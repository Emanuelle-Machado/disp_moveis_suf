class Marca {
  final int id;
  final String nome;

  Marca({required this.id, required this.nome});

  Map<String, dynamic> toMap() {
    return {'id': id, 'nome': nome};
  }

  factory Marca.fromMap(Map<String, dynamic> map) {
    if (map['id'] == null || map['nome'] == null) {
      throw Exception('Dados inválidos para Marca: id ou nome nulos');
    }
    return Marca(
      id: map['id'] as int,
      nome: map['nome'] as String,
    );
  }

  Map<String, dynamic> toApiMap() {
    return {'nome': nome};
  }
}