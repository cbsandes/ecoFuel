import 'package:flutter/material.dart';
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
          icon: const Icon(Icons.arrow_back),
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
            // PAINEL SUPERIOR: SELETOR DE ANO + CONSUMO POR ANO
            Card(
              color: Colors.blueGrey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
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
                          ),
                        ),
                        Row(
                          children: [
                            const Text(
                              'Ano: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            DropdownButton<int>(
                              value: _anoSelecionado,
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
                    const Divider(),
                    Text(
                      '• Média Anual: ${mediaKmLitroAno.toStringAsFixed(2)} KM/L | Litros no Ano: ${totalLitrosAno.toStringAsFixed(1)} L | Rodado no Ano: ${totalKmAno.toStringAsFixed(1)} KM | Total Gasto: R\$ ${totalGastoAno.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Selecione o mês por extenso ($_anoSelecionado) para ver ou cadastrar abastecimentos:',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
                            ? Colors.blue.shade700
                            : Colors.grey.shade400,
                        child: Text(
                          '$numeroMes',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        nomeMes,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        doMes.isEmpty
                            ? 'Nenhum abastecimento registrado em $nomeMes/$_anoSelecionado'
                            : '${doMes.length} abastecimento(s) • Total: R\$ ${totalMes.toStringAsFixed(2)} • Média: ${mediaKmL.toStringAsFixed(2)} KM/L',
                      ),
                      trailing: const Icon(Icons.open_in_new),
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
              icon: const Icon(Icons.arrow_back),
              label: const Text('Voltar à Seleção de Veículos'),
            ),
          ],
        ),
      ),
    );
  }
}