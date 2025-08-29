import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:inovaeuro/screens/Login/login_screen.dart';
import 'package:inovaeuro/screens/cadastro/cadastro_screen.dart';
import 'package:inovaeuro/screens/splash/splashScreen.dart';

class Routes {

  static const String splash = "/";
  static const String login = "/login";
  static const String cadastro = "/cadastro";
  static const String empreendedor = "/empreendedor";
  static const String executivo = "/executivo";

static Route<dynamic> generateRoute(RouteSettings settings) {
  switch(settings.name) {
    case splash:
    return MaterialPageRoute(builder: (_) => SplashScreen());
    case login:
    return MaterialPageRoute(builder: (_) => LoginScreen());
    case cadastro:
    return MaterialPageRoute(builder: (_) => CadastroScreen());
    case empreendedor:
    //return MaterialPageRoute(builder: (_) => EmpreendedorScreen());
    case executivo:
    //return MaterialPageRoute(builder: (_) => ExecutivoScreen());

    default:
    return MaterialPageRoute(builder: (_) =>
    Scaffold(body: Center(child: Text('Rota não encontrada!'))),
    );
    }
  }

}