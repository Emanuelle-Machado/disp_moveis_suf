import 'package:disp_moveis_suf/services/database_helper.dart';
import 'package:disp_moveis_suf/services/network_service.dart';
import 'package:disp_moveis_suf/services/sync_service.dart';
import 'package:disp_moveis_suf/views/maquina_edit_screen.dart';
import 'package:disp_moveis_suf/views/marca_list_screen.dart';
import 'package:disp_moveis_suf/views/tipo_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:disp_moveis_suf/models/Maquina.dart';

import 'package:disp_moveis_suf/models/Marca.dart';
import 'package:disp_moveis_suf/models/Tipo.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Máquinas',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const MaquinaListScreen(),
        '/tipos': (context) => const TipoListScreen(),
        '/marcas': (context) => const MarcaListScreen(),
      },
    );
  }
}

class MaquinaListScreen extends StatefulWidget {
  const MaquinaListScreen({Key? key}) : super(key: key);

  @override
  _MaquinaListScreenState createState() => _MaquinaListScreenState();
}

class _MaquinaListScreenState extends State<MaquinaListScreen> {
  final dbHelper = DatabaseHelper.instance;
  final syncService = SyncService();
  final networkService = NetworkService();
  List<Maquina> maquinas = [];
  List<Tipo> tipos = [];
  List<Marca> marcas = [];

  @override
  void initState() {
    super.initState();
    _inicializarDados();
  }

  Future<void> _inicializarDados() async {
    await _limparDadosCorrompidos();
    if (await syncService.estaOnline()) {
      await _sincronizarTiposMarcas();
    }
    await _carregarDados();
  }

  Future<void> _limparDadosCorrompidos() async {
    try {
      final db = await dbHelper.database;
      await db.transaction((txn) async {
        await txn.delete('maquinas');
        await txn.delete('tipos');
        await txn.delete('marcas');
        await txn.delete('fila_sincronizacao');
      });
      debugPrint('Dados corrompidos limpos: maquinas, tipos, marcas e fila_sincronizacao');
    } catch (e) {
      debugPrint('Erro ao limpar dados corrompidos: $e');
    }
  }

  Future<void> _sincronizarTiposMarcas() async {
    try {
      final tiposApi = await networkService.buscarTipos();
      final marcasApi = await networkService.buscarMarcas();
      final db = await dbHelper.database;
      await db.transaction((txn) async {
        await txn.delete('tipos');
        await txn.delete('marcas');
        for (var tipo in tiposApi) {
          await txn.insert('tipos', tipo.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
        }
        for (var marca in marcasApi) {
          await txn.insert('marcas', marca.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
        }
      });
      debugPrint('Tipos (${tiposApi.length}) e marcas (${marcasApi.length}) sincronizados');
    } catch (e) {
      debugPrint('Erro ao sincronizar tipos e marcas: $e');
    }
  }

  Future<void> _carregarDados() async {
    final maquinasCarregadas = await dbHelper.obterMaquinas();
    final tiposCarregados = await dbHelper.obterTipos();
    final marcasCarregadas = await dbHelper.obterMarcas();
    setState(() {
      maquinas = maquinasCarregadas;
      tipos = tiposCarregados;
      marcas = marcasCarregadas;
    });
  }

  Future<void> _sincronizarDados() async {
    await dbHelper.debugFilaSincronizacao();
    final resultado = await syncService.sincronizarDados();
    await _carregarDados();
    if (mounted) {
      final isError = resultado.contains('falha');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            resultado,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: Duration(seconds: isError ? 5 : 3),
        ),
      );
    }
  }

