import 'package:disp_moveis_suf/models/Marca.dart';
import 'package:flutter/material.dart';

class MarcaScreen extends StatefulWidget {
  const MarcaScreen({Key? key}) : super(key: key);

  @override
  State<MarcaScreen> createState() => _MarcaScreenState();
}

class _MarcaScreenState extends State<MarcaScreen> {
  final List<Marca> _marcas = [];
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  Marca? _editingMarca;

  void _showForm([Marca? marca]) {
    if (marca != null) {
      _editingMarca = marca;
      _nomeController.text = marca.nome;
    } else {
      _editingMarca = null;
      _nomeController.clear();
    }
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(marca == null ? 'Cadastrar Marca' : 'Editar Marca'),
            content: Form(
              key: _formKey,
              child: TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Informe o nome'
                            : null,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _nomeController.clear();
                },
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      if (_editingMarca != null) {
                        _editingMarca!.nome = _nomeController.text.trim();
                      } else {
                        _marcas.add(
                          Marca(
                            DateTime.now().millisecondsSinceEpoch,
                            _nomeController.text.trim(),
                          ),
                        );
                      }
                    });
                    Navigator.of(context).pop();
                    _nomeController.clear();
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
    );
  }

  void _confirmRemove(Marca marca) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remover Marca'),
            content: Text('Deseja remover a marca "${marca.nome}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _marcas.remove(marca);
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Remover'),
              ),
            ],
          ),
    );
  }

  Widget _buildMarcaList() {
    if (_marcas.isEmpty) {
      return const Center(child: Text('Nenhuma marca cadastrada.'));
    }
    return ListView.builder(
      itemCount: _marcas.length,
      itemBuilder: (context, index) {
        final marca = _marcas[index];
        return ListTile(
          title: Text(marca.nome),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showForm(marca),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmRemove(marca),
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
          appBar: AppBar(title: const Text('Marcas')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                isHorizontal
                    ? Row(
                      children: [
                        Expanded(child: _buildMarcaList()),
                        const VerticalDivider(),
                        Expanded(
                          child: Center(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Nova Marca'),
                              onPressed: () => _showForm(),
                            ),
                          ),
                        ),
                      ],
                    )
                    : Column(
                      children: [
                        Expanded(child: _buildMarcaList()),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Nova Marca'),
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
