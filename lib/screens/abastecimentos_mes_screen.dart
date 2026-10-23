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

  // Abre modal para Adicionar novo abastecimento ou Editar existente
  Future<void> _abrirFormularioAbastecimento({Abastecimento? editando}) async {
    // Sugere automaticamente o último KM registrado ou o KM inicial do veículo
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
                          labelText: '1 - KM Total do Último Abastecimento',
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
                          labelText: '2 - KM Total Mais Recente',
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Informe o KM atual';
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

    // Calcula a meta ponderada conforme os abastecimentos do mês (Gasolina vs Álcool)
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
            // TABELA DE ABASTECIMENTOS DO MÊS
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
                    const SizedBox(height: 8),
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
                              headingRowColor: WidgetStateProperty.all(
                                Colors.blueGrey.shade100,
                              ),
                              columns: const [
                                DataColumn(label: Text('Data')),
                                DataColumn(label: Text('Posto')),
                                DataColumn(label: Text('Placa')),
                                DataColumn(label: Text('Tipo')),
                                DataColumn(label: Text('Combustível')),
                                DataColumn(label: Text('KM Último')),
                                DataColumn(label: Text('KM Recente')),
                                DataColumn(label: Text('Diferença (KM)')),
                                DataColumn(label: Text('Litros')),
                                DataColumn(label: Text('R\$/Litro')),
                                DataColumn(label: Text('KM/Litro')),
                                DataColumn(label: Text('Total Gasto')),
                                DataColumn(label: Text('Editar / Excluir')),
                              ],
                              rows: _listaMes.map((a) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(a.data)),
                                    DataCell(Text(a.posto)),
                                    DataCell(Text(a.placaVeiculo)),
                                    DataCell(Text(a.tipoVeiculo)),
                                    DataCell(Text(a.tipoCombustivel)),
                                    DataCell(
                                        Text(a.kmAnterior.toStringAsFixed(1))),
                                    DataCell(
                                        Text(a.kmAtual.toStringAsFixed(1))),
                                    DataCell(
                                      Text(
                                        a.kmRodados.toStringAsFixed(1),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataCell(Text(a.litros.toStringAsFixed(2))),
                                    DataCell(Text(
                                        'R\$ ${a.precoPorLitro.toStringAsFixed(2)}')),
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
                                            icon: const Icon(Icons.edit,
                                                color: Colors.orange),
                                            tooltip: 'Editar abastecimento',
                                            onPressed: () =>
                                                _abrirFormularioAbastecimento(
                                                    editando: a),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
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