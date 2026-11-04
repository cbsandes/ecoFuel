import 'package:flutter/material.dart';
import '../main.dart';
import '../models/veiculo.dart';
import '../models/abastecimento.dart';
import '../services/cache_service.dart';
import 'abastecimentos_mes_screen.dart';

class MesesVeiculoScreen extends StatefulWidget {
  final Veiculo veiculo;

  const MesesVeiculoScreen({super.key, required this.veiculo});

  @override
  State<MesesVeiculoScreen> createState() => _MesesVeiculoScreenState();
}

class _MesesVeiculoScreenState extends State<MesesVeiculoScreen> {
  List<Abastecimento> _todosAbastecimentosVeiculo = [];
  int _anoSelecionado = DateTime.now().year;

  static const List<String> nomesMesesPorExtenso = [
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
    _carregarAbastecimentos();
  }

  Future<void> _carregarAbastecimentos() async {
    final todos = await CacheService.carregarAbastecimentos();
    setState(() {
      _todosAbastecimentosVeiculo =
          todos.where((a) => a.veiculoId == widget.veiculo.id).toList();
    });
  }

  List<int> _obterAnosDisponiveis() {
    final anoAtual = DateTime.now().year;
    final anosSet = <int>{anoAtual - 1, anoAtual, anoAtual + 1};
    for (final a in _todosAbastecimentosVeiculo) {
      anosSet.add(a.ano);
    }
    final lista = anosSet.toList()..sort();
    return lista;
  }

  @override
  Widget build(BuildContext context) {
    final abastecimentosDoAno = _todosAbastecimentosVeiculo
        .where((a) => a.ano == _anoSelecionado)
        .toList();

    // Cálculo de Consumo do Ano Selecionado
    double totalGastoAno = 0;
    double totalKmAno = 0;
    double totalLitrosAno = 0;

    for (final a in abastecimentosDoAno) {
      totalGastoAno += a.totalGasto;
      totalKmAno += a.kmRodados;
      totalLitrosAno += a.litros;
    }
    final double mediaKmLitroAno =
        totalLitrosAno > 0 ? totalKmAno / totalLitrosAno : 0.0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.verdeEletrico),
          tooltip: 'Voltar',
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Meses - ${widget.veiculo.placa} (${widget.veiculo.tipo})',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // PAINEL SUPERIOR DESTACADO EM VERDE PROFUNDO: SELETOR DE ANO + CONSUMO POR ANO
            Card(
              color: AppColors.verdeProfundo,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side:
                    const BorderSide(color: AppColors.verdeEletrico, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Consumo no Ano ($_anoSelecionado)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.brancoLeitura,
                          ),
                        ),
                        Row(
                          children: [
                            const Text(
                              'Ano: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.brancoLeitura,
                              ),
                            ),
                            DropdownButton<int>(
                              value: _anoSelecionado,
                              dropdownColor: AppColors.superficieCard,
                              style: const TextStyle(
                                color: AppColors.verdeEletrico,
                                fontWeight: FontWeight.bold,
                              ),
                              items: _obterAnosDisponiveis().map((ano) {
                                return DropdownMenuItem(
                                  value: ano,
                                  child: Text('$ano'),
                                );
                              }).toList(),
                              onChanged: (novoAno) {
                                if (novoAno != null) {
                                  setState(() => _anoSelecionado = novoAno);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.verdeEletrico),
                    Text(
                      '• Média Anual: ${mediaKmLitroAno.toStringAsFixed(2)} KM/L  |  Litros: ${totalLitrosAno.toStringAsFixed(1)} L  |  Rodado: ${totalKmAno.toStringAsFixed(1)} KM',
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppColors.brancoLeitura,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• Total Gasto no Ano: R\$ ${totalGastoAno.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.verdeEletrico,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Selecione o mês por extenso ($_anoSelecionado) para ver ou cadastrar abastecimentos:',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.brancoLeitura,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: nomesMesesPorExtenso.length,
                itemBuilder: (context, index) {
                  final numeroMes = index + 1;
                  final nomeMes = nomesMesesPorExtenso[index];
                  final doMes = abastecimentosDoAno
                      .where((a) => a.mes == numeroMes)
                      .toList();

                  double totalMes = 0;
                  double somaKm = 0;
                  double somaLitros = 0;
                  for (final item in doMes) {
                    totalMes += item.totalGasto;
                    somaKm += item.kmRodados;
                    somaLitros += item.litros;
                  }
                  final mediaKmL = somaLitros > 0 ? somaKm / somaLitros : 0.0;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: doMes.isNotEmpty
                            ? AppColors.verdeEletrico
                            : AppColors.verdeProfundo,
                        child: Text(
                          '$numeroMes',
                          style: TextStyle(
                            color: doMes.isNotEmpty
                                ? AppColors.pretoGrafite
                                : AppColors.cinzaSecundario,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        nomeMes,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brancoLeitura,
                        ),
                      ),
                      subtitle: Text(
                        doMes.isEmpty
                            ? 'Nenhum abastecimento registrado em $nomeMes/$_anoSelecionado'
                            : '${doMes.length} abastecimento(s) • Total: R\$ ${totalMes.toStringAsFixed(2)} • Média: ${mediaKmL.toStringAsFixed(2)} KM/L',
                        style: TextStyle(
                          color: doMes.isEmpty
                              ? AppColors.cinzaSecundario
                              : AppColors.verdeEletrico,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.open_in_new,
                        color: AppColors.verdeEletrico,
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AbastecimentosMesScreen(
                              veiculo: widget.veiculo,
                              numeroMes: numeroMes,
                              nomeMes: nomeMes,
                              ano: _anoSelecionado,
                            ),
                          ),
                        );
                        _carregarAbastecimentos();
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.verdeEletrico,
              ),
              label: const Text('Voltar à Seleção de Veículos'),
            ),
          ],
        ),
      ),
    );
  }
}