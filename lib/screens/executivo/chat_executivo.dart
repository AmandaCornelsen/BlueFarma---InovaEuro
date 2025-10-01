import 'package:flutter/material.dart';
import '../../database_help.dart';
import '../../data/chat_models.dart';

class ChatExecutivo extends StatefulWidget {
  final int executivoId;
  final String executivoNome;
  const ChatExecutivo({super.key, required this.executivoId, required this.executivoNome});

  @override
  State<ChatExecutivo> createState() => _ChatExecutivoState();
}

class _ChatExecutivoState extends State<ChatExecutivo> {
  List<Conversa> conversas = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarConversas();
  }

  Future<void> _carregarConversas() async {
    final db = DatabaseHelper.instance;
    final convs = await db.listConversationsForUser(widget.executivoId, 'Executivo');
    List<Conversa> lista = [];
    for (var conv in convs) {
      final msgs = await db.getMessages(conv['id'] as int);
      lista.add(
        Conversa(
          id: conv['id'] as int,
          usuario1Id: conv['executive_id'] as int,
          usuario2Id: conv['empreendedor_id'] as int,
          usuario1Nome: widget.executivoNome,
          usuario2Nome: '', // Nome do empreendedor será buscado abaixo
          mensagens: msgs.map((m) => Mensagem(
            id: m['id'] as int,
            conversaId: m['conversation_id'] as int,
            remetenteId: m['sender_id'] as int,
            destinatarioId: m['sender_id'] as int == widget.executivoId ? conv['empreendedor_id'] as int : widget.executivoId,
            texto: m['message'] as String,
            dataHora: DateTime.parse(m['created_at'] as String),
            lida: true,
          )).toList(),
          novaMensagem: false,
        ),
      );
    }
    // Buscar nomes dos empreendedores
    for (var c in lista) {
      final emp = await db.database.then((db) => db.query('users', where: 'id = ?', whereArgs: [c.usuario2Id]));
      if (emp.isNotEmpty) c.usuario2Nome = emp.first['nome'] as String? ?? '';
    }
    setState(() {
      conversas = lista;
      carregando = false;
    });
  }

  void _novaConversa() async {
    final db = DatabaseHelper.instance;
    final empreendedores = await db.database.then((db) => db.query('users', where: 'role = ?', whereArgs: ['Empreendedor']));
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return ListView(
          children: empreendedores.map((e) => ListTile(
            title: Text((e['nome'] ?? 'Empreendedor').toString()),
            subtitle: Text((e['email'] ?? '').toString()),
            onTap: () async {
              Navigator.pop(ctx);
              final convId = await db.createOrGetConversation(widget.executivoId, e['id'] as int);
              setState(() {
                carregando = true;
              });
              await _carregarConversas();
              _abrirChat(convId, (e['nome'] ?? 'Empreendedor').toString(), e['id'] as int);
            },
          )).toList(),
        );
      },
    );
  }

  void _abrirChat(int conversaId, String nomeEmpreendedor, int empreendedorId) async {
    Navigator.push(context, MaterialPageRoute(
      builder: (ctx) => TelaConversa(
        conversaId: conversaId,
        nomeContato: nomeEmpreendedor,
        meuId: widget.executivoId,
        contatoId: empreendedorId,
        meuRole: 'Executivo',
      ),
    )).then((_) => _carregarConversas());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _novaConversa,
          ),
        ],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : conversas.isEmpty
              ? const Center(child: Text('Nenhuma conversa ativa'))
              : ListView.builder(
                  itemCount: conversas.length,
                  itemBuilder: (ctx, idx) {
                    final c = conversas[idx];
                    final ultimaMsg = c.mensagens.isNotEmpty ? c.mensagens.last.texto : '';
                    return ListTile(
                      title: Text(c.usuario2Nome),
                      subtitle: Text(ultimaMsg),
                      trailing: c.novaMensagem ? const Icon(Icons.mark_chat_unread, color: Colors.red) : null,
                      onTap: () => _abrirChat(c.id, c.usuario2Nome, c.usuario2Id),
                    );
                  },
                ),
    );
  }
}

class TelaConversa extends StatefulWidget {
  final int conversaId;
  final String nomeContato;
  final int meuId;
  final int contatoId;
  final String meuRole;
  const TelaConversa({super.key, required this.conversaId, required this.nomeContato, required this.meuId, required this.contatoId, required this.meuRole});

  @override
  State<TelaConversa> createState() => _TelaConversaState();
}

class _TelaConversaState extends State<TelaConversa> {
  List<Mensagem> mensagens = [];
  final _controller = TextEditingController();
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarMensagens();
  }

  Future<void> _carregarMensagens() async {
    final db = DatabaseHelper.instance;
    final msgs = await db.getMessages(widget.conversaId);
    setState(() {
      mensagens = msgs.map((m) => Mensagem(
        id: m['id'] as int,
        conversaId: m['conversation_id'] as int,
        remetenteId: m['sender_id'] as int,
        destinatarioId: m['sender_id'] as int == widget.meuId ? widget.contatoId : widget.meuId,
        texto: m['message'] as String,
        dataHora: DateTime.parse(m['created_at'] as String),
        lida: true,
      )).toList();
      carregando = false;
    });
  }

  Future<void> _enviarMensagem() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;
    final db = DatabaseHelper.instance;
    await db.sendMessage(
      conversationId: widget.conversaId,
      senderId: widget.meuId,
      senderRole: widget.meuRole,
      body: texto,
    );
    _controller.clear();
    await _carregarMensagens();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.nomeContato)),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: mensagens.length,
                    itemBuilder: (ctx, idx) {
                      final m = mensagens[idx];
                      final souEu = m.remetenteId == widget.meuId;
                      return Align(
                        alignment: souEu ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: souEu ? Colors.green[100] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(m.texto),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(hintText: 'Digite sua mensagem'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _enviarMensagem,
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}