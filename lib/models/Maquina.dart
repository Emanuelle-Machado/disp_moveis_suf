class Maquina {
  int id;
  String idTipo;
  String idMarca;
  String descricao;
  double valor;
  String nomeProprietario;
  String contatoProprietario;
  DateTime dataFabricacao;
  DateTime dataInclusao;
  double percentualComissao;
  String status;

  Maquina({
    required this.id,
    required this.idTipo,
    required this.idMarca,
    required this.descricao,
    required this.valor,
    required this.nomeProprietario,
    required this.contatoProprietario,
    required this.dataFabricacao,
    required this.dataInclusao,
    required this.percentualComissao,
    required this.status,
  });

  Maquina copyWith({
    int? id,
    String? idTipo,
    String? idMarca,
    String? descricao,
    double? valor,
    String? nomeProprietario,
    String? contatoProprietario,
    DateTime? dataFabricacao,
    DateTime? dataInclusao,
    double? percentualComissao,
    String? status,
  }) {
    return Maquina(
      id: id ?? this.id,
      idTipo: idTipo ?? this.idTipo,
      idMarca: idMarca ?? this.idMarca,
      descricao: descricao ?? this.descricao,
      valor: valor ?? this.valor,
      nomeProprietario: nomeProprietario ?? this.nomeProprietario,
      contatoProprietario: contatoProprietario ?? this.contatoProprietario,
      dataFabricacao: dataFabricacao ?? this.dataFabricacao,
      dataInclusao: dataInclusao ?? this.dataInclusao,
      percentualComissao: percentualComissao ?? this.percentualComissao,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'idTipo': idTipo,
      'idMarca': idMarca,
      'descricao': descricao,
      'valor': valor,
      'nomeProprietario': nomeProprietario,
      'contatoProprietario': contatoProprietario,
      'dataFabricacao': dataFabricacao.millisecondsSinceEpoch,
      'dataInclusao': dataInclusao.millisecondsSinceEpoch,
      'percentualComissao': percentualComissao,
      'status': status,
    };
  }

  factory Maquina.fromMap(Map<String, dynamic> map) {
    return Maquina(
      id: map['id'] as int,
      idTipo: map['idTipo'] as String,
      idMarca: map['idMarca'] as String,
      descricao: map['descricao'] as String,
      valor: map['valor'] as double,
      nomeProprietario: map['nomeProprietario'] as String,
      contatoProprietario: map['contatoProprietario'] as String,
      dataFabricacao: DateTime.fromMillisecondsSinceEpoch(
        map['dataFabricacao'] as int,
      ),
      dataInclusao: DateTime.fromMillisecondsSinceEpoch(
        map['dataInclusao'] as int,
      ),
      percentualComissao: map['percentualComissao'] as double,
      status: map['status'] as String,
    );
  }

  factory Maquina.fromJson(Map<String, dynamic> json) {
    return Maquina(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      idMarca: json['idMarca'],
      idTipo: json['idTipo'],
      descricao: json['descricao'],
      valor: (json['valor'] as num).toDouble(),
      nomeProprietario: json['nomeProprietario'],
      contatoProprietario: json['contatoProprietario'],
      dataFabricacao: DateTime.parse(json['dataFabricacao']),
      dataInclusao: DateTime.parse(json['dataInclusao']),
      percentualComissao: (json['percentualComissao'] as num).toDouble(),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'idMarca': idMarca,
    'idTipo': idTipo,
    'descricao': descricao,
    'valor': valor,
    'nomeProprietario': nomeProprietario,
    'contatoProprietario': contatoProprietario,
    'dataFabricacao': dataFabricacao.toIso8601String(),
    'dataInclusao': dataInclusao.toIso8601String(),
    'percentualComissao': percentualComissao,
    'status': status,
  };

  @override
  String toString() {
    return 'Maquina(id: $id, idTipo: $idTipo, idMarca: $idMarca, descricao: $descricao, valor: $valor, nomeProprietario: $nomeProprietario, contatoProprietario: $contatoProprietario, dataFabricacao: $dataFabricacao, dataInclusao: $dataInclusao, percentualComissao: $percentualComissao, status: $status)';
  }

  @override
  bool operator ==(covariant Maquina other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.idTipo == idTipo &&
        other.idMarca == idMarca &&
        other.descricao == descricao &&
        other.valor == valor &&
        other.nomeProprietario == nomeProprietario &&
        other.contatoProprietario == contatoProprietario &&
        other.dataFabricacao == dataFabricacao &&
        other.dataInclusao == dataInclusao &&
        other.percentualComissao == percentualComissao &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        idTipo.hashCode ^
        idMarca.hashCode ^
        descricao.hashCode ^
        valor.hashCode ^
        nomeProprietario.hashCode ^
        contatoProprietario.hashCode ^
        dataFabricacao.hashCode ^
        dataInclusao.hashCode ^
        percentualComissao.hashCode ^
        status.hashCode;
  }
}
