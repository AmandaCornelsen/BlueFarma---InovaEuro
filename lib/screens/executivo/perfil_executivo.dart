import 'package:flutter/material.dart';
import 'package:inovaeuro/database_help.dart';
import 'package:inovaeuro/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerfilExecutivo extends StatefulWidget {
  const PerfilExecutivo({super.key});

  @override
  State<PerfilExecutivo> createState() => _PerfilExecutivoState();
}

class _PerfilExecutivoState extends State<PerfilExecutivo> {
  bool _senhaVisivel = false;
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('logged_user_id');
    if (userId != null) {
      final db = DatabaseHelper.instance;
      final dbClient = await db.database;
      final res = await dbClient.query('users', where: 'id = ?', whereArgs: [userId], limit: 1);
      if (res.isNotEmpty) {
        setState(() {
          nomeController.text = res.first['nome'] as String? ?? '';
          emailController.text = res.first['email'] as String? ?? '';
          senhaController.text = res.first['password'] as String? ?? '';
        });
      }
    }
  }

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
            // Removido título duplicado 'Perfil'
            TextFormField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: senhaController,
              decoration: InputDecoration(
                labelText: 'Senha',
                suffixIcon: IconButton(
                  icon: Icon(_senhaVisivel ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _senhaVisivel = !_senhaVisivel;
                    });
                  },
                ),
              ),
              obscureText: !_senhaVisivel,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
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
                  id: userId!,
                  email: emailController.text,
                  password: senhaController.text.isNotEmpty ? senhaController.text : null,
                  nome: nomeController.text,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Perfil atualizado!')),
                );
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('logged_user_email', emailController.text);
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
