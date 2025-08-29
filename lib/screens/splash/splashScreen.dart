import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:inovaeuro/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centraliza verticalmente
          children: [
            Lottie.asset(
              'assets/lottie/Splash.json',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              onLoaded: (composition) {
                Future.delayed(composition.duration, () {
                  Navigator.pushReplacementNamed(context, Routes.login);
                });
              },
            ),
            const SizedBox(height: 20), // Espaçamento entre animação e texto
            const Text(
              "Bem-vindo ao InovaEuro 💊",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
