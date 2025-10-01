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
  Future<void> _apagarConta() async {
    if (userId == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar conta'),
        content: const Text('Tem certeza que deseja apagar sua conta? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Apagar', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseHelper.instance.deleteUser(userId!);
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
      }
    }
  }
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
      appBar: AppBar(
        title: const Text('Perfil Executivo'),
        backgroundColor: const Color(0xFF7C4DFF),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 137, 125, 167), Color.fromARGB(255, 218, 203, 240)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 38,
                          backgroundColor: Colors.deepPurple.shade100,
                          child: const Icon(Icons.person, size: 44, color: Color(0xFF7C4DFF)),
                        ),
                        const SizedBox(height: 12),
                        Text('Perfil Executivo', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple.shade700)),
                        const SizedBox(height: 8),
                        Text('Gerencie seus dados com conforto e segurança.', style: TextStyle(fontSize: 15, color: Colors.deepPurple.shade400)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: nomeController,
                      decoration: InputDecoration(
                        labelText: 'Nome',
                        prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF7C4DFF)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        filled: true,
                        fillColor: Colors.deepPurple.shade50,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF7C4DFF)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        filled: true,
                        fillColor: Colors.deepPurple.shade50,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: senhaController,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF7C4DFF)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        filled: true,
                        fillColor: Colors.deepPurple.shade50,
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
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C4DFF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
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
                      label: const Text('Salvar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.exit_to_app, color: Colors.white),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          label: const Text('SAIR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _apagarConta,
                          icon: const Icon(Icons.delete_forever, color: Colors.white),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          label: const Text('APAGAR CONTA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
