import 'package:flutter/material.dart';
import 'package:inovaeuro/data/app_repository.dart';
import 'package:inovaeuro/database_help.dart';

class ExecutivoScreen extends StatefulWidget {
  const ExecutivoScreen({super.key});

  @override
  State<ExecutivoScreen> createState() => _ExecutivoScreenState();
}

class _ExecutivoScreenState extends State<ExecutivoScreen> {
  Widget _buildDashboardCard(String emoji, String label, int value, Color color, double width) {
    return Card(
      color: color,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: width,
        height: 90,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('$value', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
  int _selectedIndex = 0;

  Map<String, int> dashboardCounts = {
    'pendentes': 0,
    'aprovadas': 0,
    'em_andamento': 0,
    'finalizadas': 0,
  };

  List<Map<String, dynamic>> empreendedores = [];
  Future<void> _loadEmpreendedores() async {
    final db = DatabaseHelper.instance;
    final lista = await db.getAllUsers();
    final empreendedoresDb = lista.where((u) => u['role'] == 'Empreendedor').toList();
    List<Map<String, dynamic>> result = [];
    for (var emp in empreendedoresDb) {
      final projetos = await db.database.then((dbc) => dbc.query('ideas', where: 'user_id = ?', whereArgs: [emp['id']]));
      final submetidos = projetos.length;
      final aprovados = projetos.where((p) => p['status'] == 'approved').length;
      final rejeitados = projetos.where((p) => p['status'] == 'rejected').length;
      result.add({
        "nome": emp['nome'] ?? emp['email'],
        "submetidos": submetidos,
        "aprovados": aprovados,
        "rejeitados": rejeitados,
        "id": emp['id'],
      });
    }
    setState(() {
      empreendedores = result;
    });
  }


  Future<void> _loadDashboard() async {
    try {
      final counts = await AppRepository.instance.countsDashboard();
      setState(() {
        dashboardCounts['pendentes'] = counts['pending'] ?? 0;
        dashboardCounts['aprovadas'] = counts['approved'] ?? 0;
        dashboardCounts['em_andamento'] = counts['in_progress'] ?? 0;
        dashboardCounts['finalizadas'] = counts['completed'] ?? 0;
      });
    } catch (e) {
      debugPrint("Erro ao carregar dashboard: $e");
      setState(() {
        dashboardCounts = {
          'pendentes': 0,
          'aprovadas': 0,
          'em_andamento': 0,
          'finalizadas': 0,
        };
      });
    }
  }

  @override
  void initState() {
  super.initState();
  _loadDashboard();
  _loadEmpreendedores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Executivo')),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8E24AA), Color(0xFFCE93D8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Painel Executivo',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [Color(0xFFE1BEE7), Color(0xFF8E24AA), Color(0xFFBA68C8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(Rect.fromLTWH(0, 0, 300, 100)),
                      shadows: [
                        Shadow(
                          color: Color(0xFFBA68C8).withOpacity(0.7),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth = (constraints.maxWidth - 48) / 4;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDashboardCard('🕒', 'Pendentes', dashboardCounts['pendentes'] ?? 0, Color(0xFF8E24AA), cardWidth),
                          _buildDashboardCard('✅', 'Aprovados', dashboardCounts['aprovadas'] ?? 0, Color(0xFFBA68C8), cardWidth),
                          _buildDashboardCard('🚀', 'Em Andamento', dashboardCounts['em_andamento'] ?? 0, Color(0xFFCE93D8), cardWidth),
                          _buildDashboardCard('🏁', 'Finalizados', dashboardCounts['finalizadas'] ?? 0, Color(0xFF6A1B9A), cardWidth),
                        ],
                      );
                    },
                  ),
                  ...empreendedores.map((e) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(e["nome"] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Submetidos:  ${e["submetidos"]}, Aprovados: ${e["aprovados"]}, Rejeitados: ${e["rejeitados"]}"),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF8E24AA)),
                      onTap: () async {
                        final db = DatabaseHelper.instance;
                        final projetos = await db.database.then((dbc) => dbc.query('ideas', where: 'user_id = ?', whereArgs: [e['id']]));
                        await showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF8E24AA), Color(0xFFCE93D8)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Color(0xFF8E24AA),
                                        child: Text((e["nome"] ?? '')[0], style: const TextStyle(color: Colors.white)),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(e["nome"] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                    ],
                                  ),
                                  const Divider(height: 20, thickness: 1, color: Colors.white),
                                  ...projetos.map((p) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Título: ${p['title'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                        Text('Status: ${p['status'] ?? ''}', style: const TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  )),
                                  const SizedBox(height: 12),
                                  Center(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFFBA68C8)),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        _loadEmpreendedores();
                                        _loadDashboard();
                                      },
                                      child: const Text("Fechar", style: TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb_outline), label: 'Projetos'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }
}