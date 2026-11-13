import 'package:flutter/material.dart';
import '../main.dart';
import '../models/veiculo.dart';
import '../models/abastecimento.dart';
import '../services/cache_service.dart';
import 'cadastro_veiculo_screen.dart';
import 'meses_veiculo_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Veiculo> _veiculos = [];
  List<Abastecimento> _abastecimentos = [];
  bool _carregando = true;
  int _mesFiltroResumo = DateTime.now().month;
  int _anoFiltroResumo = DateTime.now().year;

  static const List<String> nomesMeses = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _carregando = true);
    final veiculos = await CacheService.carregarVeiculos();
    final abastecimentos = await CacheService.carregarAbastecimentos();
    setState(() {
      _veiculos = veiculos;
      _abastecimentos = abastecimentos;
      _carregando = false;
    });
  }

  List<int> _obterAnosDisponiveis() {
    final anoAtual = DateTime.now().year;
    final anosSet = <int>{anoAtual - 1, anoAtual, anoAtual + 1};
    for (final a in _abastecimentos) {
      anosSet.add(a.ano);
    }
    final lista = anosSet.toList()..sort();
    return lista;
  }

  // Confirma a exclusão individual de um veículo já criado
  Future<void> _confirmarExcluirVeiculo(Veiculo veiculo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover Veículo?'),
        content: Text(
          'Deseja remover o veículo de placa "${veiculo.placa}" (${veiculo.tipo}) e todos os abastecimentos vinculados a ele?',
          style: const TextStyle(color: AppColors.cinzaSecundario),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.cinzaSecundario),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: AppColors.brancoLeitura,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover Veículo'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await CacheService.excluirVeiculo(veiculo.id);
      await _carregarDados();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.verdeProfundo,
            content: Text(
              'Veículo ${veiculo.placa} removido com sucesso!',
              style: const TextStyle(color: AppColors.brancoLeitura),
            ),
          ),
        );
      }
    }
  }

  Future<void> _confirmarLimparCache() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpar Cache e Reiniciar?'),
        content: const Text(
          'Todos os veículos e tabelas de abastecimento salvos em cache serão apagados e o programa voltará ao zero. Deseja continuar?',
          style: TextStyle(color: AppColors.cinzaSecundario),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.cinzaSecundario),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: AppColors.brancoLeitura,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Limpar Tudo'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await CacheService.limparTodoCache();
      await _carregarDados();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.verdeProfundo,
            content: Text(
              'Cache limpo! O programa foi reiniciado do zero.',
              style: TextStyle(color: AppColors.brancoLeitura),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Consumo de Veículos'),
          actions: [
            TextButton.icon(
              onPressed: _confirmarLimparCache,
              icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
              label: const Text(
                'Limpar Cache',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.directions_car),
                text: 'Veículos e Controle',
              ),
              Tab(
                icon: Icon(Icons.calendar_month),
                text: 'Médias do Mês',
              ),
              Tab(
                icon: Icon(Icons.bar_chart),
                text: 'Consumo por Ano',
              ),
            ],
          ),
        ),
        body: _carregando
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.verdeEletrico,
                ),
              )
            : TabBarView(
                children: [
                  _buildAbaControleVeiculos(),
                  _buildAbaConsumosMediosMes(),
                  _buildAbaConsumoPorAno(),
                ],
              ),
      ),
    );
  }

  // ABA 1: Acesso aos veículos separadamente + card destacado em Verde Profundo
  Widget _buildAbaControleVeiculos() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: AppColors.verdeProfundo,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.verdeEletrico, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sessão de Cadastro de Veículos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.brancoLeitura,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Cadastre cada veículo separadamente para organizar suas planilhas mensais sem misturar dados.',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: AppColors.brancoLeitura,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CadastroVeiculoScreen(),
                        ),
                      );
                      _carregarDados();
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Cadastrar Veículo'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Selecione um Veículo para acessar os Meses e Anos:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.brancoLeitura,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _veiculos.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum veículo cadastrado em cache.\nClique em "Cadastrar Veículo" acima para começar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.cinzaSecundario,
                        fontSize: 15,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _veiculos.length,
                    itemBuilder: (context, index) {
                      final v = _veiculos[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.verdeProfundo,
                            foregroundColor: AppColors.verdeEletrico,
                            child: Icon(
                              v.tipo.toLowerCase().contains('moto')
                                  ? Icons.two_wheeler
                                  : Icons.directions_car,
                            ),
                          ),
                          title: Text(
                            'Placa: ${v.placa}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.brancoLeitura,
                            ),
                          ),
                          subtitle: Text(
                            'KM Inicial: ${v.kmInicial.toStringAsFixed(1)}  \nConsumo de Mercado: Gasolina ${v.mediaMercadoGasolina} KM/L • Álcool ${v.mediaMercadoAlcool} KM/L',
                            style: const TextStyle(
                              color: AppColors.cinzaSecundario,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                ),
                                tooltip: 'Remover este veículo',
                                onPressed: () => _confirmarExcluirVeiculo(v),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 18,
                                color: AppColors.verdeEletrico,
                              ),
                            ],
                          ),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MesesVeiculoScreen(veiculo: v),
                              ),
                            );
                            _carregarDados();
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ABA 2: Consumos médios do mês por carro até o presente momento
  Widget _buildAbaConsumosMediosMes() {
    final anosDisponiveis = _obterAnosDisponiveis();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Mês: ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brancoLeitura,
                    ),
                  ),
                  DropdownButton<int>(
                    value: _mesFiltroResumo,
                    dropdownColor: AppColors.superficieCard,
                    style: const TextStyle(color: AppColors.verdeEletrico),
                    items: List.generate(12, (i) {
                      return DropdownMenuItem(
                        value: i + 1,
                        child: Text(nomesMeses[i]),
                      );
                    }),
                    onChanged: (novoMes) {
                      if (novoMes != null) {
                        setState(() => _mesFiltroResumo = novoMes);
                      }
                    },
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Ano: ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brancoLeitura,
                    ),
                  ),
                  DropdownButton<int>(
                    value: _anoFiltroResumo,
                    dropdownColor: AppColors.superficieCard,
                    style: const TextStyle(color: AppColors.verdeEletrico),
                    items: anosDisponiveis.map((ano) {
                      return DropdownMenuItem(
                        value: ano,
                        child: Text('$ano'),
                      );
                    }).toList(),
                    onChanged: (novoAno) {
                      if (novoAno != null) {
                        setState(() => _anoFiltroResumo = novoAno);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _veiculos.isEmpty
                ? const Center(
                    child: Text(
                      'Cadastre um veículo para visualizar as médias do mês.',
                      style: TextStyle(color: AppColors.cinzaSecundario),
                    ),
                  )
                : ListView.builder(
                    itemCount: _veiculos.length,
                    itemBuilder: (context, index) {
                      final v = _veiculos[index];
                      final registrosMes = _abastecimentos
                          .where((a) =>
                              a.veiculoId == v.id &&
                              a.mes == _mesFiltroResumo &&
                              a.ano == _anoFiltroResumo)
                          .toList();

                      double somaKmEfetivo = 0;
                      double somaLitros = 0;
                      double totalGastoMes = 0;

                      for (final r in registrosMes) {
                        somaKmEfetivo += r.kmEfetivoConsumo;
                        somaLitros += r.litros;
                        totalGastoMes += r.totalGasto;
                      }

                      final double mediaKmLitro =
                          somaLitros > 0 ? (somaKmEfetivo / somaLitros) : 0.0;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    v.placa,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.brancoLeitura,
                                    ),
                                  ),
                                  Text(
                                    '${nomesMeses[_mesFiltroResumo - 1]} / $_anoFiltroResumo (${registrosMes.length} reg.)',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.cinzaSecundario,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    '1 - Média de KM/Litro no mês:',
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      color: AppColors.cinzaSecundario,
                                    ),
                                  ),
                                  Text(
                                    '${mediaKmLitro.toStringAsFixed(2)} KM/L',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.brancoLeitura,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    '2 - Preço Total Gasto no mês:',
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      color: AppColors.cinzaSecundario,
                                    ),
                                  ),
                                  Text(
                                    'R\$ ${totalGastoMes.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.verdeEletrico,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ABA 3: Somente Consumo por Ano
  Widget _buildAbaConsumoPorAno() {
    final anosDisponiveis = _obterAnosDisponiveis();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Selecione o Ano de Referência: ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brancoLeitura,
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<int>(
                value: _anoFiltroResumo,
                dropdownColor: AppColors.superficieCard,
                style: const TextStyle(color: AppColors.verdeEletrico),
                items: anosDisponiveis.map((ano) {
                  return DropdownMenuItem(
                    value: ano,
                    child: Text('$ano'),
                  );
                }).toList(),
                onChanged: (novoAno) {
                  if (novoAno != null) {
                    setState(() => _anoFiltroResumo = novoAno);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _veiculos.isEmpty
                ? const Center(
                    child: Text(
                      'Cadastre um veículo para analisar o Consumo por Ano.',
                      style: TextStyle(color: AppColors.cinzaSecundario),
                    ),
                  )
                : ListView.builder(
                    itemCount: _veiculos.length,
                    itemBuilder: (context, index) {
                      final v = _veiculos[index];
                      return _buildCardConsumoAnual(v, _anoFiltroResumo);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardConsumoAnual(Veiculo v, int anoSelecionado) {
    final registrosAno = _abastecimentos
        .where((a) => a.veiculoId == v.id && a.ano == anoSelecionado)
        .toList();

    double kmRodadosAno = 0;
    double kmEfetivoAno = 0;
    double litrosAnoTotal = 0;
    double litrosGasolinaAno = 0;
    double litrosAlcoolAno = 0;
    double gastoTotalAno = 0;
    final mesesComAbastecimentoNoAno = <int>{};

    for (final r in registrosAno) {
      kmRodadosAno += r.kmRodados;
      kmEfetivoAno += r.kmEfetivoConsumo;
      litrosAnoTotal += r.litros;
      if (r.tipoCombustivel == 'Gasolina') {
        litrosGasolinaAno += r.litros;
      } else {
        litrosAlcoolAno += r.litros;
      }
      gastoTotalAno += r.totalGasto;
      mesesComAbastecimentoNoAno.add(r.mes);
    }

    final double mediaKmLitroAno =
        litrosAnoTotal > 0 ? kmEfetivoAno / litrosAnoTotal : 0.0;
    final double mediaGastoMensalAno = mesesComAbastecimentoNoAno.isNotEmpty
        ? gastoTotalAno / mesesComAbastecimentoNoAno.length
        : 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.directions_car, color: AppColors.verdeEletrico),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    v.placa,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brancoLeitura,
                    ),
                  ),
                ),
                Text(
                  'Ano $anoSelecionado (${registrosAno.length} reg.)',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.cinzaSecundario,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              '• Consumo Médio no Ano: ${mediaKmLitroAno.toStringAsFixed(2)} KM/L',
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
                color: AppColors.brancoLeitura,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '• Total de Litros em $anoSelecionado: ${litrosAnoTotal.toStringAsFixed(2)} L (Gasolina: ${litrosGasolinaAno.toStringAsFixed(2)} L | Álcool: ${litrosAlcoolAno.toStringAsFixed(2)} L)',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.cinzaSecundario,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '• Quilometragem Rodada em $anoSelecionado: ${kmRodadosAno.toStringAsFixed(1)} KM (KM Efetivo: ${kmEfetivoAno.toStringAsFixed(1)} KM)',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.cinzaSecundario,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.verdeProfundo,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Gasto no Ano: R\$ ${gastoTotalAno.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.verdeEletrico,
                    ),
                  ),
                  Text(
                    'Média: R\$ ${mediaGastoMensalAno.toStringAsFixed(2)}/mês',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.brancoLeitura,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}