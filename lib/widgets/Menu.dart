import 'package:disp_moveis_suf/services/DatabaseService.dart';
import 'package:disp_moveis_suf/views/MaquinaScreen.dart';
import 'package:disp_moveis_suf/views/MarcaScreen.dart';
import 'package:disp_moveis_suf/views/TipoScreen.dart';
import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  final VoidCallback onTipo;
  final VoidCallback onMarca;
  final VoidCallback onMaquina;
  final VoidCallback onFetch; // Novo callback para buscar dados
  final VoidCallback onSync; // Callback para sincronizar dados

  const Menu({
    Key? key,
    required this.onTipo,
    required this.onMarca,
    required this.onMaquina,
    required this.onFetch,
    required this.onSync,
  }) : super(key: key);

  // Função para buscar dados do servidor REST
  void _fetchData(BuildContext context) async {
    try {
      // Exemplo de chamada ao ApiService para buscar dados
      await DatabaseService().fetchFromServer(
        context.toString(),
      ); // Ajuste conforme a implementação do ApiService
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Dados buscados com sucesso!')));
      onFetch(); // Chama o callback após buscar
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao buscar dados: $e')));
    }
  }

  // Função para sincronizar dados do banco local com o servidor
  void _syncData(BuildContext context) async {
    try {
      // Exemplo de chamada ao ApiService para sincronizar dados
      await DatabaseService()
          .syncAllResources(); // Ajuste conforme a implementação do ApiService
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dados sincronizados com sucesso!')),
      );
      onSync(); // Chama o callback após sincronizar
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao sincronizar dados: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.menu),
      onSelected: (String value) {
        switch (value) {
          case 'tipo':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TipoScreen()),
            );
            break;
          case 'marca':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MarcaScreen()),
            );
            break;
          case 'maquina':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MaquinaScreen()),
            );
            break;
          case 'fetch':
            _fetchData(context); // Chama a função de buscar dados
            break;
          case 'sync':
            _syncData(context); // Chama a função de sincronizar
            break;
        }
      },
      itemBuilder:
          (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'tipo',
              child: ListTile(
                leading: Icon(Icons.category),
                title: Text('Tipos'),
              ),
            ),
            PopupMenuItem<String>(
              value: 'marca',
              child: ListTile(
                leading: Icon(Icons.branding_watermark),
                title: Text('Marcas'),
              ),
            ),
            PopupMenuItem<String>(
              value: 'maquina',
              child: ListTile(
                leading: Icon(Icons.build),
                title: Text('Máquinas'),
              ),
            ),
            PopupMenuItem<String>(
              value: 'fetch',
              child: ListTile(
                leading: Icon(Icons.download),
                title: Text('Buscar Dados'),
              ),
            ),
            PopupMenuItem<String>(
              value: 'sync',
              child: ListTile(
                leading: Icon(Icons.sync),
                title: Text('Sincronizar Dados'),
              ),
            ),
          ],
    );
  }
}
