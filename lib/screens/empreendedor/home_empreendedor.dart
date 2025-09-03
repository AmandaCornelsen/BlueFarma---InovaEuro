import 'package:flutter/material.dart';
import 'package:inovaeuro/screens/empreendedor/light_empreendedor.dart';
import 'package:inovaeuro/screens/empreendedor/chat_empreendedor.dart';
import 'package:inovaeuro/screens/empreendedor/bonus_empreendedor.dart';
import 'package:inovaeuro/screens/empreendedor/perfil_empreendedor.dart';

class EmpreendedorScreen extends StatefulWidget {
  const EmpreendedorScreen({super.key});

  @override
  State<EmpreendedorScreen> createState() => _EmpreendedorScreenState();
}

class _EmpreendedorScreenState extends State<EmpreendedorScreen> {
  int points = 0;
  int _selectedIndex = 0;

  List<Map<String, dynamic>> projetos = [
    {
      'title': 'Projeto 1',
      'subtitle': 'Carbono Verde',
      'imageUrl': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=60',
      'description': 'Redução de carbono na indústria farmacêutica.',
      'statusPercent': 0.7,
      'status': 'Em andamento',
    },
    {
      'title': 'Projeto 2',
      'subtitle': 'Medicina alternativa',
      'imageUrl': null,
      'description': 'Pesquisa sobre tratamentos naturais.',
      'statusPercent': 0.2,
      'status': 'A começar',
    },
  ];

  @override
  void initState() {
    super.initState();
  }


  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onAddPressed() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  void _removerProjeto(int idx) {
    setState(() {
      projetos.removeAt(idx);
    });
  }

  void _editarProjeto(int idx) {
    setState(() {
      projetos[idx]['title'] = projetos[idx]['title'] + ' (editado)';
    });
  }

  void _mostrarDetalhes(Map<String, dynamic> projeto) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(projeto['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (projeto['imageUrl'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(projeto['imageUrl'], height: 120, fit: BoxFit.cover),
              ),
            SizedBox(height: 12),
            Text(projeto['description']),
            SizedBox(height: 12),
            Text('Status: ${projeto['status']}'),
            LinearProgressIndicator(value: projeto['statusPercent']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget currentBody;
    switch (_selectedIndex) {
      case 0:
        currentBody = Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Projetos em andamento',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: projetos.isEmpty
                    ? Center(child: Text('Sem projetos ainda'))
                    : ListView.separated(
                        itemCount: projetos.length,
                        separatorBuilder: (_, __) => SizedBox(height: 12),
                        itemBuilder: (context, idx) {
                          final projeto = projetos[idx];
                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                            child: ListTile(
                              leading: projeto['imageUrl'] != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(projeto['imageUrl'], width: 48, height: 48, fit: BoxFit.cover),
                                    )
                                  : CircleAvatar(
                                      backgroundColor: Colors.purple.shade100,
                                      child: Text(projeto['title'][0], style: TextStyle(color: Colors.white)),
                                    ),
                              title: Text(projeto['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              subtitle: Text(projeto['subtitle'], style: TextStyle(fontSize: 14, color: Colors.grey)),
                              trailing: PopupMenuButton<String>(
                                itemBuilder: (context) => [
                                  PopupMenuItem(value: 'edit', child: Text('Editar')),
                                  PopupMenuItem(value: 'delete', child: Text('Excluir')),
                                ],
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    _editarProjeto(idx);
                                  } else if (value == 'delete') {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Excluir projeto'),
                                        content: Text('Tem certeza que deseja excluir este projeto?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            child: Text('Excluir'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      _removerProjeto(idx);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Projeto excluído!')),
                                      );
                                    }
                                  }
                                },
                              ),
                              onTap: () => _mostrarDetalhes(projeto),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
        break;
      case 1:
        currentBody = LightEmpreendedor(
        ideias: [], 
        onSubmit: (novaIdeia) {
    
        },
        ); 
        break;
      case 2:
        currentBody = ChatEmpreendedor(); 
        break;
      case 3:
        currentBody = BonusEmpreendedor(
          enviados: projetos.length,
          aprovados: projetos.where((p) => p['status'] == 'Concluído').length,
          pontos: projetos.length * 50, // ajuste sua lógica de pontos
        ); 
        break;
      case 4:
        currentBody = PerfilEmpreendedor(); 
        break;
      default:
        currentBody = Container();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Empreendedor'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.yellow),
                const SizedBox(width: 4),
                Text(points.toString()),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(child: currentBody),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _onAddPressed,
              backgroundColor: Colors.purple,
              child: const Icon(Icons.add, size: 32),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            label: 'Ideias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.laptop_chromebook_outlined),
            label: 'Bonificacao',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}