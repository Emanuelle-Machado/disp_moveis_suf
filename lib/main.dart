import 'package:disp_moveis_suf/services/database_helper.dart';
import 'package:disp_moveis_suf/services/network_service.dart';
import 'package:disp_moveis_suf/services/sync_service.dart';
import 'package:disp_moveis_suf/views/maquina_edit_screen.dart';
import 'package:disp_moveis_suf/views/marca_list_screen.dart';
import 'package:disp_moveis_suf/views/tipo_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:disp_moveis_suf/models/Maquina.dart';
import 'package:disp_moveis_suf/models/Marca.dart';
import 'package:disp_moveis_suf/models/Tipo.dart';
import 'package:sqflite/sqflite.dart';

import 'localizations/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.initialLocale});

  final Locale? initialLocale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: initialLocale ?? const Locale('pt', 'BR'),
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', ''),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
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
  State<MaquinaListScreen> createState() => _MaquinaListScreenState();
}

class _MaquinaListScreenState extends State<MaquinaListScreen> {
  final dbHelper = DatabaseHelper.instance;
  final syncService = SyncService();
  final networkService = NetworkService();
  List<Maquina> maquinas = [];
  List<Tipo> tipos = [];
  List<Marca> marcas = [];
  String _currentLocale = 'pt_BR';

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
      debugPrint('Dados corrompidos limpos');
    } catch (e) {
      debugPrint('Erro ao limpar dados: $e');
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
      debugPrint('Tipos e marcas sincronizados');
    } catch (e) {
      debugPrint('Erro ao sincronizar: $e');
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.dataUpdated),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _buscarDadosApi() async {
    if (!await syncService.estaOnline()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.noInternet)),
        );
      }
      return;
    }
    try {
      await _sincronizarTiposMarcas();
      final maquinasApi = await networkService.buscarMaquinas();
      final maquinasLocais = await dbHelper.obterMaquinas();

      final maquinasApiUnicas = <int, Maquina>{};
      for (var maquina in maquinasApi) {
        if (!maquinasApiUnicas.containsKey(maquina.id) ||
            DateTime.parse(maquina.dataInclusao).isAfter(DateTime.parse(maquinasApiUnicas[maquina.id]!.dataInclusao))) {
          maquinasApiUnicas[maquina.id] = maquina;
        }
      }
      final maquinasApiDeduplicadas = maquinasApiUnicas.values.toList();

      final db = await dbHelper.database;
      await db.transaction((txn) async {
        for (var maquina in maquinasApiDeduplicadas) {
          final existe = maquinasLocais.any((m) => m.id == maquina.id);
          if (!existe) {
            await txn.insert('maquinas', maquina.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
          } else {
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
          SnackBar(content: Text(AppLocalizations.of(context)!.dataUpdated)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  Future<void> _excluirMaquina(int id) async {
    await dbHelper.excluirMaquina(id);
    await _carregarDados();
  }

  void _alterarIdioma(String idioma) {
    setState(() {
      _currentLocale = idioma;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyApp(
            initialLocale: idioma == 'pt_BR' ? const Locale('pt', 'BR') : const Locale('en', ''),
          ),
        ),
      );
    });
    debugPrint('Idioma alterado para: $idioma');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Locale: ${Localizations.localeOf(context).toString()}');
    debugPrint('App Title: ${AppLocalizations.of(context)!.appTitle}');
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_download),
            onPressed: _buscarDadosApi,
            tooltip: AppLocalizations.of(context)!.dataUpdated,
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _sincronizarDados,
            tooltip: AppLocalizations.of(context)!.dataUpdated,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: _alterarIdioma,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'pt_BR',
                child: Text('Português (BR)'),
              ),
              const PopupMenuItem(
                value: 'en',
                child: Text('English'),
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Text(
                AppLocalizations.of(context)!.appTitle,
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: Text(AppLocalizations.of(context)!.machines),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: Text(AppLocalizations.of(context)!.types),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/tipos');
              },
            ),
            ListTile(
              leading: const Icon(Icons.branding_watermark),
              title: Text(AppLocalizations.of(context)!.brands),
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
          final tipo = tipos.firstWhere(
                (t) => t.id == maquina.idTipo,
            orElse: () => Tipo(id: 0, descricao: AppLocalizations.of(context)!.description),
          );
          final marca = marcas.firstWhere(
                (m) => m.id == maquina.idMarca,
            orElse: () => Marca(id: 0, nome: AppLocalizations.of(context)!.description),
          );
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(maquina.descricao),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Marca: ${marca.nome}'),
                  Text('Tipo: ${tipo.descricao}'),
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
                    title: Text(AppLocalizations.of(context)!.appTitle),
                    content: Text('Deseja excluir a máquina "${maquina.descricao}"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                      TextButton(
                        onPressed: () {
                          _excluirMaquina(maquina.id);
                          Navigator.pop(context);
                        },
                        child: Text(AppLocalizations.of(context)!.delete),
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