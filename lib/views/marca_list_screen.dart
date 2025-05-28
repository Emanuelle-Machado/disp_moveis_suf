import 'package:disp_moveis_suf/models/Marca.dart';
import 'package:disp_moveis_suf/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class MarcaListScreen extends StatefulWidget {
  const MarcaListScreen({super.key});

  @override
  _MarcaListScreenState createState() => _MarcaListScreenState();
}

class _MarcaListScreenState extends State<MarcaListScreen> {
  final dbHelper = DatabaseHelper.instance;
  List<Marca> marcas = [];

  @override
  void initState() {
    super.initState();
    _carregarMarcas();
  }

  Future<void> _carregarMarcas() async {
    final marcasCarregadas = await dbHelper.obterMarcas();
    setState(() {
      marcas = marcasCarregadas;
    });
  }

  Future<void> _mostrarDialogoMarca({Marca? marca}) async {
    final controller = TextEditingController(text: marca?.nome ?? '');
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(marca == null ? 'Nova Marca' : 'Editar Marca'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nome'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final novaMarca = Marca(
                  id: marca?.id ?? int.parse(const Uuid().v4().replaceAll('-', '').substring(0, 8), radix: 16),
                  nome: controller.text,
                );
                if (marca == null) {
                  await dbHelper.inserirMarca(novaMarca);
                } else {
                  await dbHelper.atualizarMarca(novaMarca);
                }
                await _carregarMarcas();
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _excluirMarca(int id) async {
    try {
      await dbHelper.excluirMarca(id);
      await _carregarMarcas();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marcas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _mostrarDialogoMarca(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: marcas.length,
        itemBuilder: (context, index) {
          final marca = marcas[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(marca.nome),
              onTap: () => _mostrarDialogoMarca(marca: marca),
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Excluir Marca'),
                    content: Text('Deseja excluir a marca "${marca.nome}"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          _excluirMarca(marca.id);
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
    );
  }
}