import 'package:flutter/material.dart';
import 'package:inovaeuro/current_user.dart';
import 'package:inovaeuro/routes.dart';
import 'package:inovaeuro/database_help.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8E24AA), Color(0xFFCE93D8)], // Roxo e lilás
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
                      // Glow lilás
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
                      // Borda branca
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
                          keyboardType: TextInputType.visiblePassword,
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
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () async {
                            final email = emailController.text.trim();
                            final password = passwordController.text.trim();
                            if (email.isEmpty || password.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Preencha todos os campos')),
                              );
                              return;
                            }
                            try {
                              final user = await DatabaseHelper.instance.getUser(email, password);
                              if (user == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Email ou senha inválidos')),
                                );
                              } else {
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.setInt('logged_user_id', user['id']);
                                await prefs.setString('logged_user_email', user['email']);
                                await prefs.setString('logged_user_role', user['role']);
                                CurrentUser.instance.id = user['id'];
                                CurrentUser.instance.email = user['email'];
                                CurrentUser.instance.role = user['role'];
                                CurrentUser.instance.points = user['points'] ?? 0;
                                final role = user['role'];
                                if (role == "Executivo") {
                                  Navigator.pushReplacementNamed(context, Routes.executivo);
                                } else if (role == "Empreendedor") {
                                  Navigator.pushReplacementNamed(context, Routes.empreendedor);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Tipo de usuário desconhecido')),
                                  );
                                }
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erro ao fazer login: $e')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8E24AA), // Roxo
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 6,
                            shadowColor: Color(0xFFBA68C8), // Lilás
                          ),
                          child: const Text('Entrar', style: TextStyle(fontSize: 18)),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, Routes.cadastro);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Color(0xFF8E24AA), width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Registrar', style: TextStyle(fontSize: 18, color: Color(0xFF8E24AA))),
                        ),
                        const SizedBox(height: 24),
                        Text.rich(
                          TextSpan(
                            text: 'Ao continuar, você concorda com nossos ',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                            children: [
                              TextSpan(
                                text: 'Termos de Serviço',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(text: ' e '),
                              TextSpan(
                                text: 'Política de Privacidade',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(text: ' da BlueFarma'),
                            ],
                          ),
                          textAlign: TextAlign.center,
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
