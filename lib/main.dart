import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:disp_moveis_suf/services/DatabaseService.dart';
import 'package:flutter/material.dart';
import 'widgets/Menu.dart';
import 'views/MaquinaScreen.dart';
import 'views/MarcaScreen.dart';
import 'views/TipoScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventário de maquinário',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Inventário'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    initConnectivityListener();
  }

  void initConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        DatabaseService().syncAllResources();
      }
    });
  }

  void _navigateTo(Widget screen) async {
    Navigator.pop(context); // Fecha o Drawer primeiro
    await Future.delayed(
      const Duration(milliseconds: 250),
    ); // Aguarda Drawer fechar
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        centerTitle: true,
      ),
      drawer: Menu(
        onTipo: () => _navigateTo(const TipoScreen()),
        onMarca: () => _navigateTo(const MarcaScreen()),
        onMaquina: () => _navigateTo(const MaquinaScreen()),
        onFetch:
            () => _navigateTo(const Placeholder()), // Implementar se necessário
        onSync:
            () => _navigateTo(const Placeholder()), // Implementar se necessário
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Center(
                child: Icon(Icons.construction, size: 100, color: Colors.white),
                // Substitua por uma imagem de asset, se disponível:
                // child: Image.asset(
                //   'assets/maquinario.png',
                //   height: 150,
                //   fit: BoxFit.contain,
                // ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Bem-vindo ao Inventário de Maquinário',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Gerencie suas máquinas, marcas e tipos de forma eficiente e organizada. Explore o menu para começar!',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
