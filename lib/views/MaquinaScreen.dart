import 'package:disp_moveis_suf/models/Maquina.dart';
import 'package:disp_moveis_suf/services/api_service.dart';
import 'package:flutter/material.dart';

class MaquinaScreen extends StatefulWidget {
  const MaquinaScreen({Key? key}) : super(key: key);

  @override
  State<MaquinaScreen> createState() => _MaquinaScreenState();
}

class _MaquinaScreenState extends State<MaquinaScreen> {
  final List<Maquina> _maquinas = [];
  final ApiService api = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchMaquinas();
  }

  Future<void> _fetchMaquinas() async {
    // Substitua pelo seu DatabaseService real
    final maquinas = await api.getMaquinas();
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _descricaoController,
                    decoration: const InputDecoration(labelText: 'Descrição'),
                    validator:
                        (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Informe a descrição'
                                : null,
                  ),
                  TextFormField(
                    controller: _idTipoController,
                    decoration: const InputDecoration(labelText: 'ID Tipo'),
                    validator:
                        (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Informe o ID Tipo'
                                : null,
                  ),
                  TextFormField(
                    controller: _idMarcaController,
                    decoration: const InputDecoration(labelText: 'ID Marca'),
                    validator:
                        (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Informe o ID Marca'
                                : null,
                  ),
                  TextFormField(
                    controller: _valorController,
                    decoration: const InputDecoration(labelText: 'Valor'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o valor';
                      }
                      final parsedValue = double.tryParse(value);
                      if (parsedValue == null) {
                        return 'Valor inválido';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _nomeProprietarioController,
                    decoration: const InputDecoration(
                      labelText: 'Nome Proprietário',
                    ),
                    validator:
                        (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Informe o nome do proprietário'
                                : null,
                  ),
                  TextFormField(
                    controller: _contatoProprietarioController,
                    decoration: const InputDecoration(
                      labelText: 'Contato Proprietário',
                    ),
                    validator:
                        (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Informe o contato do proprietário'
                                : null,
                  ),
                  TextFormField(
                    controller: _dataFabricacaoController,
                    decoration: const InputDecoration(
                      labelText: 'Data Fabricação',
                    ),
                    validator:
                        (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Informe a data de fabricação'
                                : null,
                  ),
                  TextFormField(
                    controller: _dataInclusaoController,
                    decoration: const InputDecoration(
                      labelText: 'Data Inclusão',
                    ),
                    validator:
                        (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Informe a data de inclusão'
                                : null,
                  ),
                  TextFormField(
                    controller: _percentualComissaoController,
                    decoration: const InputDecoration(
                      labelText: 'Percentual Comissão',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o percentual de comissão';
                      }
                      final parsedValue = double.tryParse(value);
                      if (parsedValue == null) {
                        return 'Percentual inválido';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _statusController,
                    decoration: const InputDecoration(labelText: 'Status'),
                    validator:
                        (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Informe o status'
                                : null,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _descricaoController.clear();
                  _idTipoController.clear();
                  _idMarcaController.clear();
                  _valorController.clear();
                  _nomeProprietarioController.clear();
                  _contatoProprietarioController.clear();
                  _dataFabricacaoController.clear();
                  _dataInclusaoController.clear();
                  _percentualComissaoController.clear();
                  _statusController.clear();
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
                            idTipo: _idTipoController.text.trim(),
                            idMarca: _idMarcaController.text.trim(),
                            descricao: _descricaoController.text.trim(),
                            valor:
                                double.tryParse(_valorController.text.trim()) ??
                                0.0,
                            nomeProprietario:
                                _nomeProprietarioController.text.trim(),
                            contatoProprietario:
                                _contatoProprietarioController.text.trim(),
                            dataFabricacao:
                                DateTime.tryParse(
                                  _dataFabricacaoController.text.trim(),
                                ) ??
                                DateTime.now(),
                            dataInclusao:
                                DateTime.tryParse(
                                  _dataInclusaoController.text.trim(),
                                ) ??
                                DateTime.now(),
                            percentualComissao:
                                double.tryParse(
                                  _percentualComissaoController.text.trim(),
                                ) ??
                                0.0,
                            status: _statusController.text.trim(),
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
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(maquina.descricao),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID Tipo: ${maquina.idTipo}'),
                Text('ID Marca: ${maquina.idMarca}'),
                Text('Valor: R\$ ${maquina.valor.toStringAsFixed(2)}'),
                Text('Nome Proprietário: ${maquina.nomeProprietario}'),
                Text('Contato Proprietário: ${maquina.contatoProprietario}'),
                Text(
                  'Data Fabricação: ${maquina.dataFabricacao.toString().split(' ').first}',
                ),
                Text(
                  'Data Inclusão: ${maquina.dataInclusao.toString().split(' ').first}',
                ),
                Text(
                  'Percentual Comissão: ${maquina.percentualComissao.toStringAsFixed(2)}%',
                ),
                Text('Status: ${maquina.status}'),
              ],
            ),
            isThreeLine: true,
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
