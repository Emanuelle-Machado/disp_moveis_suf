import 'package:disp_moveis_suf/models/Tipo.dart';
import 'package:disp_moveis_suf/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';


class TipoListScreen extends StatefulWidget {
  const TipoListScreen({super.key});

  @override
  _TipoListScreenState createState() => _TipoListScreenState();
}

class _TipoListScreenState extends State<TipoListScreen> {
  final dbHelper = DatabaseHelper.instance;
  List<Tipo> tipos = [];

  @override
  void initState() {
    super.initState();
    _carregarTipos();
  }

  Future<void> _carregarTipos() async {
    final tiposCarregados = await dbHelper.obterTipos();
    setState(() {
      tipos = tiposCarregados;
    });
  }

  Future<void> _mostrarDialogoTipo({Tipo? tipo}) async {
    final controller = TextEditingController(text: tipo?.descricao ?? '');
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tipo == null ? 'Novo Tipo' : 'Editar Tipo'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Descrição'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final novoTipo = Tipo(
                  id: tipo?.id ?? int.parse(const Uuid().v4().replaceAll('-', '').substring(0, 8), radix: 16),
                  descricao: controller.text,
                );
                if (tipo == null) {
                  await dbHelper.inserirTipo(novoTipo);
                } else {
                  await dbHelper.atualizarTipo(novoTipo);
                }
                await _carregarTipos();
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _excluirTipo(int id) async {
    try {
      await dbHelper.excluirTipo(id);
      await _carregarTipos();
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
        title: const Text('Tipos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _mostrarDialogoTipo(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: tipos.length,
        itemBuilder: (context, index) {
          final tipo = tipos[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(tipo.descricao),
              onTap: () => _mostrarDialogoTipo(tipo: tipo),
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Excluir Tipo'),
                    content: Text('Deseja excluir o tipo "${tipo.descricao}"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          _excluirTipo(tipo.id);
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