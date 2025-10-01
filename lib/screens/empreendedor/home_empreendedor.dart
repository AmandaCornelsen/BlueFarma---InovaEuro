import 'package:flutter/material.dart';
import 'package:inovaeuro/current_user.dart';
import 'light_empreendedor.dart';
import 'package:inovaeuro/data/app_repository.dart';
import 'chat_empreendedor.dart';
import 'perfil_empreendedor.dart';
import 'bonus_empreendedor.dart';

class EmpreendedorScreen extends StatefulWidget {
  const EmpreendedorScreen({super.key});

  @override
  State<EmpreendedorScreen> createState() => _EmpreendedorScreenState();
}

class _EmpreendedorScreenState extends State<EmpreendedorScreen> {
  final GlobalKey<_BonusStarState> _bonusStarKey = GlobalKey<_BonusStarState>();
  final GlobalKey<LightEmpreendedorState> _lightEmpreendedorKey = GlobalKey<LightEmpreendedorState>();

  void _atualizarProjetos() {
    setState(() {});
  }

  // Novo: callback para atualizar pontos ao voltar da tela de submissão
  void atualizarPontos() {
    setState(() {});
  }
  int _selectedIndex = 0;
  void _abrirDetalhesProjeto(Map<String, dynamic> projeto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(projeto['title'] ?? 'Projeto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Descrição: ${projeto['description'] ?? ''}'),
            const SizedBox(height: 8),
            Text('Categoria: ${projeto['category'] ?? ''}'),
            const SizedBox(height: 8),
            Text('Tempo de conclusão: ${projeto['duration_days'] ?? ''} dias'),
            const SizedBox(height: 8),
            Text('Status: ${projeto['status'] ?? ''}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _onNavItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _onAddPressed() {
    setState(() => _selectedIndex = 1);
  }

  @override
  Widget build(BuildContext context) {
    Widget currentBody;
    switch (_selectedIndex) {
      case 0:
        currentBody = FutureBuilder<List<Map<String, dynamic>>>(
          future: AppRepository.instance.ideiasAprovadasDoUsuario(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final projetos = snapshot.data ?? [];
            if (projetos.isEmpty) {
              return const Center(child: Text('Nenhum projeto aprovado ainda.'));
            }
            return ListView.builder(
              itemCount: projetos.length,
              itemBuilder: (context, index) {
                final projeto = projetos[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(projeto['title'] ?? ''),
                    subtitle: Text('Categoria: ${projeto['category'] ?? ''}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _abrirDetalhesProjeto(projeto),
                  ),
                );
              },
            );
          },
        );
        break;
      case 1:
        currentBody = LightEmpreendedor(
          key: _lightEmpreendedorKey,
          onProjetoAtualizado: () {
            _atualizarProjetos();
            atualizarPontos();
            // Atualiza pontos na estrela
            _bonusStarKey.currentState?.atualizarPontos();
          },
        );
        break;
      case 2:
        if (CurrentUser.instance.id == null) {
          currentBody = const Center(child: CircularProgressIndicator());
        } else {
          currentBody = ChatEmpreendedor(
            empreendedorId: CurrentUser.instance.id!,
            empreendedorNome: CurrentUser.instance.email ?? '',
          );
        }
        break;
      case 3:
        if (CurrentUser.instance.id == null) {
          currentBody = const Center(child: CircularProgressIndicator());
        } else {
          currentBody = BonusEmpreendedor(userId: CurrentUser.instance.id!);
        }
        break;
      case 4:
        currentBody = const PerfilEmpreendedor();
        break;
      default:
        currentBody = Container();
    }

    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              title: const Text('Home Empreendedor'),
              actions: [BonusStar(key: _bonusStarKey)],
            )
          : null,
      body: SafeArea(child: currentBody),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _onAddPressed,
              backgroundColor: Colors.purple,
              child: const Icon(Icons.add, size: 32),
            )
          : null,
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
          BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb_outline), label: 'Ideias'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.laptop_chromebook_outlined),
              label: 'Bonificação'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }
}

class BonusStar extends StatefulWidget {
  const BonusStar({super.key});

  @override
  State<BonusStar> createState() => _BonusStarState();
}

class _BonusStarState extends State<BonusStar> {
  int pontos = CurrentUser.instance.points;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      pontos = CurrentUser.instance.points;
    });
  }

  // Chame este método de fora para atualizar a estrela
  void atualizarPontos() {
    setState(() {
      pontos = CurrentUser.instance.points;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            "$pontos",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
