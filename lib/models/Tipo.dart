class Tipo {
  final int id;
  final String descricao;

  Tipo({required this.id, required this.descricao});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descricao': descricao,
    };
  }

  factory Tipo.fromMap(Map<String, dynamic> map) {
    return Tipo(
      id: map['id'] as int,
      descricao: map['descricao'] as String,
    );
  }

  Map<String, dynamic> toApiMap() {
    return {
      'descricao': descricao,
    };
  }
}