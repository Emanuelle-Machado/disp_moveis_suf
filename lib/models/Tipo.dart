class Tipo {
  final int id;
  final String descricao;

  Tipo({required this.id, required this.descricao});

  Map<String, dynamic> toMap() {
    return {'id': id, 'descricao': descricao};
  }

  factory Tipo.fromMap(Map<String, dynamic> map) {
    if (map['id'] == null || map['descricao'] == null) {
      throw Exception('Dados inválidos para Tipo: id ou descricao nulos');
    }
    return Tipo(
      id: map['id'] as int,
      descricao: map['descricao'] as String,
    );
  }

  Map<String, dynamic> toApiMap() {
    return {'descricao': descricao};
  }
}