import 'package:flutter/material.dart';
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

  Future<void> _confirmarLimparCache() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpar Cache e Reiniciar?'),
        content: const Text(
          'Todos os veículos e tabelas de abastecimento salvos em cache serão apagados e o programa voltará ao zero. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Limpar Tudo',
              style: TextStyle(color: Colors.white),
            ),
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
            content: Text('Cache limpo! O programa foi reiniciado do zero.'),
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
          title: const Text('Controle de Consumo de Veículos'),
          actions: [
            TextButton.icon(
              onPressed: _confirmarLimparCache,
              icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
              label: const Text(
                'Limpar Cache',
                style: TextStyle(color: Colors.redAccent),
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
            ? const Center(child: CircularProgressIndicator())
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

  // ABA 1: Acesso aos veículos separadamente + botão para a tela dedicada de cadastro
  Widget _buildAbaControleVeiculos() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: Colors.blueGrey.shade50,
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
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Cadastre cada veículo separadamente para organizar suas planilhas mensais sem misturar dados.',
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
          const SizedBox(height: 16),
          const Text(
            'Selecione um Veículo para acessar os Meses e Anos:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _veiculos.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum veículo cadastrado em cache.\nClique em "Cadastrar Veículo" acima para começar.',
                      textAlign: TextAlign.center,
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
                            child: Icon(
                              v.tipo.toLowerCase().contains('moto')
                                  ? Icons.two_wheeler
                                  : Icons.directions_car,
                            ),
                          ),
                          title: Text(
                            'Placa: ${v.placa} (${v.tipo})',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'KM Inicial: ${v.kmInicial.toStringAsFixed(1)} | Meta Mercado: Gasolina ${v.mediaMercadoGasolina} KM/L • Álcool ${v.mediaMercadoAlcool} KM/L',
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<int>(
                    value: _mesFiltroResumo,
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<int>(
                    value: _anoFiltroResumo,
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
                        'Cadastre um veículo para visualizar as médias do mês.'),
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

                      double somaKmRodados = 0;
                      double somaLitros = 0;
                      double totalGastoMes = 0;

                      for (final r in registrosMes) {
                        somaKmRodados += r.kmRodados;
                        somaLitros += r.litros;
                        totalGastoMes += r.totalGasto;
                      }

                      final double mediaKmLitro =
                          somaLitros > 0 ? (somaKmRodados / somaLitros) : 0.0;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${v.placa} - ${v.tipo} (${nomesMeses[_mesFiltroResumo - 1]} / $_anoFiltroResumo)',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(),
                              Text(
                                '1 - Média de KM/Litro no mês até o momento: ${mediaKmLitro.toStringAsFixed(2)} KM/L',
                                style: const TextStyle(fontSize: 15),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '2 - Preço Total Gasto no mês até o momento: R\$ ${totalGastoMes.toStringAsFixed(2)} (${registrosMes.length} abastecimento(s))',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              DropdownButton<int>(
                value: _anoFiltroResumo,
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
    double litrosAnoTotal = 0;
    double litrosGasolinaAno = 0;
    double litrosAlcoolAno = 0;
    double gastoTotalAno = 0;
    final mesesComAbastecimentoNoAno = <int>{};

    for (final r in registrosAno) {
      kmRodadosAno += r.kmRodados;
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
        litrosAnoTotal > 0 ? kmRodadosAno / litrosAnoTotal : 0.0;
    final double mediaGastoMensalAno = mesesComAbastecimentoNoAno.isNotEmpty
        ? gastoTotalAno / mesesComAbastecimentoNoAno.length
        : 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.directions_car, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${v.placa} - ${v.tipo} (Ano $anoSelecionado)',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              '• Consumo Médio no Ano (KM/Litro): ${mediaKmLitroAno.toStringAsFixed(2)} KM/L',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '• Total de Litros Abastecidos em $anoSelecionado: ${litrosAnoTotal.toStringAsFixed(2)} L (Gasolina: ${litrosGasolinaAno.toStringAsFixed(2)} L | Álcool: ${litrosAlcoolAno.toStringAsFixed(2)} L)',
              style: const TextStyle(fontSize: 14.5),
            ),
            const SizedBox(height: 6),
            Text(
              '• Quilometragem Rodada em $anoSelecionado: ${kmRodadosAno.toStringAsFixed(1)} KM (${registrosAno.length} abastecimento(s))',
              style: const TextStyle(fontSize: 14.5),
            ),
            const SizedBox(height: 6),
            Text(
              '• Total Gasto no Ano: R\$ ${gastoTotalAno.toStringAsFixed(2)} (Média nos meses abastecidos: R\$ ${mediaGastoMensalAno.toStringAsFixed(2)}/mês)',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}