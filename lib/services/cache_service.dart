import 'package:shared_preferences/shared_preferences.dart';
import '../models/veiculo.dart';
import '../models/abastecimento.dart';

class CacheService {
  static const String _keyVeiculos = 'cache_veiculos_v1';
  static const String _keyAbastecimentos = 'cache_abastecimentos_v1';

  // Carrega todos os veículos salvos em cache
  static Future<List<Veiculo>> carregarVeiculos() async {
    final prefs = await SharedPreferences.getInstance();
    final listaJson = prefs.getStringList(_keyVeiculos) ?? [];
    return listaJson.map((item) => Veiculo.fromJson(item)).toList();
  }

  // Salva um novo veículo no cache
  static Future<void> salvarVeiculo(Veiculo novoVeiculo) async {
    final prefs = await SharedPreferences.getInstance();
    final veiculos = await carregarVeiculos();
    veiculos.add(novoVeiculo);
    final listaJson = veiculos.map((v) => v.toJson()).toList();
    await prefs.setStringList(_keyVeiculos, listaJson);
  }

  // Remove um veículo específico e todos os abastecimentos vinculados a ele
  static Future<void> excluirVeiculo(String veiculoId) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Remove o veículo da lista de veículos
    final veiculos = await carregarVeiculos();
    veiculos.removeWhere((v) => v.id == veiculoId);
    final veiculosJson = veiculos.map((v) => v.toJson()).toList();
    await prefs.setStringList(_keyVeiculos, veiculosJson);

    // 2. Remove os abastecimentos daquele veículo para não deixar lixo no cache
    final abastecimentos = await carregarAbastecimentos();
    abastecimentos.removeWhere((a) => a.veiculoId == veiculoId);
    final abastecimentosJson = abastecimentos.map((a) => a.toJson()).toList();
    await prefs.setStringList(_keyAbastecimentos, abastecimentosJson);
  }

  // Carrega todos os abastecimentos salvos em cache
  static Future<List<Abastecimento>> carregarAbastecimentos() async {
    final prefs = await SharedPreferences.getInstance();
    final listaJson = prefs.getStringList(_keyAbastecimentos) ?? [];
    return listaJson.map((item) => Abastecimento.fromJson(item)).toList();
  }

  // Adiciona ou atualiza (edita) um abastecimento no cache
  static Future<void> salvarOuEditarAbastecimento(
      Abastecimento registro) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = await carregarAbastecimentos();

    final index = lista.indexWhere((a) => a.id == registro.id);
    if (index >= 0) {
      lista[index] = registro; // Edita registro existente
    } else {
      lista.add(registro); // Adiciona novo registro
    }

    final listaJson = lista.map((a) => a.toJson()).toList();
    await prefs.setStringList(_keyAbastecimentos, listaJson);
  }

  // Remove um abastecimento específico se necessário
  static Future<void> excluirAbastecimento(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = await carregarAbastecimentos();
    lista.removeWhere((a) => a.id == id);
    final listaJson = lista.map((a) => a.toJson()).toList();
    await prefs.setStringList(_keyAbastecimentos, listaJson);
  }

  // LIMPAR CACHE: Zera completamente os dados do aplicativo
  static Future<void> limparTodoCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}