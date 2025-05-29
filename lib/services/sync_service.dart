import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:disp_moveis_suf/models/Maquina.dart';
import 'package:disp_moveis_suf/models/Marca.dart';
import 'package:disp_moveis_suf/models/OperacaoSincronizacao.dart';
import 'package:disp_moveis_suf/models/Tipo.dart';
import 'package:flutter/material.dart';
import 'network_service.dart';
import 'database_helper.dart';
import 'dart:convert';

class SyncService {
  final NetworkService networkService = NetworkService();
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<bool> estaOnline() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      bool online = connectivityResult != ConnectivityResult.none;
      debugPrint('Conexão: ${online ? "Online" : "Offline"}');
      return online;
    } catch (e) {
      debugPrint('Erro ao verificar conexão: $e');
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
      debugPrint('Nenhuma operação pendente para sincronizar');
      return 'Nenhuma operação pendente';
    }

    int sucessos = 0;
    int falhas = 0;
    List<String> erros = [];

    for (var op in operacoes) {
      try {
        debugPrint('Processando operação: ${op.recurso} ${op.operacao} ID: ${op.recursoId}');
        debugPrint('Dados da operação: ${op.dados}');
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
          default:
            debugPrint('Recurso desconhecido: ${op.recurso}');
            continue;
        }
        // Marcar como sincronizado no banco
        if (op.recurso == 'maquina') {
          await dbHelper.marcarMaquinaComoSincronizada(op.recursoId);
        }
        await dbHelper.limparFilaSincronizacao(op.id!);
        debugPrint('Operação ${op.recurso} ${op.operacao} ID: ${op.recursoId} sincronizada com sucesso');
        sucessos++;
      } catch (e) {
        debugPrint('Erro ao sincronizar ${op.recurso} ${op.operacao} ID: ${op.recursoId}: $e');
        erros.add('Erro em ${op.recurso} ${op.operacao} ID: ${op.recursoId}: $e');
        falhas++;
      }
    }

    String mensagem = 'Sincronização concluída: $sucessos operação(ões) bem-sucedida(s), $falhas falha(s)';
    if (erros.isNotEmpty) {
      mensagem += '\nErros: ${erros.join('; ')}';
    }
    return mensagem;
  }

  Future<void> _sincronizarTipo(OperacaoSincronizacao op) async {
    debugPrint('Sincronizando tipo: ${op.operacao} ID: ${op.recursoId}');
    try {
      final dados = jsonDecode(op.dados);
      final tipo = Tipo.fromMap({
        'id': op.recursoId,
        'descricao': dados['descricao'] ?? '',
      });
      if (op.operacao == 'inserir') {
        await networkService.criarTipo(tipo);
      } else if (op.operacao == 'atualizar') {
        await networkService.atualizarTipo(tipo);
      } else if (op.operacao == 'excluir') {
        await networkService.excluirTipo(op.recursoId);
      }
    } catch (e) {
      throw Exception('Erro ao sincronizar tipo: $e');
    }
  }

  Future<void> _sincronizarMarca(OperacaoSincronizacao op) async {
    debugPrint('Sincronizando marca: ${op.operacao} ID: ${op.recursoId}');
    try {
      final dados = jsonDecode(op.dados);
      final marca = Marca.fromMap({
        'id': op.recursoId,
        'nome': dados['nome'] ?? '',
      });
      if (op.operacao == 'inserir') {
        await networkService.criarMarca(marca);
      } else if (op.operacao == 'atualizar') {
        await networkService.atualizarMarca(marca);
      } else if (op.operacao == 'excluir') {
        await networkService.excluirMarca(op.recursoId);
      }
    } catch (e) {
      throw Exception('Erro ao sincronizar marca: $e');
    }
  }

  Future<void> _sincronizarMaquina(OperacaoSincronizacao op) async {
    debugPrint('Sincronizando máquina: ${op.operacao} ID: ${op.recursoId}');
    try {
      final dados = jsonDecode(op.dados);
      final maquina = Maquina.fromMap({
        'id': op.recursoId,
        'idMarca': dados['idMarca'] ?? 0,
        'idTipo': dados['idTipo'] ?? 0,
        'anoFabricacao': dados['anoFabricacao'] ?? 0,
        'contatoProprietario': dados['contatoProprietario'] ?? '',
        'dataInclusao': dados['dataInclusao'] ?? '',
        'descricao': dados['descricao'] ?? '',
        'nomeProprietario': dados['nomeProprietario'] ?? '',
        'percentualComissao': dados['percentualComissao'] ?? 0.0,
        'status': dados['status'] ?? 'D',
        'valor': dados['valor'] ?? 0.0,
        'isSincronizado': 0,
      });
      if (op.operacao == 'inserir') {
        await networkService.criarMaquina(maquina);
      } else if (op.operacao == 'atualizar') {
        await networkService.atualizarMaquina(maquina);
      } else if (op.operacao == 'excluir') {
        await networkService.excluirMaquina(op.recursoId);
      }
    } catch (e) {
      throw Exception('Erro ao sincronizar máquina: $e');
    }
  }
}