import 'package:disp_moveis_suf/models/Maquina.dart';
import 'package:disp_moveis_suf/services/DatabaseService.dart';
import 'package:flutter/material.dart';

class MaquinaScreen extends StatefulWidget {
  const MaquinaScreen({Key? key}) : super(key: key);

  @override
  State<MaquinaScreen> createState() => _MaquinaScreenState();
}

class _MaquinaScreenState extends State<MaquinaScreen> {
  final List<Maquina> _maquinas = [];

  @override
  void initState() {
    super.initState();
    _fetchMaquinas();
  }

  Future<void> _fetchMaquinas() async {
    // Substitua pelo seu DatabaseService real
    final maquinas = await DatabaseService().getAll('maquinas');
    setState(() {
      _maquinas.clear();
      _maquinas.addAll(maquinas.cast<Maquina>());
    });
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _idTipoController = TextEditingController();
  final TextEditingController _idMarcaController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _nomeProprietarioController =
      TextEditingController();
  final TextEditingController _contatoProprietarioController =
      TextEditingController();
  final TextEditingController _dataFabricacaoController =
      TextEditingController();
  final TextEditingController _dataInclusaoController = TextEditingController();
  final TextEditingController _percentualComissaoController =
      TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  Maquina? _editingMaquina;

  void _showForm([Maquina? maquina]) {
    if (maquina != null) {
      _editingMaquina = maquina;
      _descricaoController.text = maquina.descricao;
      _idTipoController.text = maquina.idTipo;
      _idMarcaController.text = maquina.idMarca;
      _valorController.text = maquina.valor.toString();
      _nomeProprietarioController.text = maquina.nomeProprietario;
      _contatoProprietarioController.text = maquina.contatoProprietario;
      _dataFabricacaoController.text = maquina.dataFabricacao.toString();
      _dataInclusaoController.text = maquina.dataInclusao.toString();
      _percentualComissaoController.text =
          maquina.percentualComissao.toString();
      _statusController.text = maquina.status;
    } else {
      _editingMaquina = null;
      _descricaoController.clear();
    }
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              maquina == null ? 'Cadastrar Máquina' : 'Editar Máquina',
            ),
            content: Form(
              key: _formKey,
              child: TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator:
                    (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Informe a descrição'
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
                      if (_editingMaquina != null) {
                        _editingMaquina!.descricao =
                            _descricaoController.text.trim();
                      } else {
                        _maquinas.add(
                          Maquina(
                            id: DateTime.now().millisecondsSinceEpoch,
                            idTipo: '0', // TODO: Replace with actual idTipo
                            idMarca: '0', // TODO: Replace with actual idMarca
                            descricao: _descricaoController.text.trim(),
                            valor: 0.0, // TODO: Replace with actual valor
                            nomeProprietario:
                                '', // TODO: Replace with actual nomeProprietario
                            contatoProprietario:
                                '', // TODO: Replace with actual contatoProprietario
                            dataFabricacao:
                                DateTime.now(), // TODO: Replace with actual dataFabricacao
                            dataInclusao: DateTime.now(),
                            percentualComissao:
                                0.0, // TODO: Replace with actual percentualComissao
                            status: '', // TODO: Replace with actual status
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

  void _confirmRemove(Maquina maquina) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remover Máquina'),
            content: Text('Deseja remover a máquina "${maquina.descricao}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _maquinas.remove(maquina);
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Remover'),
              ),
            ],
          ),
    );
  }

  Widget _buildMaquinaList() {
    if (_maquinas.isEmpty) {
      return const Center(child: Text('Nenhuma máquina cadastrada.'));
    }
    return ListView.builder(
      itemCount: _maquinas.length,
      itemBuilder: (context, index) {
        final maquina = _maquinas[index];
        return ListTile(
          title: Text(maquina.descricao),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showForm(maquina),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmRemove(maquina),
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
                        Expanded(child: _buildMaquinaList()),
                        const VerticalDivider(),
                        Expanded(
                          child: Center(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Nova Máquina'),
                              onPressed: () => _showForm(),
                            ),
                          ),
                        ),
                      ],
                    )
                    : Column(
                      children: [
                        Expanded(child: _buildMaquinaList()),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Nova Máquina'),
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
