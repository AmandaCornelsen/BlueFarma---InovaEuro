import 'package:flutter/material.dart';
import 'package:inovaeuro/screens/empreendedor/light_empreendedor.dart';
import 'package:inovaeuro/screens/empreendedor/chat_empreendedor.dart';
import 'package:inovaeuro/screens/empreendedor/bonus_empreendedor.dart';
import 'package:inovaeuro/screens/empreendedor/perfil_empreendedor.dart';
import 'store_empreendedor.dart';

class EmpreendedorScreen extends StatefulWidget {
  const EmpreendedorScreen({super.key});

  @override
  State<EmpreendedorScreen> createState() => _EmpreendedorScreenState();
}

class _EmpreendedorScreenState extends State<EmpreendedorScreen> {
  int _selectedIndex = 0;

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
      EmpreendedorStore.instance.projetos.removeAt(idx);
    });
  }

  void _editarProjeto(int idx) async {
    final projeto = EmpreendedorStore.instance.projetos[idx];
    final TextEditingController nomeController = TextEditingController(text: projeto['nome']);
    final TextEditingController descricaoController = TextEditingController(text: projeto['descricao']);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar Projeto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome')),
            const SizedBox(height: 12),
            TextField(controller: descricaoController, decoration: const InputDecoration(labelText: 'Descrição')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                projeto['nome'] = nomeController.text;
                projeto['descricao'] = descricaoController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          )
        ],
      ),
    );
  }

  void _mostrarDetalhes(Map<String, dynamic> projeto) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(projeto['nome']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (projeto.containsKey('imagemUrl') && projeto['imagemUrl'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(projeto['imagemUrl'], height: 120, fit: BoxFit.cover),
              ),
            const SizedBox(height: 12),
            Text('Descrição: ${projeto['descricao']}'),
            const SizedBox(height: 12),
            Text('Status: ${projeto['status']}'),
            if (projeto.containsKey('tempoEstimado'))
              Text('Tempo estimado: ${projeto['tempoEstimado']} dias'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
        ],
      ),
    );
  }

  String getStatus(double percent) {
    if (percent <= 0.33) return 'A começar';
    if (percent <= 0.66) return 'Em andamento';
    return 'Finalizado';
  }

  Color getStatusColor(double percent) {
    if (percent <= 0.33) return Colors.orange;
    if (percent <= 0.66) return Colors.blue;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final projetosAprovados = EmpreendedorStore.instance.getProjetosAprovados();

    Widget currentBody;
    switch (_selectedIndex) {
      case 0:
        currentBody = Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Projetos Aprovados',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: projetosAprovados.isEmpty
                    ? const Center(child: Text('Nenhum projeto aprovado ainda'))
                    : ListView.separated(
                        itemCount: projetosAprovados.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, idx) {
                          final projeto = projetosAprovados[idx];
                          final percent = projeto['statusPercent'] ?? 0.0;
                          final status = getStatus(percent);
                          final statusColor = getStatusColor(percent);

                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                            child: ListTile(
                              leading: projeto.containsKey('imagemUrl') && projeto['imagemUrl'] != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        projeto['imagemUrl'],
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : CircleAvatar(
                                      backgroundColor: Colors.purple.shade100,
                                      child: Text(projeto['nome'][0], style: const TextStyle(color: Colors.white)),
                                    ),
                              title: Text(projeto['nome'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(projeto['descricao'], maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: percent,
                                    minHeight: 8,
                                    color: statusColor,
                                    backgroundColor: Colors.grey[300],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'edit', child: Text('Editar')),
                                  const PopupMenuItem(value: 'delete', child: Text('Excluir')),
                                ],
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    _editarProjeto(EmpreendedorStore.instance.projetos.indexOf(projeto));
                                  } else if (value == 'delete') {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Excluir projeto'),
                                        content: const Text('Tem certeza que deseja excluir este projeto?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
                                          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Excluir')),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      _removerProjeto(EmpreendedorStore.instance.projetos.indexOf(projeto));
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Projeto excluído!')));
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
        currentBody = const LightEmpreendedor();
        break;
      case 2:
        currentBody = const ChatEmpreendedor();
        break;
      case 3:
        currentBody = const BonusEmpreendedor();
        break;
      case 4:
        currentBody = const PerfilEmpreendedor();
        break;
      default:
        currentBody = Container();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Empreendedor'),
        actions: const [BonusStar()],
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb_outline), label: 'Ideias'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.laptop_chromebook_outlined), label: 'Bonificação'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }
}
