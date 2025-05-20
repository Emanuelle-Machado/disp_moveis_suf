import 'package:disp_moveis_suf/models/Tipo.dart';
import 'package:flutter/material.dart';

class TipoScreen extends StatefulWidget {
  const TipoScreen({Key? key}) : super(key: key);

  @override
  State<TipoScreen> createState() => _TipoScreenState();
}

class _TipoScreenState extends State<TipoScreen> {
  final List<Tipo> _tipos = [];
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descricaoController = TextEditingController();
  Tipo? _editingTipo;

  void _showForm([Tipo? tipo]) {
    if (tipo != null) {
      _editingTipo = tipo;
      _descricaoController.text = tipo.descricao;
    } else {
      _editingTipo = null;
      _descricaoController.clear();
    }
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(tipo == null ? 'Cadastrar tipo' : 'Editar tipo'),
            content: Form(
              key: _formKey,
              child: TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Informe a descricao'
                            : null,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _descricaoController.clear();
                },
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      if (_editingTipo != null) {
                        _editingTipo!.descricao =
                            _descricaoController.text.trim();
                      } else {
                        _tipos.add(
                          Tipo(
                            DateTime.now().millisecondsSinceEpoch,
                            _descricaoController.text.trim(),
                          ),
                        );
                      }
                    });
                    Navigator.of(context).pop();
                    _descricaoController.clear();
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
    );
  }

  void _confirmRemove(Tipo tipo) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remover tipo'),
            content: Text('Deseja remover a tipo "${tipo.descricao}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _tipos.remove(tipo);
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Remover'),
              ),
            ],
          ),
    );
  }

  Widget _buildTipoList() {
    if (_tipos.isEmpty) {
      return const Center(child: Text('Nenhum tipo cadastrado.'));
    }
    return ListView.builder(
      itemCount: _tipos.length,
      itemBuilder: (context, index) {
        final tipo = _tipos[index];
        return ListTile(
          title: Text(tipo.descricao),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showForm(tipo),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmRemove(tipo),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isHorizontal = orientation == Orientation.landscape;
        return Scaffold(
          appBar: AppBar(title: const Text('tipos')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                isHorizontal
                    ? Row(
                      children: [
                        Expanded(child: _buildTipoList()),
                        const VerticalDivider(),
                        Expanded(
                          child: Center(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Novo tipo'),
                              onPressed: () => _showForm(),
                            ),
                          ),
                        ),
                      ],
                    )
                    : Column(
                      children: [
                        Expanded(child: _buildTipoList()),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Novo tipo'),
                            onPressed: () => _showForm(),
                          ),
                        ),
                      ],
                    ),
          ),
        );
      },
    );
  }
}
