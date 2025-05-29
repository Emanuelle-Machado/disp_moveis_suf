import 'package:disp_moveis_suf/models/OperacaoSincronizacao.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'network_service.dart';
import 'database_helper.dart';
import 'package:disp_moveis_suf/models/Maquina.dart';
import 'package:disp_moveis_suf/models/Marca.dart';
import 'package:disp_moveis_suf/models/Tipo.dart';
import 'package:flutter/material.dart';

class SyncService {
  final NetworkService networkService = NetworkService();
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<bool> estaOnline() async {
    try {
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts/1')).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<String> sincronizarDados() async {
    if (!await estaOnline()) {
      debugPrint('Sincronização cancelada: dispositivo offline');
      return 'Dispositivo offline';
    }
    final operacoes = await dbHelper.obterOperacoesPendentes();
    debugPrint('Operações pendentes: ${operacoes.length}');
    if (operacoes.isEmpty) {
      return 'Nenhuma operação pendente';
    }

    // Ordenar operações: tipos primeiro, depois marcas, depois máquinas
    operacoes.sort((a, b) {
      const ordem = {'tipo': 1, 'marca': 2, 'maquina': 3};
      return ordem[a.recurso]!.compareTo(ordem[b.recurso]!);
    });

    int sucessos = 0;
    int falhas = 0;
    List<String> erros = [];
    for (var op in operacoes) {
      try {
        debugPrint('Processando operação: ${op.recurso} ${op.operacao} ID: ${op.recursoId}');
        switch (op.recurso) {
          case 'tipo':
            await _sincronizarTipo(op);
            break;
          case 'marca':
            await _sincronizarMarca(op);
            break;
          case 'maquina':
            await _sincronizarMaquina(op);
            break;
        }
        await dbHelper.limparFilaSincronizacao(op.id!);
        sucessos++;
      } catch (e) {
        String erro = 'Erro ao ${op.operacao} ${op.recurso} ID: ${op.recursoId}: $e';
        erros.add(erro);
        falhas++;
        debugPrint(erro);
      }
    }
    String mensagem = 'Sincronização concluída: $sucessos operação(ões) bem-sucedida(s)';
    if (falhas > 0) {
      mensagem += ', $falhas falha(s)';
    }
    if (erros.isNotEmpty) {
      mensagem += '\nErros: ${erros.join('; ')}';
    }
    return mensagem;
  }

  Future<void> _sincronizarTipo(OperacaoSincronizacao op) async {
    debugPrint('Sincronizando tipo: ${op.operacao} ID: ${op.recursoId}');
    if (op.operacao == 'excluir') {
      await networkService.excluirTipo(op.recursoId);
    } else {
      final dados = jsonDecode(op.dados);
      final tipo = Tipo(
        id: op.recursoId,
        descricao: dados['descricao'] ?? '',
      );
      switch (op.operacao) {
        case 'inserir':
          final serverId = await networkService.criarTipo(tipo);
          if (serverId != null && serverId != op.recursoId) {
            await _atualizarIdLocal('tipos', op.recursoId, serverId);
            await _atualizarReferenciasMaquina('idTipo', op.recursoId, serverId);
            debugPrint('Tipo ID local ${op.recursoId} atualizado para ID do servidor: $serverId');
          } else if (serverId == null) {
            final serverId = await networkService.obterIdTipoPorDescricao(tipo.descricao);
            if (serverId != null) {
              await _atualizarIdLocal('tipos', op.recursoId, serverId);
              await _atualizarReferenciasMaquina('idTipo', op.recursoId, serverId);
              debugPrint('Tipo ID local ${op.recursoId} mapeado para ID do servidor: $serverId via busca');
            } else {
              throw Exception('Não foi possível obter o ID do tipo "${tipo.descricao}" no servidor');
            }
          }
          break;
        case 'atualizar':
          await networkService.atualizarTipo(tipo);
          break;
      }
    }
  }

  Future<void> _sincronizarMarca(OperacaoSincronizacao op) async {
    debugPrint('Sincronizando marca: ${op.operacao} ID: ${op.recursoId}');
    if (op.operacao == 'excluir') {
      await networkService.excluirMarca(op.recursoId);
    } else {
      final dados = jsonDecode(op.dados);
      final marca = Marca(
        id: op.recursoId,
        nome: dados['nome'] ?? '',
      );
      switch (op.operacao) {
        case 'inserir':
          final serverId = await networkService.criarMarca(marca);
          if (serverId != null && serverId != op.recursoId) {
            await _atualizarIdLocal('marcas', op.recursoId, serverId);
            await _atualizarReferenciasMaquina('idMarca', op.recursoId, serverId);
            debugPrint('Marca ID local ${op.recursoId} atualizado para ID do servidor: $serverId');
          } else if (serverId == null) {
            final serverId = await networkService.obterIdMarcaPorNome(marca.nome);
            if (serverId != null) {
              await _atualizarIdLocal('marcas', op.recursoId, serverId);
              await _atualizarReferenciasMaquina('idMarca', op.recursoId, serverId);
              debugPrint('Marca ID local ${op.recursoId} mapeado para ID do servidor: $serverId via busca');
            } else {
              throw Exception('Não foi possível obter o ID da marca "${marca.nome}" no servidor');
            }
          }
          break;
        case 'atualizar':
          await networkService.atualizarMarca(marca);
          break;
      }
    }
  }

  Future<void> _sincronizarMaquina(OperacaoSincronizacao op) async {
    debugPrint('Sincronizando máquina: ${op.operacao} ID: ${op.recursoId}');
    debugPrint('Dados da operação: ${op.dados}');
    if (op.operacao == 'excluir') {
      await networkService.excluirMaquina(op.recursoId);
    } else {
      final dados = jsonDecode(op.dados);
      // Validar dados
      if (dados['idMarca'] == null || dados['idTipo'] == null) {
        throw Exception('Marca ou Tipo inválido');
      }
      if (!['D', 'N', 'R', 'V'].contains(dados['status'])) {
        throw Exception('Status inválido: ${dados['status']}');
      }
      // Verificar se idMarca e idTipo existem no servidor
      try {
        final marcasApi = await networkService.buscarMarcas();
        final tiposApi = await networkService.buscarTipos();
        debugPrint('Marcas disponíveis no servidor: ${marcasApi.map((m) => m.id).toList()}');
        debugPrint('Tipos disponíveis no servidor: ${tiposApi.map((t) => t.id).toList()}');
        if (!marcasApi.any((m) => m.id == dados['idMarca'])) {
          throw Exception('Marca ID ${dados['idMarca']} não existe no servidor');
        }
        if (!tiposApi.any((t) => t.id == dados['idTipo'])) {
          throw Exception('Tipo ID ${dados['idTipo']} não existe no servidor');
        }
      } catch (e) {
        debugPrint('Erro ao buscar marcas ou tipos: $e');
        throw Exception('Falha ao validar Marca ou Tipo: $e');
      }
      final maquina = Maquina(
        id: op.recursoId,
        idMarca: dados['idMarca'],
        idTipo: dados['idTipo'],
        anoFabricacao: dados['anoFabricacao'],
        contatoProprietario: dados['contatoProprietario'] ?? '',
        dataInclusao: dados['dataInclusao'],
        descricao: dados['descricao'] ?? '',
        nomeProprietario: dados['nomeProprietario'] ?? '',
        percentualComissao: (dados['percentualComissao'] as num).toDouble(),
        status: dados['status'],
        valor: (dados['valor'] as num).toDouble(),
      );
      switch (op.operacao) {
        case 'inserir':
          final serverId = await networkService.criarMaquina(maquina);
          final finalId = serverId ?? op.recursoId;
          if (serverId != null && serverId != op.recursoId) {
            await _atualizarIdLocal('maquinas', op.recursoId, serverId);
            debugPrint('Máquina ID local ${op.recursoId} atualizado para ID do servidor: $serverId');
          }
          await dbHelper.marcarMaquinaComoSincronizada(finalId);
          debugPrint('Máquina ID $finalId marcada como sincronizada');
          break;
        case 'atualizar':
          final serverId = await networkService.atualizarMaquina(maquina);
          final finalId = serverId ?? op.recursoId;
          if (serverId != null && serverId != op.recursoId) {
            await _atualizarIdLocal('maquinas', op.recursoId, serverId);
            debugPrint('Máquina ID local ${op.recursoId} atualizado para ID do servidor: $serverId');
          }
          await dbHelper.marcarMaquinaComoSincronizada(finalId);
          debugPrint('Máquina ID $finalId marcada como sincronizada');
          break;
      }
    }
  }

  Future<void> _atualizarIdLocal(String tabela, int idLocal, int idServidor) async {
    final db = await dbHelper.database;
    await db.update(
      tabela,
      {'id': idServidor},
      where: 'id = ?',
      whereArgs: [idLocal],
    );
    await db.update(
      'fila_sincronizacao',
      {'recursoId': idServidor},
      where: 'recursoId = ? AND recurso = ?',
      whereArgs: [idLocal, tabela.replaceAll('s', '')],
    );
  }

  Future<void> _atualizarReferenciasMaquina(String campo, int idLocal, int idServidor) async {
    final db = await dbHelper.database;
    await db.update(
      'maquinas',
      {campo: idServidor},
      where: '$campo = ?',
      whereArgs: [idLocal],
    );
    final operacoes = await db.query(
      'fila_sincronizacao',
      where: 'recurso = ? AND operacao IN (?, ?)',
      whereArgs: ['maquina', 'inserir', 'atualizar'],
    );
    for (var op in operacoes) {
      final dados = jsonDecode(op['dados'] as String);
      if (dados[campo] == idLocal) {
        dados[campo] = idServidor;
        await db.update(
          'fila_sincronizacao',
          {'dados': jsonEncode(dados)},
          where: 'id = ?',
          whereArgs: [op['id']],
        );
      }
    }
  }
}