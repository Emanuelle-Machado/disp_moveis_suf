import 'dart:convert';
import 'package:disp_moveis_suf/models/Maquina.dart';
import 'package:disp_moveis_suf/models/Marca.dart';
import 'package:disp_moveis_suf/models/Tipo.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class NetworkService {
  final String baseUrl = 'https://argo.td.utfpr.edu.br/maquinas/ws';

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  // Tipos
  Future<List<Tipo>> buscarTipos() async {
    try {
      final uri = Uri.parse('$baseUrl/tipo');
      debugPrint('Buscando tipos em: $uri');
      final response = await http.get(uri, headers: _headers).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Tempo limite excedido ao buscar tipos'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Tipo.fromMap(json)).toList();
      }
      throw Exception('Falha ao buscar tipos: ${response.statusCode}');
    } catch (e) {
      debugPrint('Erro ao buscar tipos: $e');
      if (e.toString().contains('Failed host lookup')) {
        throw Exception('Erro de resolução de DNS: verifique a conexão ou o servidor');
      }
      throw Exception('Erro ao buscar tipos: $e');
    }
  }

  Future<void> criarTipo(Tipo tipo) async {
    try {
      final uri = Uri.parse('$baseUrl/tipo');
      debugPrint('Criando tipo em: $uri, dados: ${jsonEncode(tipo.toApiMap())}');
      final response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(tipo.toApiMap()),
      );
      if (response.statusCode != 201 && response.statusCode != 204) {
        throw Exception('Falha ao criar tipo: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao criar tipo: $e');
      throw Exception('Erro ao criar tipo: $e');
    }
  }

  Future<void> atualizarTipo(Tipo tipo) async {
    try {
      final uri = Uri.parse('$baseUrl/tipo/${tipo.id}');
      debugPrint('Atualizando tipo em: $uri, dados: ${jsonEncode(tipo.toApiMap())}');
      final response = await http.put(
        uri,
        headers: _headers,
        body: jsonEncode(tipo.toApiMap()),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Falha ao atualizar tipo: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao atualizar tipo: $e');
      throw Exception('Erro ao atualizar tipo: $e');
    }
  }

  Future<void> excluirTipo(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/tipo/$id');
      debugPrint('Excluindo tipo em: $uri');
      final response = await http.delete(uri, headers: _headers);
      debugPrint('Resposta da exclusão de tipo ID $id: ${response.statusCode}');
      if (response.statusCode != 200 && response.statusCode != 204 && response.statusCode != 404) {
        throw Exception('Falha ao excluir tipo: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao excluir tipo: $e');
      throw Exception('Erro ao excluir tipo: $e');
    }
  }

  // Marcas
  Future<List<Marca>> buscarMarcas() async {
    try {
      final uri = Uri.parse('$baseUrl/marca');
      debugPrint('Buscando marcas em: $uri');
      final response = await http.get(uri, headers: _headers).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Tempo limite excedido ao buscar marcas'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Marca.fromMap(json)).toList();
      }
      throw Exception('Falha ao buscar marcas: ${response.statusCode}');
    } catch (e) {
      debugPrint('Erro ao buscar marcas: $e');
      if (e.toString().contains('Failed host lookup')) {
        throw Exception('Erro de resolução de DNS: verifique a conexão ou o servidor');
      }
      throw Exception('Erro ao buscar marcas: $e');
    }
  }

  Future<void> criarMarca(Marca marca) async {
    try {
      final uri = Uri.parse('$baseUrl/marca');
      debugPrint('Criando marca em: $uri, dados: ${jsonEncode(marca.toApiMap())}');
      final response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(marca.toApiMap()),
      );
      if (response.statusCode != 201 && response.statusCode != 204) {
        throw Exception('Falha ao criar marca: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao criar marca: $e');
      throw Exception('Erro ao criar marca: $e');
    }
  }

  Future<void> atualizarMarca(Marca marca) async {
    try {
      final uri = Uri.parse('$baseUrl/marca/${marca.id}');
      debugPrint('Atualizando marca em: $uri, dados: ${jsonEncode(marca.toApiMap())}');
      final response = await http.put(
        uri,
        headers: _headers,
        body: jsonEncode(marca.toApiMap()),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Falha ao atualizar marca: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao atualizar marca: $e');
      throw Exception('Erro ao atualizar marca: $e');
    }
  }

  Future<void> excluirMarca(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/marca/$id');
      debugPrint('Excluindo marca em: $uri');
      final response = await http.delete(uri, headers: _headers);
      debugPrint('Resposta da exclusão de marca ID $id: ${response.statusCode}');
      if (response.statusCode != 200 && response.statusCode != 204 && response.statusCode != 404) {
        throw Exception('Falha ao excluir marca: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao excluir marca: $e');
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
      debugPrint('Buscando máquinas em: $uri');
      final response = await http.get(uri, headers: _headers).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Tempo limite excedido ao buscar máquinas'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Maquina.fromMap({...json, 'isSincronizado': 1})).toList();
      }
      throw Exception('Falha ao buscar máquinas: ${response.statusCode}');
    } catch (e) {
      debugPrint('Erro ao buscar máquinas: $e');
      if (e.toString().contains('Failed host lookup')) {
        throw Exception('Erro de resolução de DNS: verifique a conexão ou o servidor');
      }
      throw Exception('Erro ao buscar máquinas: $e');
    }
  }

  Future<int?> criarMaquina(Maquina maquina) async {
    try {
      final uri = Uri.parse('$baseUrl/maquina');
      debugPrint('Criando máquina em: $uri, dados: ${jsonEncode(maquina.toApiMap())}');
      final response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(maquina.toApiMap()),
      );
      if (response.statusCode == 201 || response.statusCode == 204) {
        if (response.statusCode == 201 && response.body.isNotEmpty) {
          try {
            final data = jsonDecode(response.body);
            final serverId = data['id'] as int?;
            debugPrint('Máquina criada com ID do servidor: $serverId');
            return serverId;
          } catch (e) {
            debugPrint('Não foi possível extrair ID da resposta: $e');
          }
        }
        return null;
      }
      throw Exception('Falha ao criar máquina: ${response.statusCode}');
    } catch (e) {
      debugPrint('Erro ao criar máquina: $e');
      throw Exception('Erro ao criar máquina: $e');
    }
  }

  Future<void> atualizarMaquina(Maquina maquina) async {
    try {
      final uri = Uri.parse('$baseUrl/maquina/${maquina.id}');
      debugPrint('Atualizando máquina em: $uri, dados: ${jsonEncode(maquina.toApiMap())}');
      final response = await http.put(
        uri,
        headers: _headers,
        body: jsonEncode(maquina.toApiMap()),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Falha ao atualizar máquina: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao atualizar máquina: $e');
      throw Exception('Erro ao atualizar máquina: $e');
    }
  }

  Future<void> excluirMaquina(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/maquina/$id');
      debugPrint('Excluindo máquina em: $uri');
      final response = await http.delete(uri, headers: _headers);
      debugPrint('Resposta da exclusão de máquina ID $id: ${response.statusCode}');
      if (response.statusCode != 200 && response.statusCode != 204 && response.statusCode != 404) {
        throw Exception('Falha ao excluir máquina: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao excluir máquina: $e');
      throw Exception('Erro ao excluir máquina: $e');
    }
  }
}