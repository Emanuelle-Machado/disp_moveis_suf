import 'package:disp_moveis_suf/models/Maquina.dart';
import 'package:disp_moveis_suf/models/Marca.dart';
import 'package:disp_moveis_suf/models/OperacaoSincronizacao.dart';
import 'package:disp_moveis_suf/models/Tipo.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'network_service.dart';
import 'database_helper.dart';
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
        String erro = 'Erro ao ${op.operacao} ${op.recurso} ID: ${op.recursoId}';
        if (e.toString().contains('Falha ao')) {
          erro += ': Servidor retornou erro';
        } else {
          erro += ': $e';
        }
        erros.add(erro);
        falhas++;
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
          await networkService.criarTipo(tipo);
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
          await networkService.criarMarca(marca);
          break;
        case 'atualizar':
          await networkService.atualizarMarca(marca);
          break;
      }
    }
  }

  Future<void> _sincronizarMaquina(OperacaoSincronizacao op) async {
    final dados = jsonDecode(op.dados);
    final maquina = Maquina(
      id: op.recursoId,
      idMarca: dados['idMarca'],
      idTipo: dados['idTipo'],
      anoFabricacao: dados['anoFabricacao'],
      contatoProprietario: dados['contatoProprietario'],
      dataInclusao: dados['dataInclusao'],
      descricao: dados['descricao'],
      nomeProprietario: dados['nomeProprietario'],
      percentualComissao: dados['percentualComissao'].toDouble(),
      status: dados['status'],
      valor: dados['valor'].toDouble(),
    );
    debugPrint('Sincronizando máquina: ${op.operacao} ID: ${op.recursoId}');
    debugPrint('Dados da operação: ${op.dados}');
    switch (op.operacao) {
      case 'inserir':
        final serverId = await networkService.criarMaquina(maquina);
        if (serverId != null && serverId != op.recursoId) {
          final db = await dbHelper.database;
          await db.update(
            'maquinas',
            {'id': serverId},
            where: 'id = ?',
            whereArgs: [op.recursoId],
          );
          await db.update(
            'fila_sincronizacao',
            {'recursoId': serverId},
            where: 'recursoId = ? AND recurso = ?',
            whereArgs: [op.recursoId, 'maquina'],
          );
          debugPrint('ID local ${op.recursoId} atualizado para ID do servidor: $serverId');
        }
        await dbHelper.marcarMaquinaComoSincronizada(serverId ?? op.recursoId);
        break;
      case 'atualizar':
        await networkService.atualizarMaquina(maquina);
        await dbHelper.marcarMaquinaComoSincronizada(op.recursoId);
        break;
      case 'excluir':
        await networkService.excluirMaquina(op.recursoId);
        break;
    }
  }
}