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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8E24AA), Color(0xFFCE93D8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        'InovaEuro',
                        style: TextStyle(
                          fontSize: 54,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          foreground: Paint()
                            ..shader = const LinearGradient(
                              colors: [Color(0xFFE1BEE7), Color(0xFF8E24AA), Color(0xFFBA68C8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(Rect.fromLTWH(0, 0, 320, 110)),
                          shadows: [
                            Shadow(
                              color: Color(0xFFBA68C8).withOpacity(0.7),
                              blurRadius: 32,
                              offset: Offset(0, 0),
                            ),
                            Shadow(
                              color: Colors.black38,
                              blurRadius: 16,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'InovaEuro',
                        style: TextStyle(
                          fontSize: 54,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          foreground: Paint()..color = Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.white,
                              blurRadius: 2,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: nomeController,
                          decoration: InputDecoration(
                            labelText: 'Nome de usuário',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.person, color: Colors.blue[700]),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.email, color: Colors.blue[700]),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: Icon(Icons.lock, color: Colors.blue[700]),
                          ),
                        ),
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 16),
                        if (selectedRole == "Executivo")
                          TextField(
                            controller: codigoExecutivoController,
                            decoration: InputDecoration(
                              labelText: 'Código Executivo',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: Icon(Icons.verified, color: Colors.blue[700]),
                            ),
                          ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _registerUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8E24AA),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 6,
                            shadowColor: Color(0xFFBA68C8),
                          ),
                          child: const Text('Cadastrar', style: TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, Routes.login);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Color(0xFF8E24AA), width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Voltar ao Login', style: TextStyle(fontSize: 18, color: Color(0xFF8E24AA))),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
