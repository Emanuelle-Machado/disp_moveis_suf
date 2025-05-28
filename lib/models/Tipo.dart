class Tipo {
  final int id;
  final String descricao;

  Tipo({required this.id, required this.descricao});

  Map<String, dynamic> toMap() {
    return {'id': id, 'descricao': descricao};
  }

  factory Tipo.fromMap(Map<String, dynamic> map) {
    return Tipo(
      id: map['id'],
      descricao: map['descricao'],
    );
  }

  Map<String, dynamic> toApiMap() {
    return {'descricao': descricao}; // Não envia ID no POST
  }
}