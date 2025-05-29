import 'dart:convert';
import 'package:disp_moveis_suf/models/Maquina.dart';
import 'package:disp_moveis_suf/models/Marca.dart';
import 'package:disp_moveis_suf/models/Tipo.dart';
import 'package:http/http.dart' as http;

class NetworkService {
  final String baseUrl = 'https://argo.td.utfpr.edu.br/maquinas/ws';

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  // Tipos
  Future<List<Tipo>> buscarTipos() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tipo'), headers: _headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Tipo.fromMap(json)).toList();
      }
      throw Exception('Falha ao buscar tipos: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erro ao buscar tipos: $e');
    }
  }

  Future<void> criarTipo(Tipo tipo) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tipo'),
        headers: _headers,
        body: jsonEncode(tipo.toApiMap()),
      );
      if (response.statusCode != 201 && response.statusCode != 204) {
        throw Exception('Falha ao criar tipo: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao criar tipo: $e');
    }
  }

  Future<void> atualizarTipo(Tipo tipo) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/tipo/${tipo.id}'),
        headers: _headers,
        body: jsonEncode(tipo.toApiMap()),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Falha ao atualizar tipo: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar tipo: $e');
    }
  }

  Future<void> excluirTipo(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/tipo/$id'), headers: _headers);
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Falha ao excluir tipo: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao excluir tipo: $e');
    }
  }

  // Marcas
  Future<List<Marca>> buscarMarcas() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/marca'), headers: _headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Marca.fromMap(json)).toList();
      }
      throw Exception('Falha ao buscar marcas: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erro ao buscar marcas: $e');
    }
  }

  Future<void> criarMarca(Marca marca) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/marca'),
        headers: _headers,
        body: jsonEncode(marca.toApiMap()),
      );
      if (response.statusCode != 201 && response.statusCode != 204) {
        throw Exception('Falha ao criar marca: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao criar marca: $e');
    }
  }

  Future<void> atualizarMarca(Marca marca) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/marca/${marca.id}'),
        headers: _headers,
        body: jsonEncode(marca.toApiMap()),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Falha ao atualizar marca: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar marca: $e');
    }
  }

  Future<void> excluirMarca(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/marca/$id'), headers: _headers);
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Falha ao excluir marca: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao excluir marca: $e');
    }
  }

  // Máquinas
  Future<List<Maquina>> buscarMaquinas({
    double? valorDe,
    double? valorAte,
    String? status,
    int? idTipo,
    int? idMarca,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (valorDe != null) queryParams['valorDe'] = valorDe.toString();
      if (valorAte != null) queryParams['valorAte'] = valorAte.toString();
      if (status != null) queryParams['status'] = status;
      if (idTipo != null) queryParams['idTipo'] = idTipo.toString();
      if (idMarca != null) queryParams['idMarca'] = idMarca.toString();

      final uri = Uri.parse('$baseUrl/maquina').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Maquina.fromMap({...json, 'isSincronizado': 1})).toList();
      }
      throw Exception('Falha ao buscar máquinas: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Erro ao buscar máquinas: $e');
    }
  }

  Future<void> criarMaquina(Maquina maquina) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/maquina'),
        headers: _headers,
        body: jsonEncode(maquina.toApiMap()),
      );
      if (response.statusCode != 201 && response.statusCode != 204) {
        throw Exception('Falha ao criar máquina: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao criar máquina: $e');
    }
  }

  Future<void> atualizarMaquina(Maquina maquina) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/maquina/${maquina.id}'),
        headers: _headers,
        body: jsonEncode(maquina.toApiMap()),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Falha ao atualizar máquina: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar máquina: $e');
    }
  }

  Future<void> excluirMaquina(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/maquina/$id'), headers: _headers);
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Falha ao excluir máquina: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao excluir máquina: $e');
    }
  }
}