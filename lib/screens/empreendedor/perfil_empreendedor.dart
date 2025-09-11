import 'package:flutter/material.dart';
import 'package:inovaeuro/database_help.dart';
import 'package:inovaeuro/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerfilEmpreendedor extends StatefulWidget {
  const PerfilEmpreendedor({super.key});

  @override
  State<PerfilEmpreendedor> createState() => _PerfilEmpreendedorState();
}

class _PerfilEmpreendedorState extends State<PerfilEmpreendedor> {
  String nome = 'Empreendedor';
  String email = 'email@exemplo.com';
  String senha = '';

  void _logout() {
    Navigator.pushReplacementNamed(context, Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Perfil',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              initialValue: nome,
              decoration: const InputDecoration(labelText: 'Nome'),
              onChanged: (v) => nome = v,
            ),
            TextFormField(
              initialValue: email,
              decoration: const InputDecoration(labelText: 'Email'),
              onChanged: (v) => email = v,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
              onChanged: (v) => senha = v,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final userId = prefs.getInt('logged_user_id');

                if (userId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erro: usuário não encontrado'),
                    ),
                  );
                  return;
                }

                final dbHelper = DatabaseHelper.instance;

                await dbHelper.updateUser(
                  id: userId,
                  email: email,
                  password: senha.isNotEmpty
                      ? senha
                      : null, 
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Perfil atualizado!')),
                );

                await prefs.setString('logged_user_email', email);
              },
              child: const Text('Salvar'),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'SAIR',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
