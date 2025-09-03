import 'package:flutter/material.dart';

class PerfilEmpreendedor extends StatefulWidget {
  const PerfilEmpreendedor({super.key});

  @override
  State<PerfilEmpreendedor> createState() => _PerfilEmpreendedorState();
}

class _PerfilEmpreendedorState extends State<PerfilEmpreendedor> {
  String nome = 'Empreendedor';
  String email = 'email@exemplo.com';
  String senha = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Perfil', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          TextFormField(initialValue: nome, decoration: InputDecoration(labelText: 'Nome'), onChanged: (v) => nome = v),
          TextFormField(initialValue: email, decoration: InputDecoration(labelText: 'Email'), onChanged: (v) => email = v),
          TextFormField(decoration: InputDecoration(labelText: 'Senha'), obscureText: true, onChanged: (v) => senha = v),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Perfil atualizado!')));
            },
            child: Text('Salvar'),
          ),
        ],
      ),
    );
  }
}