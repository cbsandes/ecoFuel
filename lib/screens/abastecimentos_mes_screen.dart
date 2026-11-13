import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
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
    final variacao = item.variacaoMargemTanque;
    final sinalVariacao = variacao >= 0 ? '+' : '';

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(
                Icons.local_gas_station,
                color: AppColors.verdeEletrico,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Detalhes do Abastecimento (${item.data})',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brancoLeitura,
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
                    color: AppColors.verdeEletrico,
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
                  'Diferença no Odômetro (KM):',
                  '${item.kmRodados.toStringAsFixed(1)} KM',
                ),
                const Divider(height: 16),
                _buildLinhaDetalhe(
                  'KM p/ esvaziar (Último abast.):',
                  '${item.kmRestanteTanqueAnterior.toStringAsFixed(0)} KM',
                ),
                _buildLinhaDetalhe(
                  'KM p/ esvaziar (Abast. recente):',
                  '${item.kmRestanteTanqueAtual.toStringAsFixed(0)} KM',
                ),
                _buildLinhaDetalhe(
                  'Variação na margem do tanque:',
                  '$sinalVariacao${variacao.toStringAsFixed(1)} KM',
                ),
                _buildLinhaDetalhe(
                  'KM Efetivo (Ajustado p/ cálculo):',
                  '${item.kmEfetivoConsumo.toStringAsFixed(1)} KM',
                  destaque: true,
                ),
                const Divider(height: 16),
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
                  'Média real deste abastecimento:',
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
              icon: const Icon(Icons.edit, color: AppColors.verdeEletrico),
              label: const Text(
                'Editar',
                style: TextStyle(color: AppColors.verdeEletrico),
              ),
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
                color: AppColors.cinzaSecundario,
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
                color: destaque
                    ? AppColors.verdeEletrico
                    : AppColors.brancoLeitura,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para criar um tópico principal do rodapé
  Widget _buildTopicoRodape({
    required String titulo,
    String? valorDestaque,
    Color corValor = AppColors.brancoLeitura,
  }) {
    return Row(
      children: [
        const Icon(
          Icons.circle,
          size: 7,
          color: AppColors.verdeEletrico,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: AppColors.brancoLeitura,
              ),
              children: [
                TextSpan(text: '$titulo '),
                if (valorDestaque != null)
                  TextSpan(
                    text: valorDestaque,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: corValor,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget auxiliar para criar um subtópico espaçado e recuado no rodapé
  Widget _buildSubtopicoRodape({
    required String rotulo,
    required String valor,
    Color corValor = AppColors.brancoLeitura,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 22.0, top: 5.0),
      child: Row(
        children: [
          const Text(
            '–  ',
            style: TextStyle(
              color: AppColors.verdeEletrico,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.cinzaSecundario,
                ),
                children: [
                  TextSpan(text: '$rotulo '),
                  TextSpan(
                    text: valor,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: corValor,
                    ),
                  ),
                ],
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
    double ultimaMargemTanqueSugerida = 0.0;

    if (_listaMes.isNotEmpty && editando == null) {
      ultimoKmSugerido = _listaMes.last.kmAtual;
      ultimaMargemTanqueSugerida = _listaMes.last.kmRestanteTanqueAtual;
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
    final kmRestanteAnteriorCtrl = TextEditingController(
      text: (editando?.kmRestanteTanqueAnterior ?? ultimaMargemTanqueSugerida)
          .toStringAsFixed(0),
    );
    final kmRestanteAtualCtrl = TextEditingController(
      text: editando != null
          ? editando.kmRestanteTanqueAtual.toStringAsFixed(0)
          : '',
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
                        style: const TextStyle(color: AppColors.brancoLeitura),
                        decoration: const InputDecoration(
                          labelText: 'Data do Abastecimento (dd/MM/aaaa)',
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Informe a data' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: postoCtrl,
                        style: const TextStyle(color: AppColors.brancoLeitura),
                        decoration: const InputDecoration(
                          labelText: 'Posto que abasteceu',
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Informe o posto' : null,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: combustivelSelecionado,
                        dropdownColor: AppColors.superficieCard,
                        style: const TextStyle(color: AppColors.brancoLeitura),
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
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: kmAnteriorCtrl,
                        style: const TextStyle(color: AppColors.brancoLeitura),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: '1 - KM antes no último abastecimento',
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Informe o KM anterior'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: kmAtualCtrl,
                        style: const TextStyle(color: AppColors.brancoLeitura),
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
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: kmRestanteAnteriorCtrl,
                        style: const TextStyle(color: AppColors.brancoLeitura),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText:
                              'KM p/ esvaziar no último abastecimento (Painel)',
                          helperText:
                              'Quantos KM faltavam p/ esvaziar na vez anterior',
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Informe a margem anterior (ou 0)'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: kmRestanteAtualCtrl,
                        style: const TextStyle(color: AppColors.brancoLeitura),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText:
                              'KM p/ esvaziar neste abastecimento (Ex: 40, 80, 100)',
                          helperText:
                              'Quantos KM faltavam no painel ao parar no posto hoje',
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Informe quantos KM faltavam p/ esvaziar'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: precoLitroCtrl,
                        style: const TextStyle(color: AppColors.brancoLeitura),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'R\$ por Litro',
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Informe o R\$ por litro'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: litrosCtrl,
                        style: const TextStyle(color: AppColors.brancoLeitura),
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
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: AppColors.cinzaSecundario),
                  ),
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
                      kmRestanteTanqueAnterior:
                          _parseDecimal(kmRestanteAnteriorCtrl.text),
                      kmRestanteTanqueAtual:
                          _parseDecimal(kmRestanteAtualCtrl.text),
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
      return 'Média de mercado (Fazendo ${mediaKmPorLitro.toStringAsFixed(2)} KM/L | Esperado: ${metaMediaEsperada.toStringAsFixed(1)} KM/L)';
    } else {
      return 'Consumo elevado! (Fazendo ${mediaKmPorLitro.toStringAsFixed(2)} KM/L | Abaixo da tabela de ${metaMediaEsperada.toStringAsFixed(1)} KM/L)';
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalGastoMes = 0;
    double somaKmRodados = 0;
    double somaKmEfetivoConsumo = 0;
    double somaLitros = 0;

    for (final a in _listaMes) {
      totalGastoMes += a.totalGasto;
      somaKmRodados += a.kmRodados;
      somaKmEfetivoConsumo += a.kmEfetivoConsumo;
      somaLitros += a.litros;
    }

    final int qtd = _listaMes.length;
    final double mediaGastoPorAbastecimento =
        qtd > 0 ? totalGastoMes / qtd : 0.0;
    final double mediaKmRodados = qtd > 0 ? somaKmRodados / qtd : 0.0;
    // Usa o KM Efetivo (compensado pela margem de esvaziamento do tanque) para uma média real precisa
    final double mediaKmPorLitro =
        somaLitros > 0 ? somaKmEfetivoConsumo / somaLitros : 0.0;
    final String statusMercado = _avaliarConsumoMercado(mediaKmPorLitro);
    final bool dentroDaMedia = statusMercado.startsWith('Média de mercado');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.verdeEletrico),
          tooltip: 'Voltar',
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.nomeMes}/${widget.ano} - ${widget.veiculo.placa}',
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
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Tabela de Abastecimentos de ${widget.nomeMes}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brancoLeitura,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Dica: Selecione qualquer abastecimento da tabela para visualizar todos os detalhes de KM, margem do tanque, veículo e combustível.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.cinzaSecundario,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _listaMes.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(
                              child: Text(
                                'Nenhum abastecimento registrado neste mês. Selecione "Adicionar Abastecimento".',
                                style: TextStyle(
                                  color: AppColors.cinzaSecundario,
                                ),
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              showCheckboxColumn: false,
                              headingRowColor: WidgetStateProperty.all(
                                AppColors.verdeProfundo,
                              ),
                              headingTextStyle: const TextStyle(
                                color: AppColors.brancoLeitura,
                                fontWeight: FontWeight.bold,
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
                                  onSelectChanged: (_) =>
                                      _mostrarDetalhesAbastecimento(a),
                                  cells: [
                                    DataCell(
                                      Text(
                                        a.data,
                                        style: const TextStyle(
                                          color: AppColors.cinzaSecundario,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        a.posto,
                                        style: const TextStyle(
                                          color: AppColors.brancoLeitura,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '${a.litros.toStringAsFixed(2)} L',
                                        style: const TextStyle(
                                          color: AppColors.brancoLeitura,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '${a.kmPorLitro.toStringAsFixed(2)} KM/L',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.brancoLeitura,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        'R\$ ${a.totalGasto.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.verdeEletrico,
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
                                              color: AppColors.cinzaSecundario,
                                            ),
                                            tooltip: 'Ver detalhes completos',
                                            onPressed: () =>
                                                _mostrarDetalhesAbastecimento(a),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: AppColors.verdeEletrico,
                                            ),
                                            tooltip: 'Editar abastecimento',
                                            onPressed: () =>
                                                _abrirFormularioAbastecimento(
                                                    editando: a),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.redAccent,
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

                    const Divider(height: 28),

                    // RODAPÉ DA TABELA COM TÓPICOS E SUBTÓPICOS ESPAÇADOS
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.verdeProfundo,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.verdeEletrico.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Resumo do Mês até o Momento:',
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.brancoLeitura,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // TÓPICO 1: GASTOS DO MÊS + SUBTÓPICO
                          _buildTopicoRodape(
                            titulo: 'Total Gasto no Mês:',
                            valorDestaque:
                                'R\$ ${totalGastoMes.toStringAsFixed(2)}',
                            corValor: AppColors.verdeEletrico,
                          ),
                          _buildSubtopicoRodape(
                            rotulo: 'Média por abastecimento:',
                            valor:
                                'R\$ ${mediaGastoPorAbastecimento.toStringAsFixed(2)}',
                            corValor: AppColors.verdeEletrico,
                          ),

                          const SizedBox(height: 14),

                          // TÓPICO 2: QUILOMETRAGEM + SUBTÓPICOS
                          _buildTopicoRodape(
                            titulo: 'Quilometragem Rodada até o momento:',
                          ),
                          _buildSubtopicoRodape(
                            rotulo: 'Total físico rodado no odômetro:',
                            valor: '${somaKmRodados.toStringAsFixed(1)} KM',
                          ),
                          _buildSubtopicoRodape(
                            rotulo: 'KM efetivo compensado pela margem do tanque:',
                            valor:
                                '${somaKmEfetivoConsumo.toStringAsFixed(1)} KM',
                            corValor: AppColors.verdeEletrico,
                          ),
                          _buildSubtopicoRodape(
                            rotulo: 'Média de KMs por abastecimento:',
                            valor: '${mediaKmRodados.toStringAsFixed(1)} KM',
                          ),

                          const SizedBox(height: 14),

                          // TÓPICO 3: MÉDIA DE CONSUMO + SUBTÓPICO
                          _buildTopicoRodape(
                            titulo: 'Média de Consumo (KM/Litro) até o momento:',
                            valorDestaque:
                                '${mediaKmPorLitro.toStringAsFixed(2)} KM/L',
                          ),
                          _buildSubtopicoRodape(
                            rotulo: 'Referência de mercado do veículo:',
                            valor:
                                'Gasolina ${widget.veiculo.mediaMercadoGasolina.toStringAsFixed(1)} KM/L • Álcool ${widget.veiculo.mediaMercadoAlcool.toStringAsFixed(1)} KM/L',
                          ),

                          const SizedBox(height: 16),

                          // DIAGNÓSTICO DE MERCADO
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.pretoGrafite,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: dentroDaMedia
                                    ? AppColors.verdeEletrico
                                    : Colors.amberAccent,
                              ),
                            ),
                            child: Text(
                              'Diagnóstico de Mercado: $statusMercado',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: dentroDaMedia
                                    ? AppColors.verdeEletrico
                                    : Colors.amberAccent,
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

            // BOTÃO IMPRIMIR TABELA (.PDF) LOGO ABAIXO DA TABELA (EM VERDE ELÉTRICO)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.verdeEletrico,
                foregroundColor: AppColors.pretoGrafite,
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
                        somaKmRodados: somaKmRodados,
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
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.verdeEletrico,
              ),
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