  Future<void> _buscarDadosApi() async {
    if (!await syncService.estaOnline()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sem conexão com a internet')),
        );
      }
      return;
    }
    try {
      await _sincronizarTiposMarcas();
      final maquinasApi = await networkService.buscarMaquinas();
      final maquinasLocais = await dbHelper.obterMaquinas();

      debugPrint('Máquinas locais antes da sincronização: ${maquinasLocais.map((m) => {'id': m.id, 'isSincronizado': m.isSincronizado, 'descricao': m.descricao}).toList()}');
      debugPrint('Máquinas da API: ${maquinasApi.map((m) => {'id': m.id, 'descricao': m.descricao, 'dataInclusao': m.dataInclusao}).toList()}');

      // Deduplicar máquinas da API, preferindo a mais recente por dataInclusao
      final maquinasApiUnicas = <int, Maquina>{};
      for (var maquina in maquinasApi) {
        if (!maquinasApiUnicas.containsKey(maquina.id) ||
            DateTime.parse(maquina.dataInclusao).isAfter(DateTime.parse(maquinasApiUnicas[maquina.id]!.dataInclusao))) {
          maquinasApiUnicas[maquina.id] = maquina;
        }
      }
      final maquinasApiDeduplicadas = maquinasApiUnicas.values.toList();

      debugPrint('Máquinas da API após deduplicação: ${maquinasApiDeduplicadas.map((m) => {'id': m.id, 'descricao': m.descricao}).toList()}');

      final db = await dbHelper.database;
      await db.transaction((txn) async {
        for (var maquina in maquinasApiDeduplicadas) {
          final existe = maquinasLocais.any((m) => m.id == maquina.id);
          if (!existe) {
            debugPrint('Inserindo máquina ID: ${maquina.id}, Descrição: ${maquina.descricao}');
            await txn.insert('maquinas', maquina.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
          } else {
            debugPrint('Máquina ID: ${maquina.id} já existe localmente, atualizando');
            await txn.update(
              'maquinas',
              {...maquina.toMap(), 'isSincronizado': 1},
              where: 'id = ?',
              whereArgs: [maquina.id],
            );
          }
        }
      });
      await _carregarDados();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados da API atualizados')),
        );
      }
    } catch (e) {
      debugPrint('Erro ao buscar dados: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao buscar dados: $e')),
        );
      }
    }
  }

  Future<void> _excluirMaquina(int id) async {
    await dbHelper.excluirMaquina(id);
    await _carregarDados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Máquinas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_download),
            onPressed: _buscarDadosApi,
            tooltip: 'Buscar Dados da API',
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _sincronizarDados,
            tooltip: 'Sincronizar Dados',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Máquinas'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Tipos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/tipos');
              },
            ),
            ListTile(
              leading: const Icon(Icons.branding_watermark),
              title: const Text('Marcas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/marcas');
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: maquinas.length,
        itemBuilder: (context, index) {
          final maquina = maquinas[index];
          final tipo = tipos.firstWhere((t) => t.id == maquina.idTipo, orElse: () => Tipo(id: 0, descricao: 'Desconhecido'));
          final marca = marcas.firstWhere((m) => m.id == maquina.idMarca, orElse: () => Marca(id: 0, nome: 'Desconhecida'));
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(maquina.descricao),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Marca: ${marca.nome}'),
                  Text('Tipo: ${tipo.descricao}'),
                  Text('Valor: R\$${maquina.valor.toStringAsFixed(2)}'),
                  Text('Status: ${maquina.status == 'D' ? 'Disponível' : maquina.status == 'N' ? 'Em Negociação' : maquina.status == 'R' ? 'Reservada' : 'Vendida'}'),
                  if (!maquina.isSincronizado) const Text('Pendente de sincronização', style: TextStyle(color: Colors.red)),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MaquinaEditScreen(maquina: maquina),
                  ),
                ).then((_) => _carregarDados());
              },
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Excluir Máquina'),
                    content: Text('Deseja excluir a máquina "${maquina.descricao}"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          _excluirMaquina(maquina.id);
                          Navigator.pop(context);
                        },
                        child: const Text('Excluir'),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MaquinaEditScreen(),
            ),
          ).then((_) => _carregarDados());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}