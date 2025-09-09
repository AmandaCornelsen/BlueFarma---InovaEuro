import 'package:flutter/material.dart';
import 'package:inovaeuro/current_user.dart';
import 'package:inovaeuro/data/app_repository.dart';
import 'package:inovaeuro/screens/empreendedor/perfil_empreendedor.dart';
import 'chat_executivo.dart';
import 'perfil_executivo.dart';
import 'projetos_executivo.dart';


class ExecutivoScreen extends StatefulWidget {
  const ExecutivoScreen({super.key});

  @override
  State<ExecutivoScreen> createState() => _ExecutivoScreenState();
}

class _ExecutivoScreenState extends State<ExecutivoScreen> {
  int _selectedIndex = 0;

  Map<String, int> dashboardCounts = {
    'pendentes': 0,
    'aprovadas': 0,
    'em_andamento': 0,
    'finalizadas': 0,
  };

  void _onNavItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _loadDashboard() async {
    try {
      final counts = await AppRepository.instance.countsDashboard();
      if (counts != null) {
        setState(() {
          dashboardCounts['pendentes'] = counts['pending'] ?? 0;
          dashboardCounts['aprovadas'] = counts['approved'] ?? 0;
          dashboardCounts['em_andamento'] = counts['in_progress'] ?? 0;
          dashboardCounts['finalizadas'] = counts['completed'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint("Erro ao carregar dashboard: $e");
      // Mantém zeros caso haja erro
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
  }

  @override
  Widget build(BuildContext context) {
    Widget currentBody;

    switch (_selectedIndex) {
      case 0:
        currentBody = SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Painel Executivo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                children: [
                  _buildDashboardCard('Projetos Pendentes',
                      dashboardCounts['pendentes']!, Colors.redAccent),
                  _buildDashboardCard('Projetos Aprovados',
                      dashboardCounts['aprovadas']!, Colors.green),
                  _buildDashboardCard('Em Andamento',
                      dashboardCounts['em_andamento']!, Colors.blueAccent),
                  _buildDashboardCard('Finalizados',
                      dashboardCounts['finalizadas']!, Colors.purpleAccent),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.indigo.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Últimas ações',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                          'Você possui ${dashboardCounts['pendentes']} projetos para analisar.'),
                      Text(
                          '${dashboardCounts['aprovadas']} projetos foram aprovados recentemente.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
        break;
      case 1:
        currentBody = const ExecutivoProjetos();
        break;
      case 2:
        currentBody = const ChatExecutivo();
        break;
      case 3:
        currentBody = const PerfilExecutivo();
        break;
      default:
        currentBody = Container();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Executivo')
      ),
      body: SafeArea(child: currentBody),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb_outline), label: 'Projetos'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(String title, int count, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: color.withOpacity(0.85),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$count',
                style: const TextStyle(fontSize: 32, color: Colors.white)),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
