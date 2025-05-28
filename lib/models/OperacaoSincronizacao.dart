class OperacaoSincronizacao {
  final int? id;
  final String recurso; // 'tipo', 'marca', 'maquina'
  final int recursoId;
  final String operacao; // 'inserir', 'atualizar', 'excluir'
  final String dados; // JSON dos dados

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
      id: map['id'],
      recurso: map['recurso'],
      recursoId: map['recursoId'],
      operacao: map['operacao'],
      dados: map['dados'],
    );
  }
}