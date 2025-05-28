import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:disp_moveis_suf/models/Maquina.dart';
import 'package:disp_moveis_suf/models/Marca.dart';
import 'package:disp_moveis_suf/models/OperacaoSincronizacao.dart';
import 'package:disp_moveis_suf/models/Tipo.dart';
import 'network_service.dart';
import 'database_helper.dart';


class SyncService {
  final NetworkService networkService = NetworkService();
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<bool> estaOnline() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> sincronizarDados() async {
    if (!await estaOnline()) return;

    final operacoes = await dbHelper.obterOperacoesPendentes();

    for (var op in operacoes) {
      try {
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
      } catch (e) {
        print('Erro ao sincronizar ${op.recurso} ${op.operacao} ${op.recursoId}: $e');
      }
    }
  }

  Future<void> _sincronizarTipo(OperacaoSincronizacao op) async {
    if (op.operacao == 'inserir') {
      await networkService.criarTipo(Tipo.fromMap(jsonDecode(op.dados)));
    } else if (op.operacao == 'atualizar') {
      await networkService.atualizarTipo(Tipo.fromMap(jsonDecode(op.dados)));
    } else if (op.operacao == 'excluir') {
      await networkService.excluirTipo(op.recursoId);
    }
  }

  Future<void> _sincronizarMarca(OperacaoSincronizacao op) async {
    if (op.operacao == 'inserir') {
      await networkService.criarMarca(Marca.fromMap(jsonDecode(op.dados)));
    } else if (op.operacao == 'atualizar') {
      await networkService.atualizarMarca(Marca.fromMap(jsonDecode(op.dados)));
    } else if (op.operacao == 'excluir') {
      await networkService.excluirMarca(op.recursoId);
    }
  }

  Future<void> _sincronizarMaquina(OperacaoSincronizacao op) async {
    if (op.operacao == 'inserir') {
      await networkService.criarMaquina(Maquina.fromMap(jsonDecode(op.dados)));
    } else if (op.operacao == 'atualizar') {
      await networkService.atualizarMaquina(Maquina.fromMap(jsonDecode(op.dados)));
    } else if (op.operacao == 'excluir') {
      await networkService.excluirMaquina(op.recursoId);
    }
  }
}