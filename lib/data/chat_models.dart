class Mensagem {
  final int id;
  final int conversaId;
  final int remetenteId;
  final int destinatarioId;
  final String texto;
  final DateTime dataHora;
  final bool lida;

  Mensagem({
    required this.id,
    required this.conversaId,
    required this.remetenteId,
    required this.destinatarioId,
    required this.texto,
    required this.dataHora,
    this.lida = false,
  });
}

class Conversa {
  final int id;
  final int usuario1Id;
  final int usuario2Id;
  final String usuario1Nome;
  String usuario2Nome;
  final List<Mensagem> mensagens;
  final bool novaMensagem;

  Conversa({
    required this.id,
    required this.usuario1Id,
    required this.usuario2Id,
    required this.usuario1Nome,
    required this.usuario2Nome,
    this.mensagens = const [],
    this.novaMensagem = false,
  });
}
