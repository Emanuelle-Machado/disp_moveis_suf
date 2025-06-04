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
      id: map['id'] as int,
      idMarca: map['idMarca'] as int,
      idTipo: map['idTipo'] as int,
      anoFabricacao: map['anoFabricacao'] as int,
      contatoProprietario: map['contatoProprietario'] as String,
      dataInclusao: map['dataInclusao'] as String,
      descricao: map['descricao'] as String,
      nomeProprietario: map['nomeProprietario'] as String,
      percentualComissao: (map['percentualComissao'] as num).toDouble(),
      status: map['status'] as String,
      valor: (map['valor'] as num).toDouble(),
      isSincronizado: (map['isSincronizado'] ?? 0) == 1,
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