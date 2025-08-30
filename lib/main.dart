import 'package:flutter/material.dart';
import 'package:inovaeuro/database_help.dart';
import 'package:inovaeuro/routes.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

  await DatabaseHelper.instance.database;



  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

   @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InovaEuro',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: Routes.splash,
      onGenerateRoute: Routes.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}