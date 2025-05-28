class Maquina {
  final int id;
  final int idMarca;
  final int idTipo;
  final int anoFabricacao;
  final String contatoProprietario;
  final String dataInclusao;
  final String descricao;
  final String nomeProprietario;
  final double percentualComissao;
  final String status;
  final double valor;
  final bool isSincronizado;

  Maquina({
    required this.id,
    required this.idMarca,
    required this.idTipo,
    required this.anoFabricacao,
    required this.contatoProprietario,
    required this.dataInclusao,
    required this.descricao,
    required this.nomeProprietario,
    required this.percentualComissao,
    required this.status,
    required this.valor,
    this.isSincronizado = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idMarca': idMarca,
      'idTipo': idTipo,
      'anoFabricacao': anoFabricacao,
      'contatoProprietario': contatoProprietario,
      'dataInclusao': dataInclusao,
      'descricao': descricao,
      'nomeProprietario': nomeProprietario,
      'percentualComissao': percentualComissao,
      'status': status,
      'valor': valor,
      'isSincronizado': isSincronizado ? 1 : 0,
    };
  }

  factory Maquina.fromMap(Map<String, dynamic> map) {
    return Maquina(
      id: map['id'],
      idMarca: map['idMarca'],
      idTipo: map['idTipo'],
      anoFabricacao: map['anoFabricacao'],
      contatoProprietario: map['contatoProprietario'],
      dataInclusao: map['dataInclusao'],
      descricao: map['descricao'],
      nomeProprietario: map['nomeProprietario'],
      percentualComissao: map['percentualComissao'].toDouble(),
      status: map['status'],
      valor: map['valor'].toDouble(),
      isSincronizado: map['isSincronizado'] == 1,
    );
  }

  Map<String, dynamic> toApiMap() {
    return {
      'idMarca': idMarca,
      'idTipo': idTipo,
      'anoFabricacao': anoFabricacao,
      'contatoProprietario': contatoProprietario,
      'dataInclusao': dataInclusao,
      'descricao': descricao,
      'nomeProprietario': nomeProprietario,
      'percentualComissao': percentualComissao,
      'status': status,
      'valor': valor,
    };
  }
}