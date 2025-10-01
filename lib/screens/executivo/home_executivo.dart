import 'package:flutter/material.dart';
import 'package:inovaeuro/data/app_repository.dart';
import 'package:inovaeuro/database_help.dart';
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
  _loadEmpreendedores();
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
                          Card(
                            color: Colors.redAccent,
                            child: InkWell(
                              onTap: () => _onNavItemTapped(1),
                              child: SizedBox(
                                width: cardWidth,
                                height: 80,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('🕒', style: TextStyle(fontSize: 24)),
                                      Text('Pendentes', style: TextStyle(color: Colors.white)),
                                      Text('${dashboardCounts['pendentes']}', style: TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Card(
                            color: Colors.green,
                            child: SizedBox(
                              width: cardWidth,
                              height: 80,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('✅', style: TextStyle(fontSize: 24)),
                                    Text('Aprovados', style: TextStyle(color: Colors.white)),
                                    Text('${dashboardCounts['aprovadas']}', style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Card(
                            color: Colors.blueAccent,
                            child: SizedBox(
                              width: cardWidth,
                              height: 80,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('🚀', style: TextStyle(fontSize: 24)),
                                    Text('Em Andamento', style: TextStyle(color: Colors.white)),
                                    Text('${dashboardCounts['em_andamento']}', style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Card(
                            color: Colors.purpleAccent,
                            child: SizedBox(
                              width: cardWidth,
                              height: 80,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('🏁', style: TextStyle(fontSize: 24)),
                                    Text('Finalizados', style: TextStyle(color: Colors.white)),
                                    Text('${dashboardCounts['finalizadas']}', style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  ...empreendedores.map((e) => ListTile(
                    title: Text(e["nome"] ?? ''),
                    subtitle: Text("Submetidos: ${e["submetidos"]}, Aprovados: ${e["aprovados"]}, Rejeitados: ${e["rejeitados"]}"),
                    trailing: const Icon(Icons.arrow_forward_ios),
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
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.indigo,
                                      child: Text((e["nome"] ?? '')[0], style: const TextStyle(color: Colors.white)),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(e["nome"] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const Divider(height: 20, thickness: 1),
                                ...projetos.map((p) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Título: ${p['title'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text('Status: ${p['status'] ?? ''}'),
                                    ],
                                  ),
                                )),
                                const SizedBox(height: 12),
                                Center(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(255, 174, 181, 220)),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _loadEmpreendedores();
                                      _loadDashboard();
                                    },
                                    child: const Text("Fechar"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )).toList(),
                ],
              ),
            ),
          ],
        );
        break;
      case 1:
        currentBody = ExecutivoProjetos(
          onProjetoAprovadoOuRejeitado: () {
            _loadDashboard();
            _loadEmpreendedores();
          },
        );
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
