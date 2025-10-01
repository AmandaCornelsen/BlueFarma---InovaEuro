import 'package:flutter/material.dart';
import 'package:inovaeuro/database_help.dart';
import 'package:inovaeuro/current_user.dart';
import 'package:inovaeuro/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController codigoExecutivoController = TextEditingController();

  String? selectedRole;
  final List<String> roles = ["Executivo", "Empreendedor"];

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    codigoExecutivoController.dispose();
    super.dispose();
  }

  // Função para cadastrar usuário no banco
  Future<void> _registerUser() async {
    final nome = nomeController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (nome.isEmpty || email.isEmpty || password.isEmpty || selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    // Se for executivo, precisa validar o código
    if (selectedRole == "Executivo" && codigoExecutivoController.text.trim() != "127") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código executivo incorreto')),
      );
      return;
    }

    try {
      await DatabaseHelper.instance.createUser(email, password, selectedRole!, nome);
      // Busca usuário recém-cadastrado para login automático
      final user = await DatabaseHelper.instance.getUser(email, password);
      if (user != null) {
        // Inicializa CurrentUser
        // ignore: use_build_context_synchronously
        CurrentUser.instance.id = user['id'];
        CurrentUser.instance.email = user['email'];
        CurrentUser.instance.role = user['role'];
        CurrentUser.instance.points = user['points'] ?? 0;

        // Salva no SharedPreferences igual ao login
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('logged_user_id', user['id']);
        await prefs.setString('logged_user_email', user['email']);
        await prefs.setString('logged_user_role', user['role']);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário cadastrado com sucesso!')),
      );

      // Redireciona para a home correta
      if (selectedRole == "Executivo") {
        Navigator.pushReplacementNamed(context, Routes.executivo);
      } else {
        Navigator.pushReplacementNamed(context, Routes.empreendedor);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar usuário: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro InovaEuro'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, Routes.login),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 32),
                const Text(
                  'Cadastro',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nomeController,
                  decoration: InputDecoration(
                    hintText: 'Nome de usuário',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'email@domain.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Senha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  hint: const Text('Selecione seu perfil'),
                  items: roles.map((role) {
                    return DropdownMenuItem(value: role, child: Text(role));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  ),
                ),
                const SizedBox(height: 12),
                // Só aparece se for executivo
                if (selectedRole == "Executivo")
                  TextField(
                    controller: codigoExecutivoController,
                    decoration: InputDecoration(
                      hintText: 'Código Executivo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cadastrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
