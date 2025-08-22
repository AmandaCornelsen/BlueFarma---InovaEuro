import 'package:flutter/material.dart';
import 'screens/Login/selecao_screen.dart';
import 'screens/Login/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

   @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InovaEuro',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: SelecaoScreen()
    );
}
}