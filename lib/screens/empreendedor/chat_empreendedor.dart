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
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Chat com Executivo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Expanded(
            child: ListView.builder(
              itemCount: mensagens.length,
              itemBuilder: (context, idx) => ListTile(
                title: Text(mensagens[idx]),
                subtitle: idx % 2 == 0 ? Text('Você') : Text('Executivo'),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(child: TextField(controller: _controller, decoration: InputDecoration(hintText: 'Digite sua mensagem'))),
              IconButton(
                icon: Icon(Icons.send),
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
    );
  }
}