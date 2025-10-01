import 'package:flutter/material.dart';
import 'package:inovaeuro/data/app_repository.dart';
import 'package:inovaeuro/current_user.dart';
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

  final List<Map<String, dynamic>> empreendedores = [
    {
      "nome": "Ana Silva",
      "submetidos": 4,
      "aprovados": 2,
      "rejeitados": 1,
    },
    {
      "nome": "Carlos Souza",
      "submetidos": 3,
      "aprovados": 1,
      "rejeitados": 2,
    },
    {
      "nome": "Mariana Costa",
      "submetidos": 5,
      "aprovados": 4,
      "rejeitados": 1,
    },
  ];

  void _onNavItemTapped(int index) {
    setState(() => _selectedIndex = index);
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
  }

  @override
  Widget build(BuildContext context) {
    Widget currentBody;

    switch (_selectedIndex) {
      case 0:
        currentBody = Stack(
          children: [
            // Fundo neutro
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Color(0xFFF5F5F5)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            SingleChildScrollView(
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
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth = (constraints.maxWidth - 48) / 4;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _HoverCard(
                            width: cardWidth,
                            color: Colors.redAccent,
                            emoji: "🕒",
                            title: 'Projetos Pendentes',
                            count: dashboardCounts['pendentes']!,
                            onTap: () => _onNavItemTapped(1),
                          ),
                          _HoverCard(
                            width: cardWidth,
                            color: Colors.green,
                            emoji: "✅",
                            title: 'Projetos Aprovados',
                            count: dashboardCounts['aprovadas']!,
                          ),
                          _HoverCard(
                            width: cardWidth,
                            color: Colors.blueAccent,
                            emoji: "🚀",
                            title: 'Em Andamento',
                            count: dashboardCounts['em_andamento']!,
                          ),
                          _HoverCard(
                            width: cardWidth,
                            color: Colors.purpleAccent,
                            emoji: "🏁",
                            title: 'Finalizados',
                            count: dashboardCounts['finalizadas']!,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  // Card de Empreendedores
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    color: Colors.indigo.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Empreendedores',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          ...empreendedores.map((e) {
                            return ListTile(
                              title: Text(e["nome"]),
                              subtitle: Text(
                                  "Submetidos: ${e["submetidos"]}, Aprovados: ${e["aprovados"]}, Rejeitados: ${e["rejeitados"]}"),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.indigo.shade50,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: Colors.indigo,
                                                child: Text(
                                                  e["nome"][0],
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                e["nome"],
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          const Divider(height: 20, thickness: 1),
                                          Row(
                                            children: [
                                              const Icon(Icons.pending,
                                                  color: Colors.orange),
                                              const SizedBox(width: 8),
                                              Text(
                                                  "Submetidos: ${e["submetidos"]}"),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(Icons.check_circle,
                                                  color: Colors.green),
                                              const SizedBox(width: 8),
                                              Text(
                                                  "Aprovados: ${e["aprovados"]}"),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(Icons.cancel,
                                                  color: Colors.red),
                                              const SizedBox(width: 8),
                                              Text(
                                                  "Rejeitados: ${e["rejeitados"]}"),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Center(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color.fromARGB(255, 174, 181, 220)),
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text("Fechar"),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        break;
      case 1:
        currentBody =
            ExecutivoProjetos(onProjetoAprovadoOuRejeitado: _loadDashboard);
        break;
      case 2:
          if (CurrentUser.instance.id == null) {
            currentBody = const Center(child: CircularProgressIndicator());
          } else {
            currentBody = ChatExecutivo(
              executivoId: CurrentUser.instance.id!,
              executivoNome: CurrentUser.instance.email ?? '',
            );
          }
        break;
      case 3:
        currentBody = const PerfilExecutivo();
        break;
      default:
        currentBody = Container();
    }

    return Scaffold(
      appBar: _selectedIndex == 0 ? AppBar(title: const Text('Home Executivo')) : null,
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

// HoverCard atualizado
class _HoverCard extends StatefulWidget {
  final double width;
  final Color color;
  final String title;
  final int count;
  final String emoji;
  final VoidCallback? onTap;

  const _HoverCard({
    required this.width,
    required this.color,
    required this.title,
    required this.count,
    required this.emoji,
    this.onTap,
  });

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final scale = _hovering ? 1.05 : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(scale),
          width: widget.width,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text('${widget.count}',
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 4),
              Text(widget.title,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
