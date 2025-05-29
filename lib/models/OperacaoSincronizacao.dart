class OperacaoSincronizacao {
  final int? id;
  final String recurso;
  final int recursoId;
  final String operacao;
  final String dados;

  OperacaoSincronizacao({
    this.id,
    required this.recurso,
    required this.recursoId,
    required this.operacao,
    required this.dados,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recurso': recurso,
      'recursoId': recursoId,
      'operacao': operacao,
      'dados': dados,
    };
  }

  factory OperacaoSincronizacao.fromMap(Map<String, dynamic> map) {
    return OperacaoSincronizacao(
      id: map['id'] as int?,
      recurso: map['recurso'] as String,
      recursoId: map['recursoId'] as int,
      operacao: map['operacao'] as String,
      dados: map['dados'] as String,
    );
  }
}