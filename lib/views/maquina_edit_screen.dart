import 'package:disp_moveis_suf/models/Maquina.dart';
import 'package:disp_moveis_suf/models/Marca.dart';
import 'package:disp_moveis_suf/models/Tipo.dart';
import 'package:disp_moveis_suf/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';


class MaquinaEditScreen extends StatefulWidget {
  final Maquina? maquina;

  const MaquinaEditScreen({super.key, this.maquina});

  @override
  _MaquinaEditScreenState createState() => _MaquinaEditScreenState();
}

class _MaquinaEditScreenState extends State<MaquinaEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final dbHelper = DatabaseHelper.instance;
  late int idMarca;
  late int idTipo;
  late int anoFabricacao;
  late String contatoProprietario;
  late String dataInclusao;
  late String descricao;
  late String nomeProprietario;
  late double percentualComissao;
  late String status;
  late double valor;
  List<Tipo> tipos = [];
  List<Marca> marcas = [];

  @override
  void initState() {
    super.initState();
    idMarca = widget.maquina?.idMarca ?? 0;
    idTipo = widget.maquina?.idTipo ?? 0;
    anoFabricacao = widget.maquina?.anoFabricacao ?? DateTime.now().year;
    contatoProprietario = widget.maquina?.contatoProprietario ?? '';
    dataInclusao = widget.maquina?.dataInclusao ?? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    descricao = widget.maquina?.descricao ?? '';
    nomeProprietario = widget.maquina?.nomeProprietario ?? '';
    percentualComissao = widget.maquina?.percentualComissao ?? 0.0;
    status = widget.maquina?.status ?? 'D';
    valor = widget.maquina?.valor ?? 0.0;
    _carregarTiposEMarcas();
  }

  Future<void> _carregarTiposEMarcas() async {
    final tiposCarregados = await dbHelper.obterTipos();
    final marcasCarregadas = await dbHelper.obterMarcas();
    setState(() {
      tipos = tiposCarregados;
      marcas = marcasCarregadas;
      if (idMarca == 0 && marcas.isNotEmpty) idMarca = marcas.first.id;
      if (idTipo == 0 && tipos.isNotEmpty) idTipo = tipos.first.id;
    });
  }

  Future<void> _salvarMaquina() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final maquina = Maquina(
        id: widget.maquina?.id ?? int.parse(const Uuid().v4().replaceAll('-', '').substring(0, 8), radix: 16),
        idMarca: idMarca,
        idTipo: idTipo,
        anoFabricacao: anoFabricacao,
        contatoProprietario: contatoProprietario,
        dataInclusao: dataInclusao,
        descricao: descricao,
        nomeProprietario: nomeProprietario,
        percentualComissao: percentualComissao,
        status: status,
        valor: valor,
      );
      if (widget.maquina == null) {
        await dbHelper.inserirMaquina(maquina);
      } else {
        await dbHelper.atualizarMaquina(maquina);
      }
      if (mounted) Navigator.pop(context);
    }
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
                DropdownButtonFormField<int>(
                  value: idTipo,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: tipos.map((tipo) {
                    return DropdownMenuItem(
                      value: tipo.id,
                      child: Text(tipo.descricao),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => idTipo = value!),
                  validator: (value) => value == null ? 'Selecione um tipo' : null,
                ),
                DropdownButtonFormField<int>(
                  value: idMarca,
                  decoration: const InputDecoration(labelText: 'Marca'),
                  items: marcas.map((marca) {
                    return DropdownMenuItem(
                      value: marca.id,
                      child: Text(marca.nome),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => idMarca = value!),
                  validator: (value) => value == null ? 'Selecione uma marca' : null,
                ),
                TextFormField(
                  initialValue: descricao,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                  validator: (value) => value!.isEmpty ? 'Descrição é obrigatória' : null,
                  onSaved: (value) => descricao = value!,
                ),
                TextFormField(
                  initialValue: anoFabricacao.toString(),
                  decoration: const InputDecoration(labelText: 'Ano de Fabricação'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Ano é obrigatório';
                    final ano = int.tryParse(value);
                    if (ano == null || ano < 1900 || ano > DateTime.now().year) {
                      return 'Ano inválido';
                    }
                    return null;
                  },
                  onSaved: (value) => anoFabricacao = int.parse(value!),
                ),
                TextFormField(
                  initialValue: contatoProprietario,
                  decoration: const InputDecoration(labelText: 'Contato do Proprietário'),
                  validator: (value) => value!.isEmpty ? 'Contato é obrigatório' : null,
                  onSaved: (value) => contatoProprietario = value!,
                ),
                TextFormField(
                  initialValue: dataInclusao,
                  decoration: const InputDecoration(labelText: 'Data de Inclusão (yyyy-MM-dd HH:mm)'),
                  validator: (value) {
                    try {
                      DateFormat('yyyy-MM-dd HH:mm').parse(value!);
                      return null;
                    } catch (e) {
                      return 'Data inválida (use yyyy-MM-dd HH:mm)';
                    }
                  },
                  onSaved: (value) => dataInclusao = value!,
                ),
                TextFormField(
                  initialValue: nomeProprietario,
                  decoration: const InputDecoration(labelText: 'Nome do Proprietário'),
                  validator: (value) => value!.isEmpty ? 'Nome é obrigatório' : null,
                  onSaved: (value) => nomeProprietario = value!,
                ),
                TextFormField(
                  initialValue: percentualComissao.toString(),
                  decoration: const InputDecoration(labelText: 'Percentual de Comissão'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final percentual = double.tryParse(value!);
                    if (percentual == null || percentual < 0) return 'Percentual inválido';
                    return null;
                  },
                  onSaved: (value) => percentualComissao = double.parse(value!),
                ),
                TextFormField(
                  initialValue: valor.toString(),
                  decoration: const InputDecoration(labelText: 'Valor'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final val = double.tryParse(value!);
                    if (val == null || val < 0) return 'Valor inválido';
                    return null;
                  },
                  onSaved: (value) => valor = double.parse(value!),
                ),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'D', child: Text('Disponível')),
                    DropdownMenuItem(value: 'I', child: Text('Indisponível')),
                  ],
                  onChanged: (value) => setState(() => status = value!),
                  validator: (value) => value == null ? 'Selecione um status' : null,
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