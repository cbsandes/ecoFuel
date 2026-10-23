import 'dart:convert';

class Veiculo {
  final String id;
  final String placa;
  final String tipo; // Ex: Carro, Moto, Utilitário, Caminhonete
  final double kmInicial;
  final double mediaMercadoGasolina; // KM/L esperado na gasolina
  final double mediaMercadoAlcool; // KM/L esperado no álcool

  Veiculo({
    required this.id,
    required this.placa,
    required this.tipo,
    required this.kmInicial,
    required this.mediaMercadoGasolina,
    required this.mediaMercadoAlcool,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'placa': placa,
      'tipo': tipo,
      'kmInicial': kmInicial,
      'mediaMercadoGasolina': mediaMercadoGasolina,
      'mediaMercadoAlcool': mediaMercadoAlcool,
    };
  }

  factory Veiculo.fromMap(Map<String, dynamic> map) {
    return Veiculo(
      id: map['id'] ?? '',
      placa: map['placa'] ?? '',
      tipo: map['tipo'] ?? 'Carro',
      kmInicial: (map['kmInicial'] ?? 0.0).toDouble(),
      mediaMercadoGasolina: (map['mediaMercadoGasolina'] ?? 10.0).toDouble(),
      mediaMercadoAlcool: (map['mediaMercadoAlcool'] ?? 7.0).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Veiculo.fromJson(String source) =>
      Veiculo.fromMap(json.decode(source));
}