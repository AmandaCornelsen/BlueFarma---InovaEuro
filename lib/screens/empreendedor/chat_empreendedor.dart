import 'package:flutter/material.dart';

class ChatEmpreendedor extends StatefulWidget {
  const ChatEmpreendedor({super.key});

  @override
  State<ChatEmpreendedor> createState() => _ChatEmpreendedorState();
}

class _ChatEmpreendedorState extends State<ChatEmpreendedor> {
  final _controller = TextEditingController();
  List<String> mensagens = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Chat com Executivo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: mensagens.length,
                itemBuilder: (context, idx) => ListTile(
                  title: Text(mensagens[idx]),
                  subtitle: idx % 2 == 0 ? const Text('Você') : const Text('Executivo'),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Digite sua mensagem'))),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    setState(() {
                      mensagens.add(_controller.text);
                    });
                    _controller.clear();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}