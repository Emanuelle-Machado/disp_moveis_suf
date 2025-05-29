import 'package:disp_moveis_suf/models/Maquina.dart';
import 'package:disp_moveis_suf/models/Marca.dart';
import 'package:disp_moveis_suf/models/Tipo.dart';
import 'package:disp_moveis_suf/services/database_helper.dart';
import 'package:disp_moveis_suf/services/network_service.dart';
import 'package:disp_moveis_suf/services/sync_service.dart';
import 'package:disp_moveis_suf/views/maquina_edit_screen.dart';
import 'package:disp_moveis_suf/views/marca_list_screen.dart';
import 'package:disp_moveis_suf/views/tipo_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaquinaApp());
}

class MaquinaApp extends StatelessWidget {
  const MaquinaApp({super.key});

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
  const MaquinaListScreen({super.key});

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
    _carregarDados();
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
      final isError = resultado.contains('falha(s)');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            resultado,
            style: TextStyle(color: Colors.white),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sem conexão com a internet')),
      );
      return;
    }
    try {
      final testResponse = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'));
      debugPrint('Teste de conexão: ${testResponse.statusCode}');

      final tiposApi = await networkService.buscarTipos();
      final marcasApi = await networkService.buscarMarcas();
      final maquinasApi = await networkService.buscarMaquinas();

      final tiposLocais = await dbHelper.obterTipos();
      final marcasLocais = await dbHelper.obterMarcas();
      final maquinasLocais = await dbHelper.obterMaquinas();

      final db = await dbHelper.database;
      await db.transaction((txn) async {
        for (var tipo in tiposApi) {
          final existe = tiposLocais.any((t) => t.id == tipo.id);
          if (!existe) {
            debugPrint('Inserindo tipo ID: ${tipo.id}');
            await txn.insert('tipos', tipo.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
          } else {
            debugPrint('Tipo ID: ${tipo.id} já existe, pulando');
          }
        }
        for (var marca in marcasApi) {
          final existe = marcasLocais.any((m) => m.id == marca.id);
          if (!existe) {
            debugPrint('Inserindo marca ID: ${marca.id}');
            await txn.insert('marcas', marca.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
          } else {
            debugPrint('Marca ID: ${marca.id} já existe, pulando');
          }
        }
        for (var maquina in maquinasApi) {
          final existePorId = maquinasLocais.any((m) => m.id == maquina.id && m.isSincronizado);
          final existePorDados = maquinasLocais.any((m) =>
          m.descricao == maquina.descricao &&
              m.dataInclusao == maquina.dataInclusao &&
              m.idMarca == maquina.idMarca &&
              m.idTipo == maquina.idTipo &&
              m.isSincronizado);
          if (!existePorId && !existePorDados) {
            debugPrint('Inserindo máquina ID: ${maquina.id}, Descrição: ${maquina.descricao}');
            await txn.insert('maquinas', maquina.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
          } else {
            debugPrint('Máquina ID: ${maquina.id} ou dados já sincronizados, pulando');
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
        String mensagem = 'Erro ao buscar dados';
        if (e.toString().contains('Erro de resolução de DNS')) {
          mensagem = 'Falha ao conectar ao servidor. Verifique sua conexão.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensagem)),
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
            ListTile(
              leading: const Icon(Icons.cloud_download),
              title: const Text('Buscar Dados da API'),
              onTap: () {
                Navigator.pop(context);
                _buscarDadosApi();
              },
            ),
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Sincronizar Dados'),
              onTap: () {
                Navigator.pop(context);
                _sincronizarDados();
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
                  Text('Status: ${maquina.status}'),
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