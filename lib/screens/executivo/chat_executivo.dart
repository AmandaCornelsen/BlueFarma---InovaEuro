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
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Center(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB388FF), Color(0xFF7C4DFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 16)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Selecione um empreendedor', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                ...empreendedores.map((e) => Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  color: Colors.white.withOpacity(0.9),
                  child: ListTile(
                    title: Text((e['nome'] ?? 'Empreendedor').toString(), style: TextStyle(color: Color(0xFF7C4DFF), fontWeight: FontWeight.bold)),
                    subtitle: Text((e['email'] ?? '').toString(), style: TextStyle(color: Colors.black54)),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final convId = await db.createOrGetConversation(widget.executivoId, e['id'] as int);
                      setState(() {
                        carregando = true;
                      });
                      await _carregarConversas();
                      _abrirChat(convId, (e['nome'] ?? 'Empreendedor').toString(), e['id'] as int);
                    },
                  ),
                ))
              ],
            ),
          ),
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE1BEE7), Color(0xFF7C4DFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, right: 16, left: 16, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Chats', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF7C4DFF))),
                      IconButton(
                        icon: const Icon(Icons.add, color: Color(0xFF7C4DFF)),
                        onPressed: _novaConversa,
                        tooltip: 'Nova conversa',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: conversas.isEmpty
                      ? Center(
                          child: Text('Nenhuma conversa ativa', style: TextStyle(fontSize: 18, color: Color(0xFF7C4DFF), fontWeight: FontWeight.bold)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: conversas.length,
                          itemBuilder: (ctx, idx) {
                            final c = conversas[idx];
                            final ultimaMsg = c.mensagens.isNotEmpty ? c.mensagens.last.texto : '';
                            return Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 6,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              color: Colors.white.withOpacity(0.95),
                              child: ListTile(
                                title: Text(c.usuario2Nome, style: TextStyle(color: Color(0xFF7C4DFF), fontWeight: FontWeight.bold)),
                                subtitle: Text(ultimaMsg, style: TextStyle(color: Colors.black87)),
                                trailing: c.novaMensagem ? const Icon(Icons.mark_chat_unread, color: Colors.red) : null,
                                onTap: () => _abrirChat(c.id, c.usuario2Nome, c.usuario2Id),
                              ),
                            );
                          },
                        ),
                ),
              ],
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

  State<TelaConversa> createState() => _TelaConversaState();
}

class _TelaConversaState extends State<TelaConversa> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE1BEE7), Color(0xFF7C4DFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(widget.nomeContato),
          backgroundColor: Color(0xFF7C4DFF),
          elevation: 6,
        ),
        body: carregando
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: mensagens.length,
                      itemBuilder: (ctx, idx) {
                        final m = mensagens[idx];
                        final souEu = m.remetenteId == widget.meuId;
                        return Align(
                          alignment: souEu ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: souEu ? Color(0xFFD1C4E9) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                            ),
                            child: Text(m.texto, style: TextStyle(color: Color(0xFF4A148C))),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFFB388FF).withOpacity(0.7),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: 'Digite sua mensagem',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.send, color: Color(0xFF7C4DFF)),
                          onPressed: _enviarMensagem,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
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

}