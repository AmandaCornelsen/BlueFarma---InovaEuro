import 'package:flutter/material.dart';

class HomeExecutivo extends StatefulWidget {
  const HomeExecutivo({super.key});

  @override
  State<HomeExecutivo> createState() => _HomeExecutivoState();
}

class _HomeExecutivoState extends State<HomeExecutivo> {
  int totalIdeas = 12;
  int approvedIdeas = 7;
  int pendingIdeas = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Executivo'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Dashboard de Ideias',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDashboardCard('Total', totalIdeas, Colors.blue),
                  _buildDashboardCard('Aprovadas', approvedIdeas, Colors.green),
                  _buildDashboardCard('Pendentes', pendingIdeas, Colors.orange),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Notificações',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.new_releases),
                      title: const Text('Nova ideia de João'),
                      subtitle: const Text('Clique para aprovar/rejeitar'),
                      trailing: IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () {},
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.new_releases),
                      title: const Text('Nova ideia de Maria'),
                      subtitle: const Text('Clique para aprovar/rejeitar'),
                      trailing: IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat),
                  label: const Text('Chat com Empreendedores'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(String title, int value, Color color) {
    return Card(
      color: color.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value.toString(),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }
}
