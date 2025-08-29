import 'package:flutter/material.dart';
import 'package:inovaeuro/database_help.dart';

class HomeEmpreendedor extends StatefulWidget {
  const HomeEmpreendedor({super.key});

  @override
  State<HomeEmpreendedor> createState() => _HomeEmpreendedorState();
}

class _HomeEmpreendedorState extends State<HomeEmpreendedor> {
  int points = 0;

  @override
  void initState() {
    super.initState();
    _loadUserPoints();
  }

  Future<void> _loadUserPoints() async {
    // Aqui você pode pegar o usuário logado do SQLite
    // Temporário: ponto inicial
    setState(() {
      points = 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Empreendedor'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.yellow),
                const SizedBox(width: 4),
                Text(points.toString()),
              ],
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Suas ideias',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    Card(
                      child: ListTile(
                        title: const Text('Ideia 1'),
                        subtitle: const Text('Status: Em análise'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {},
                        ),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: const Text('Ideia 2'),
                        subtitle: const Text('Status: Aprovada'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Nova Ideia'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
