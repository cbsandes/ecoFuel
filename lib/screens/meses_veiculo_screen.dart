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
  List<Abastecimento> _abastecimentosVeiculo = [];
  final int _anoSelecionado = DateTime.now().year;

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
      _abastecimentosVeiculo = todos
          .where((a) =>
              a.veiculoId == widget.veiculo.id && a.ano == _anoSelecionado)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
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
            Text(
              'Selecione o mês por extenso ($_anoSelecionado) para ver ou cadastrar abastecimentos:',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: nomesMesesPorExtenso.length,
                itemBuilder: (context, index) {
                  final numeroMes = index + 1;
                  final nomeMes = nomesMesesPorExtenso[index];
                  final doMes = _abastecimentosVeiculo
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
                    margin: const EdgeInsets.symmetric(vertical: 5),
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
                            ? 'Nenhum abastecimento registrado'
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
