import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/veiculo.dart';
import '../models/abastecimento.dart';
import '../services/cache_service.dart';
import '../services/pdf_service.dart';

class AbastecimentosMesScreen extends StatefulWidget {
  final Veiculo veiculo;
  final int numeroMes;
  final String nomeMes;
  final int ano;

  const AbastecimentosMesScreen({
    super.key,
    required this.veiculo,
    required this.numeroMes,
    required this.nomeMes,
    required this.ano,
  });

  @override
  State<AbastecimentosMesScreen> createState() =>
      _AbastecimentosMesScreenState();
}

class _AbastecimentosMesScreenState extends State<AbastecimentosMesScreen> {
  List<Abastecimento> _listaMes = [];

  @override
  void initState() {
    super.initState();
    _carregarRegistrosDoMes();
  }

  Future<void> _carregarRegistrosDoMes() async {
    final todos = await CacheService.carregarAbastecimentos();
    setState(() {
      _listaMes = todos
          .where((a) =>
              a.veiculoId == widget.veiculo.id &&
              a.mes == widget.numeroMes &&
              a.ano == widget.ano)
          .toList();
    });
  }

  double _parseDecimal(String texto) {
    return double.tryParse(texto.replaceAll(',', '.').trim()) ?? 0.0;
  }

  // Abre a janela flutuante com as informações detalhadas do abastecimento selecionado
  Future<void> _mostrarDetalhesAbastecimento(Abastecimento item) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              const Icon(Icons.local_gas_station, color: Colors.blueGrey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Detalhes do Abastecimento (${item.data})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Posto: ${item.posto}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey,
                  ),
                ),
                const Divider(height: 20),
                _buildLinhaDetalhe('Placa:', item.placaVeiculo),
                _buildLinhaDetalhe('Tipo veículo:', item.tipoVeiculo),
                _buildLinhaDetalhe('Combustível:', item.tipoCombustivel),
                _buildLinhaDetalhe(
                  'KM antes no último abastecimento:',
                  '${item.kmAnterior.toStringAsFixed(1)} KM',
                ),
                _buildLinhaDetalhe(
                  'KM no abastecimento mais recente:',
                  '${item.kmAtual.toStringAsFixed(1)} KM',
                ),
                _buildLinhaDetalhe(
                  'Diferença (KM):',
                  '${item.kmRodados.toStringAsFixed(1)} KM',
                  destaque: true,
                ),
                _buildLinhaDetalhe(
                  'Litros:',
                  '${item.litros.toStringAsFixed(2)} L',
                ),
                _buildLinhaDetalhe(
                  'R\$/litro:',
                  'R\$ ${item.precoPorLitro.toStringAsFixed(2)}',
                ),
                const Divider(height: 20),
                _buildLinhaDetalhe(
                  'Média deste abastecimento:',
                  '${item.kmPorLitro.toStringAsFixed(2)} KM/L',
                  destaque: true,
                ),
                _buildLinhaDetalhe(
                  'Total gasto:',
                  'R\$ ${item.totalGasto.toStringAsFixed(2)}',
                  destaque: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _abrirFormularioAbastecimento(editando: item);
              },
              icon: const Icon(Icons.edit, color: Colors.orange),
              label: const Text('Editar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  // Widget auxiliar para formatar cada linha da janela flutuante de detalhes
  Widget _buildLinhaDetalhe(String rotulo, String valor,
      {bool destaque = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              rotulo,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              valor,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: destaque ? FontWeight.bold : FontWeight.w500,
                color: destaque ? Colors.indigo : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Abre modal para Adicionar novo abastecimento ou Editar existente
  Future<void> _abrirFormularioAbastecimento({Abastecimento? editando}) async {
    double ultimoKmSugerido = widget.veiculo.kmInicial;
    if (_listaMes.isNotEmpty && editando == null) {
      ultimoKmSugerido = _listaMes.last.kmAtual;
    }

    final dataCtrl = TextEditingController(
      text: editando?.data ?? DateFormat('dd/MM/yyyy').format(DateTime.now()),
    );
    final postoCtrl = TextEditingController(text: editando?.posto ?? '');
    final kmAnteriorCtrl = TextEditingController(
      text: (editando?.kmAnterior ?? ultimoKmSugerido).toStringAsFixed(1),
    );
    final kmAtualCtrl = TextEditingController(
      text: editando != null ? editando.kmAtual.toStringAsFixed(1) : '',
    );
    final precoLitroCtrl = TextEditingController(
      text: editando != null ? editando.precoPorLitro.toStringAsFixed(2) : '',
    );
    final litrosCtrl = TextEditingController(
      text: editando != null ? editando.litros.toStringAsFixed(2) : '',
    );
    String combustivelSelecionado = editando?.tipoCombustivel ?? 'Gasolina';

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text(
                editando == null
                    ? 'Novo Abastecimento - ${widget.nomeMes}'
                    : 'Editar Abastecimento',
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: dataCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Data do Abastecimento (dd/MM/aaaa)',
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Informe a data' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: postoCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Posto que abasteceu',
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Informe o posto' : null,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: combustivelSelecionado,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Combustível',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Gasolina',
                            child: Text('Gasolina'),
                          ),
                          DropdownMenuItem(
                            value: 'Álcool',
                            child: Text('Álcool'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => combustivelSelecionado = val);
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: kmAnteriorCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: '1 - KM antes no último abastecimento',
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Informe o KM anterior'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: kmAtualCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: '2 - KM no abastecimento mais recente',
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Informe o KM mais recente';
                          }
                          final ant = _parseDecimal(kmAnteriorCtrl.text);
                          final atu = _parseDecimal(v);
                          if (atu < ant) {
                            return 'O KM recente deve ser maior ou igual ao anterior';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: precoLitroCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'R\$ por Litro',
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Informe o R\$ por litro'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: litrosCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Quantidade de Litros Abastecidos',
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Informe os litros';
                          }
                          if (_parseDecimal(v) <= 0) {
                            return 'Litros deve ser maior que zero';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    final registro = Abastecimento(
                      id: editando?.id ??
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      veiculoId: widget.veiculo.id,
                      mes: widget.numeroMes,
                      ano: widget.ano,
                      data: dataCtrl.text.trim(),
                      posto: postoCtrl.text.trim(),
                      placaVeiculo: widget.veiculo.placa,
                      tipoVeiculo: widget.veiculo.tipo,
                      kmAnterior: _parseDecimal(kmAnteriorCtrl.text),
                      kmAtual: _parseDecimal(kmAtualCtrl.text),
                      tipoCombustivel: combustivelSelecionado,
                      precoPorLitro: _parseDecimal(precoLitroCtrl.text),
                      litros: _parseDecimal(litrosCtrl.text),
                    );

                    await CacheService.salvarOuEditarAbastecimento(registro);
                    if (ctx.mounted) Navigator.pop(ctx);
                    _carregarRegistrosDoMes();
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Calcula o diagnóstico comparando a frequência de KM/Litro atual com a média tabelada do mercado
  String _avaliarConsumoMercado(double mediaKmPorLitro) {
    if (_listaMes.isEmpty || mediaKmPorLitro <= 0) {
      return 'Sem dados suficientes no mês';
    }

    double somaMetas = 0;
    for (final a in _listaMes) {
      somaMetas += a.tipoCombustivel == 'Gasolina'
          ? widget.veiculo.mediaMercadoGasolina
          : widget.veiculo.mediaMercadoAlcool;
    }
    final metaMediaEsperada = somaMetas / _listaMes.length;

    if (mediaKmPorLitro >= metaMediaEsperada) {
      return 'NA MÉDIA DO MERCADO (Fazendo ${mediaKmPorLitro.toStringAsFixed(2)} KM/L | Esperado: ${metaMediaEsperada.toStringAsFixed(1)} KM/L)';
    } else {
      return 'CONSUMINDO DEMAIS! (Fazendo ${mediaKmPorLitro.toStringAsFixed(2)} KM/L | Abaixo da tabela de ${metaMediaEsperada.toStringAsFixed(1)} KM/L)';
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalGastoMes = 0;
    double somaKmRodados = 0;
    double somaLitros = 0;

    for (final a in _listaMes) {
      totalGastoMes += a.totalGasto;
      somaKmRodados += a.kmRodados;
      somaLitros += a.litros;
    }

    final int qtd = _listaMes.length;
    final double mediaGastoPorAbastecimento =
        qtd > 0 ? totalGastoMes / qtd : 0.0;
    final double mediaKmRodados = qtd > 0 ? somaKmRodados / qtd : 0.0;
    final double mediaKmPorLitro =
        somaLitros > 0 ? somaKmRodados / somaLitros : 0.0;
    final String statusMercado = _avaliarConsumoMercado(mediaKmPorLitro);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar',
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.nomeMes}/${widget.ano} - ${widget.veiculo.placa} (${widget.veiculo.tipo})',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ElevatedButton.icon(
              onPressed: () => _abrirFormularioAbastecimento(),
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Abastecimento'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TABELA DE ABASTECIMENTOS DO MÊS (FILTRADA)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Tabela de Abastecimentos - ${widget.nomeMes} (${widget.veiculo.placa})',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Dica: Clique em qualquer abastecimento da tabela para abrir a janela flutuante com todos os detalhes de KM, veículo e combustível.',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 10),
                    _listaMes.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(
                              child: Text(
                                'Nenhum abastecimento registrado neste mês. Clique em "Adicionar Abastecimento" no topo.',
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              showCheckboxColumn: false,
                              headingRowColor: WidgetStateProperty.all(
                                Colors.blueGrey.shade100,
                              ),
                              columns: const [
                                DataColumn(label: Text('Data')),
                                DataColumn(label: Text('Posto')),
                                DataColumn(label: Text('Litros Abastecidos')),
                                DataColumn(label: Text('KM/Litro')),
                                DataColumn(label: Text('Total Gasto')),
                                DataColumn(label: Text('Ações')),
                              ],
                              rows: _listaMes.map((a) {
                                return DataRow(
                                  // Ao clicar na linha, abre a janela flutuante com as informações restantes
                                  onSelectChanged: (_) =>
                                      _mostrarDetalhesAbastecimento(a),
                                  cells: [
                                    DataCell(Text(a.data)),
                                    DataCell(Text(a.posto)),
                                    DataCell(
                                      Text('${a.litros.toStringAsFixed(2)} L'),
                                    ),
                                    DataCell(
                                      Text(
                                        '${a.kmPorLitro.toStringAsFixed(2)} KM/L',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        'R\$ ${a.totalGasto.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.visibility,
                                              color: Colors.blueGrey,
                                            ),
                                            tooltip: 'Ver detalhes completos',
                                            onPressed: () =>
                                                _mostrarDetalhesAbastecimento(a),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.orange,
                                            ),
                                            tooltip: 'Editar abastecimento',
                                            onPressed: () =>
                                                _abrirFormularioAbastecimento(
                                                    editando: a),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            tooltip: 'Excluir abastecimento',
                                            onPressed: () async {
                                              await CacheService
                                                  .excluirAbastecimento(a.id);
                                              _carregarRegistrosDoMes();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),

                    const Divider(height: 28, thickness: 1.5),

                    // RODAPÉ DA TABELA COM TOTAIS E MÉDIAS
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blueGrey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rodapé da Tabela — Resumo do Mês até o Momento:',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• Total Gasto no Mês: R\$ ${totalGastoMes.toStringAsFixed(2)} (Média gasta por abastecimento: R\$ ${mediaGastoPorAbastecimento.toStringAsFixed(2)})',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '• Média de KMs Rodados até o momento: ${mediaKmRodados.toStringAsFixed(1)} KM por abastecimento (Total rodado no mês: ${somaKmRodados.toStringAsFixed(1)} KM)',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '• Média de Consumo (KM/Litro) até o momento: ${mediaKmPorLitro.toStringAsFixed(2)} KM/L',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusMercado.startsWith('NA MÉDIA')
                                  ? Colors.green.shade100
                                  : Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Diagnóstico de Mercado: $statusMercado',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: statusMercado.startsWith('NA MÉDIA')
                                    ? Colors.green.shade900
                                    : Colors.red.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // BOTÃO IMPRIMIR TABELA (.PDF) LOGO ABAIXO DA TABELA
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _listaMes.isEmpty
                  ? null
                  : () {
                      PdfService.gerarPdfDoMes(
                        veiculo: widget.veiculo,
                        nomeMes: widget.nomeMes,
                        ano: widget.ano,
                        abastecimentos: _listaMes,
                        totalGastoMes: totalGastoMes,
                        mediaGastoPorAbastecimento: mediaGastoPorAbastecimento,
                        mediaKmRodados: mediaKmRodados,
                        mediaKmPorLitro: mediaKmPorLitro,
                        statusConsumoMercado: statusMercado,
                      );
                    },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text(
                'Imprimir Tabela (.pdf)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 12),

            // BOTÃO VOLTAR
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text('Voltar para os Meses do Veículo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}