import 'package:flutter/material.dart';
import '../models/veiculo.dart';
import '../services/cache_service.dart';

class CadastroVeiculoScreen extends StatefulWidget {
  const CadastroVeiculoScreen({super.key});

  @override
  State<CadastroVeiculoScreen> createState() => _CadastroVeiculoScreenState();
}

class _CadastroVeiculoScreenState extends State<CadastroVeiculoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _placaController = TextEditingController();
  String _tipoSelecionado = 'Carro';
  final _kmInicialController = TextEditingController(text: '0');
  final _mediaGasolinaController = TextEditingController(text: '11.0');
  final _mediaAlcoolController = TextEditingController(text: '7.5');

  final List<String> _tiposVeiculo = [
    'Carro',
    'Moto',
    'Caminhonete / Picape',
    'Utilitário / Van',
    'Caminhão',
  ];

  double _parseNumero(String valor) {
    return double.tryParse(valor.replaceAll(',', '.').trim()) ?? 0.0;
  }

  Future<void> _salvarVeiculo() async {
    if (!_formKey.currentState!.validate()) return;

    final novoVeiculo = Veiculo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      placa: _placaController.text.trim().toUpperCase(),
      tipo: _tipoSelecionado,
      kmInicial: _parseNumero(_kmInicialController.text),
      mediaMercadoGasolina: _parseNumero(_mediaGasolinaController.text),
      mediaMercadoAlcool: _parseNumero(_mediaAlcoolController.text),
    );

    await CacheService.salvarVeiculo(novoVeiculo);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veículo cadastrado com sucesso!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _placaController.dispose();
    _kmInicialController.dispose();
    _mediaGasolinaController.dispose();
    _mediaAlcoolController.dispose();
    super.dispose();
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
        title: const Text('Cadastro de Veículo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Dados do Veículo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _placaController,
                decoration: const InputDecoration(
                  labelText: 'Placa do Veículo (Ex: ABC-1234 ou ABC1D23)',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Informe a placa do veículo'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _tipoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Tipo do Veículo',
                  border: OutlineInputBorder(),
                ),
                items: _tiposVeiculo
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _tipoSelecionado = val);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _kmInicialController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'KM Total Inicial do Odômetro',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Média Tabelada de Mercado (Para Diagnóstico de Consumo)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _mediaGasolinaController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Média Mercado Gasolina (KM/L)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _mediaAlcoolController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Média Mercado Álcool (KM/L)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _salvarVeiculo,
                icon: const Icon(Icons.save),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text('Salvar Veículo no Cache'),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Voltar à Página Anterior'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}