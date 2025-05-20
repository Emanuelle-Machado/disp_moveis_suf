class Marca {
  int id;
  String nome;

  Marca(this.id, this.nome);

  Marca copyWith({int? id, String? nome}) {
    return Marca(id ?? this.id, nome ?? this.nome);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'nome': nome};
  }

  factory Marca.fromMap(Map<String, dynamic> map) {
    return Marca(map['id'] as int, map['nome'] as String);
  }
  factory Marca.fromJson(Map<String, dynamic> json) {
    return Marca(json['id'] as int, json['nome'] as String);
  }

  Map<String, dynamic> toJson() => {'nome': nome};

  @override
  String toString() => 'Marca(id: $id, nome: $nome)';

  @override
  bool operator ==(covariant Marca other) {
    if (identical(this, other)) return true;

    return other.id == id && other.nome == nome;
  }

  @override
  int get hashCode => id.hashCode ^ nome.hashCode;
}
