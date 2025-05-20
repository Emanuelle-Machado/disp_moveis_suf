class Tipo {
  int id;
  String descricao;

  Tipo(this.id, this.descricao);

  Tipo copyWith({int? id, String? descricao}) {
    return Tipo(id ?? this.id, descricao ?? this.descricao);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'descricao': descricao};
  }

  factory Tipo.fromMap(Map<String, dynamic> map) {
    return Tipo(map['id'] as int, map['descricao'] as String);
  }

  factory Tipo.fromJson(Map<String, dynamic> json) {
    return Tipo(json['id'], json['descricao']);
  }

  Map<String, dynamic> toJson() => {'descricao': descricao};

  @override
  String toString() => 'Tipo(id: $id, descricao: $descricao)';

  @override
  bool operator ==(covariant Tipo other) {
    if (identical(this, other)) return true;

    return other.id == id && other.descricao == descricao;
  }

  @override
  int get hashCode => id.hashCode ^ descricao.hashCode;
}
