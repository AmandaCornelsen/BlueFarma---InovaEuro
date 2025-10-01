import 'package:flutter/material.dart';

class ChatExecutivo extends StatelessWidget {
  const ChatExecutivo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: const Center(child: Text('Lista de conversas aqui')),
    );
  }
}
