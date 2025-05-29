import 'package:disp_moveis_suf/models/Maquina.dart';
import 'package:disp_moveis_suf/models/Marca.dart';
import 'package:disp_moveis_suf/models/Tipo.dart';
import 'package:disp_moveis_suf/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MaquinaEditScreen extends StatefulWidget {
  final Maquina? maquina;

  const MaquinaEditScreen({super.key, this.maquina});

  @override
  _MaquinaEditScreenState createState() => _MaquinaEditScreenState();
}

class _MaquinaEditScreenState extends State<MaquinaEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final dbHelper = DatabaseHelper.instance;
  late TextEditingController _descricaoController;
  late TextEditingController _nomeProprietarioController;
  late TextEditingController _contatoProprietarioController;
  late TextEditingController _anoFabricacaoController;
  late TextEditingController _valorController;
  late TextEditingController _percentualComissaoController;
  String? _status;
  int? _idMarca;
  int? _idTipo;
  List<Marca> marcas = [];
  List<Tipo> tipos = [];

  @override
  void initState() {
    super.initState();
    _descricaoController = TextEditingController(text: widget.maquina?.descricao ?? '');
    _nomeProprietarioController = TextEditingController(text: widget.maquina?.nomeProprietario ?? '');
    _contatoProprietarioController = TextEditingController(text: widget.maquina?.contatoProprietario ?? '');
    _anoFabricacaoController = TextEditingController(text: widget.maquina?.anoFabricacao.toString() ?? '');
    _valorController = TextEditingController(text: widget.maquina?.valor.toString() ?? '');
    _percentualComissaoController = TextEditingController(text: widget.maquina?.percentualComissao.toString() ?? '');
    _status = widget.maquina?.status ?? 'D';
    _idMarca = widget.maquina?.idMarca;
    _idTipo = widget.maquina?.idTipo;
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final marcasCarregadas = await dbHelper.obterMarcas();
    final tiposCarregados = await dbHelper.obterTipos();
    setState(() {
      marcas = marcasCarregadas;
      tipos = tiposCarregados;
      if (_idMarca == null && marcas.isNotEmpty) _idMarca = marcas.first.id;
      if (_idTipo == null && tipos.isNotEmpty) _idTipo = tipos.first.id;
    });
  }

  Future<void> _salvarMaquina() async {
    if (_formKey.currentState!.validate()) {
      final db = await dbHelper.database;
      final id = widget.maquina?.id ?? (await db.rawQuery('SELECT COALESCE(MAX(id), 0) + 1 as nextId FROM maquinas')).first['nextId'] as int;
      final maquina = Maquina(
        id: id,
        idMarca: _idMarca!,
        idTipo: _idTipo!,
        anoFabricacao: int.parse(_anoFabricacaoController.text),
        contatoProprietario: _contatoProprietarioController.text,
        dataInclusao: widget.maquina?.dataInclusao ?? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
        descricao: _descricaoController.text,
        nomeProprietario: _nomeProprietarioController.text,
        percentualComissao: double.parse(_percentualComissaoController.text),
        status: _status!,
        valor: double.parse(_valorController.text),
      );

      if (widget.maquina == null) {
        await dbHelper.inserirMaquina(maquina);
      } else {
        await dbHelper.atualizarMaquina(maquina);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _nomeProprietarioController.dispose();
    _contatoProprietarioController.dispose();
    _anoFabricacaoController.dispose();
    _valorController.dispose();
    _percentualComissaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.maquina == null ? 'Nova Máquina' : 'Editar Máquina'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                  validator: (value) => value!.isEmpty ? 'Informe a descrição' : null,
                ),
                DropdownButtonFormField<int>(
                  value: _idMarca,
                  decoration: const InputDecoration(labelText: 'Marca'),
                  items: marcas.map((marca) {
                    return DropdownMenuItem(
                      value: marca.id,
                      child: Text(marca.nome),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _idMarca = value),
                  validator: (value) => value == null ? 'Selecione a marca' : null,
                ),
                DropdownButtonFormField<int>(
                  value: _idTipo,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: tipos.map((tipo) {
                    return DropdownMenuItem(
                      value: tipo.id,
                      child: Text(tipo.descricao),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _idTipo = value),
                  validator: (value) => value == null ? 'Selecione o tipo' : null,
                ),
                TextFormField(
                  controller: _anoFabricacaoController,
                  decoration: const InputDecoration(labelText: 'Ano de Fabricação'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Informe o ano';
                    if (int.tryParse(value) == null) return 'Ano inválido';
                    return null;
                  },
                ),
                TextFormField(
                  controller: _nomeProprietarioController,
                  decoration: const InputDecoration(labelText: 'Nome do Proprietário'),
                  validator: (value) => value!.isEmpty ? 'Informe o nome' : null,
                ),
                TextFormField(
                  controller: _contatoProprietarioController,
                  decoration: const InputDecoration(labelText: 'Contato do Proprietário'),
                  validator: (value) => value!.isEmpty ? 'Informe o contato' : null,
                ),
                TextFormField(
                  controller: _valorController,
                  decoration: const InputDecoration(labelText: 'Valor'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value!.isEmpty) return 'Informe o valor';
                    if (double.tryParse(value) == null) return 'Valor inválido';
                    return null;
                  },
                ),
                TextFormField(
                  controller: _percentualComissaoController,
                  decoration: const InputDecoration(labelText: 'Percentual de Comissão'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value!.isEmpty) return 'Informe o percentual';
                    if (double.tryParse(value) == null) return 'Percentual inválido';
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'D', child: Text('Disponível')),
                    DropdownMenuItem(value: 'N', child: Text('Em Negociação')),
                    DropdownMenuItem(value: 'R', child: Text('Reservada')),
                    DropdownMenuItem(value: 'V', child: Text('Vendida')),
                  ],
                  onChanged: (value) => setState(() => _status = value),
                  validator: (value) => value == null ? 'Selecione o status' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _salvarMaquina,
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}