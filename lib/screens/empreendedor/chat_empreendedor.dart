
import 'package:flutter/material.dart';
import '../../database_help.dart';
import '../../data/chat_models.dart';

class ChatEmpreendedor extends StatefulWidget {
  final int empreendedorId;
  final String empreendedorNome;
  const ChatEmpreendedor({super.key, required this.empreendedorId, required this.empreendedorNome});

  @override
  State<ChatEmpreendedor> createState() => _ChatEmpreendedorState();
}

class _ChatEmpreendedorState extends State<ChatEmpreendedor> {
  List<Conversa> conversas = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarConversas();
  }

  Future<void> _carregarConversas() async {
    final db = DatabaseHelper.instance;
    final convs = await db.listConversationsForUser(widget.empreendedorId, 'Empreendedor');
    List<Conversa> lista = [];
    for (var conv in convs) {
      final msgs = await db.getMessages(conv['id'] as int);
      lista.add(
        Conversa(
          id: conv['id'] as int,
          usuario1Id: conv['empreendedor_id'] as int,
          usuario2Id: conv['executive_id'] as int,
          usuario1Nome: widget.empreendedorNome,
          usuario2Nome: '', // Nome do executivo será buscado abaixo
          mensagens: msgs.map((m) => Mensagem(
            id: m['id'] as int,
            conversaId: m['conversation_id'] as int,
            remetenteId: m['sender_id'] as int,
            destinatarioId: m['sender_id'] as int == widget.empreendedorId ? conv['executive_id'] as int : widget.empreendedorId,
            texto: m['message'] as String,
            dataHora: DateTime.parse(m['created_at'] as String),
            lida: true,
          )).toList(),
          novaMensagem: false,
        ),
      );
    }
    // Buscar nomes dos executivos
    for (var c in lista) {
      final exec = await db.database.then((db) => db.query('users', where: 'id = ?', whereArgs: [c.usuario2Id]));
      if (exec.isNotEmpty) c.usuario2Nome = exec.first['nome'] as String? ?? '';
    }
    setState(() {
      conversas = lista;
      carregando = false;
    });
  }

  void _novaConversa() async {
    final db = DatabaseHelper.instance;
    final executivos = await db.getExecutives();
    showDialog(
      context: context,
      builder: (ctx) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.15), blurRadius: 16)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Selecione um executivo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF7C4DFF))),
                  const SizedBox(height: 16),
                  ...executivos.map((e) => Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple.shade100,
                        child: Text((e['nome'] ?? 'E')[0]),
                      ),
                      title: Text(e['nome'] ?? 'Executivo', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(e['email'] ?? '', style: const TextStyle(color: Colors.deepPurple)),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF7C4DFF)),
                      onTap: () async {
                        Navigator.pop(ctx);
                        final convId = await db.createOrGetConversation(e['id'] as int, widget.empreendedorId);
                        setState(() {
                          carregando = true;
                        });
                        await _carregarConversas();
                        _abrirChat(convId, e['nome'] ?? 'Executivo', e['id'] as int);
                      },
                    ),
                  )),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar', style: TextStyle(color: Color(0xFF7C4DFF), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _abrirChat(int conversaId, String nomeExecutivo, int executivoId) async {
    Navigator.push(context, MaterialPageRoute(
      builder: (ctx) => TelaConversa(
        conversaId: conversaId,
        nomeContato: nomeExecutivo,
        meuId: widget.empreendedorId,
        contatoId: executivoId,
        meuRole: 'Empreendedor',
      ),
    )).then((_) => _carregarConversas());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Nova conversa', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C4DFF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 6,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              ),
              onPressed: _novaConversa,
            ),
          ),
        ],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : conversas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: Colors.deepPurple.shade200),
                      const SizedBox(height: 16),
                      const Text('Nenhuma conversa ativa', style: TextStyle(fontSize: 18, color: Color(0xFF7C4DFF))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  itemCount: conversas.length,
                  itemBuilder: (ctx, idx) {
                    final c = conversas[idx];
                    final ultimaMsg = c.mensagens.isNotEmpty ? c.mensagens.last.texto : '';
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple.shade100,
                          child: Text(c.usuario2Nome.isNotEmpty ? c.usuario2Nome[0] : 'E'),
                        ),
                        title: Text(c.usuario2Nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(ultimaMsg, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF7C4DFF))),
                        trailing: c.novaMensagem ? const Icon(Icons.mark_chat_unread, color: Colors.red) : null,
                        onTap: () => _abrirChat(c.id, c.usuario2Nome, c.usuario2Id),
                      ),
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
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.deepPurple.shade100,
              child: Text(widget.nomeContato.isNotEmpty ? widget.nomeContato[0] : 'E'),
            ),
            const SizedBox(width: 12),
            Text(widget.nomeContato, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: const Color(0xFF7C4DFF),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF6F2FF), Color(0xFFEDE7F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      itemCount: mensagens.length,
                      itemBuilder: (ctx, idx) {
                        final m = mensagens[idx];
                        final souEu = m.remetenteId == widget.meuId;
                        return Row(
                          mainAxisAlignment: souEu ? MainAxisAlignment.end : MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                              decoration: BoxDecoration(
                                color: souEu ? const Color(0xFF7C4DFF) : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(18),
                                  topRight: const Radius.circular(18),
                                  bottomLeft: Radius.circular(souEu ? 18 : 4),
                                  bottomRight: Radius.circular(souEu ? 4 : 18),
                                ),
                                boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.08), blurRadius: 6)],
                              ),
                              child: Text(
                                m.texto,
                                style: TextStyle(
                                  color: souEu ? Colors.white : const Color(0xFF7C4DFF),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.07), blurRadius: 8)],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: 'Digite sua mensagem...',
                              filled: true,
                              fillColor: const Color(0xFFF6F2FF),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _enviarMensagem,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C4DFF),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            elevation: 4,
                          ),
                          child: const Icon(Icons.send, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}