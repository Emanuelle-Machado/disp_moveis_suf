class Marca {
  final int id;
  final String nome;

  Marca({required this.id, required this.nome});

  Map<String, dynamic> toMap() {
    return {'id': id, 'nome': nome};
  }

  factory Marca.fromMap(Map<String, dynamic> map) {
    return Marca(
      id: map['id'],
      nome: map['nome'],
    );
  }

  Map<String, dynamic> toApiMap() {
    return {'nome': nome}; // Não envia ID no POST
  }
}