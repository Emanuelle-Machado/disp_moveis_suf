import 'package:disp_moveis_suf/models/Maquina.dart';
import 'package:disp_moveis_suf/models/Marca.dart';
import 'package:disp_moveis_suf/models/Tipo.dart';
import 'package:disp_moveis_suf/services/api_service.dart';
import 'package:flutter/foundation.dart';

class AppState with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Tipo> _tipos = [];
  List<Marca> _marcas = [];
  List<Maquina> _maquinas = [];

  List<Tipo> get tipos => _tipos;
  List<Marca> get marcas => _marcas;
  List<Maquina> get maquinas => _maquinas;

  Future<void> fetchTipos() async {
    _tipos = await _apiService.getTipos();
    notifyListeners();
  }

  Future<void> fetchMarcas() async {
    _marcas = await _apiService.getMarcas();
    notifyListeners();
  }

  Future<void> fetchMaquinas({
    double? valorDe,
    double? valorAte,
    String? status,
    int? idTipo,
    int? idMarca,
  }) async {
    _maquinas = await _apiService.getMaquinas(
      valorDe: valorDe,
      valorAte: valorAte,
      status: status,
      idTipo: idTipo,
      idMarca: idMarca,
    );
    notifyListeners();
  }

  Future<void> createMaquina(Maquina maquina) async {
    await _apiService.createMaquina(maquina);
    await fetchMaquinas();
  }

  Future<void> updateMaquina(Maquina maquina, int id) async {
    await _apiService.updateMaquina(maquina, id);
    await fetchMaquinas();
  }

  Future<void> deleteMaquina(int id) async {
    await _apiService.deleteMaquina(id);
    await fetchMaquinas();
  }
}
