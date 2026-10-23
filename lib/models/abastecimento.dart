import 'dart:convert';

class Abastecimento {
  final String id;
  final String veiculoId;
  final int mes; // 1 = Janeiro ... 12 = Dezembro
  final int ano;
  final String data; // Formato dd/MM/yyyy
  final String posto;
  final String placaVeiculo;
  final String tipoVeiculo;
  final double kmAnterior; // 1 - KM total do último abastecimento
  final double kmAtual; // 2 - KM total do abastecimento mais recente
  final String tipoCombustivel; // 'Gasolina' ou 'Álcool'
  final double precoPorLitro; // R$ por litro
  final double litros; // Quantidade de litros abastecidos

  Abastecimento({
    required this.id,
    required this.veiculoId,
    required this.mes,
    required this.ano,
    required this.data,
    required this.posto,
    required this.placaVeiculo,
    required this.tipoVeiculo,
    required this.kmAnterior,
    required this.kmAtual,
    required this.tipoCombustivel,
    required this.precoPorLitro,
    required this.litros,
  });

  // 3 - Diferença do quanto andou entre abastecimentos
  double get kmRodados {
    final diferenca = kmAtual - kmAnterior;
    return diferenca > 0 ? diferenca : 0.0;
  }

  // Cálculo de KM/Litro: Diferença dividida por Quantidade de litros
  double get kmPorLitro {
    if (litros <= 0) return 0.0;
    return kmRodados / litros;
  }

  // Cálculo de Total Gasto: R$ por litro multiplicado por Quantidade de litros
  double get totalGasto {
    return precoPorLitro * litros;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'veiculoId': veiculoId,
      'mes': mes,
      'ano': ano,
      'data': data,
      'posto': posto,
      'placaVeiculo': placaVeiculo,
      'tipoVeiculo': tipoVeiculo,
      'kmAnterior': kmAnterior,
      'kmAtual': kmAtual,
      'tipoCombustivel': tipoCombustivel,
      'precoPorLitro': precoPorLitro,
      'litros': litros,
    };
  }

  factory Abastecimento.fromMap(Map<String, dynamic> map) {
    return Abastecimento(
      id: map['id'] ?? '',
      veiculoId: map['veiculoId'] ?? '',
      mes: map['mes'] ?? 1,
      ano: map['ano'] ?? DateTime.now().year,
      data: map['data'] ?? '',
      posto: map['posto'] ?? '',
      placaVeiculo: map['placaVeiculo'] ?? '',
      tipoVeiculo: map['tipoVeiculo'] ?? '',
      kmAnterior: (map['kmAnterior'] ?? 0.0).toDouble(),
      kmAtual: (map['kmAtual'] ?? 0.0).toDouble(),
      tipoCombustivel: map['tipoCombustivel'] ?? 'Gasolina',
      precoPorLitro: (map['precoPorLitro'] ?? 0.0).toDouble(),
      litros: (map['litros'] ?? 0.0).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Abastecimento.fromJson(String source) =>
      Abastecimento.fromMap(json.decode(source));
}
