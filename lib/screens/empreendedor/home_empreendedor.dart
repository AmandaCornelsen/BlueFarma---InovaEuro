import 'package:flutter/material.dart';
import 'package:inovaeuro/screens/empreendedor/projeto_detalhe.dart';

class EmpreendedorScreen extends StatefulWidget {
  const EmpreendedorScreen({super.key});

  @override
  State<EmpreendedorScreen> createState() => _EmpreendedorScreenState();
}

class _EmpreendedorScreenState extends State<EmpreendedorScreen> {
  int points = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserPoints();
  }

  Future<void> _loadUserPoints() async {
    // Aqui você pode buscar os pontos do usuário no banco
    setState(() {
      points = 10; // exemplo temporário
    });
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Aqui você pode tratar a navegação para outras telas se quiser.
      // Exemplo:
      // if (index == 0) { Navigator.pushNamed(context, Routes.home); }
      // else if (index == 1) { ... }
    });
  }

  void _onAddPressed() {
    // Navegar para a tela de ideias (exemplo: 'ideias')
    Navigator.pushNamed(context, '/ideias');
  }

  @override
  Widget build(BuildContext context) {
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
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Suas ideias',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildIdeaCard(
                      title: 'Projeto 1',
                      subtitle: 'Carbono Verde',
                      imageUrl:
                          'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=60',
                      description:
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor',
                    ),
                    const SizedBox(height: 12),
                    _buildIdeaCard(
                      title: 'Projeto 2',
                      subtitle: 'Medicina alternativa',
                      imageUrl: null, // Sem imagem neste exemplo
                      description: '',
                      showAddButton: true,
                      onAddPressed: _onAddPressed,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddPressed,
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, size: 32),
      ),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), label: 'Opção 3'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildIdeaCard({
    required String title,
    required String subtitle,
    String? imageUrl,
    required String description,
    bool showAddButton = false,
    VoidCallback? onAddPressed,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.purple.shade100,
                  child: Text(title[0], style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(subtitle,
                          style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ),
                if (showAddButton)
                  ElevatedButton(
                    onPressed: onAddPressed,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                    ),
                    child: const Icon(Icons.add),
                  )
                else
                  PopupMenuButton<String>(
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Editar')),
                      const PopupMenuItem(value: 'delete', child: Text('Excluir')),
                    ],
                    onSelected: (value) {
                      // lógica para editar ou excluir
                    },
                  ),
              ],
            ),
            if (imageUrl != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imageUrl, fit: BoxFit.cover),
              ),
            ],
            if (description.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Subtexto', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text(description),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProjetoDetailScreen(
                    title: title,
                    imageUrl: imageUrl ?? '',
                    statusPercent: 0.0, // Ajuste conforme o progresso real do projeto
                    investimento: 'R\$0 - R\$1200', // Ajuste conforme dados reais
                    ),
                  ),
                );
              },

                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.purple,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Saber mais'),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
