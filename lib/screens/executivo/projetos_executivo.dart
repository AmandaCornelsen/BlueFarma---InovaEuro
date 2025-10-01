import 'package:flutter/material.dart';
import 'package:inovaeuro/data/app_repository.dart';


typedef ProjetoCallback = void Function();

class ExecutivoProjetos extends StatefulWidget {
  final ProjetoCallback? onProjetoAprovadoOuRejeitado;
  const ExecutivoProjetos({super.key, this.onProjetoAprovadoOuRejeitado});

  @override
  State<ExecutivoProjetos> createState() => _ExecutivoProjetosState();
}

class _ExecutivoProjetosState extends State<ExecutivoProjetos> {
  List<Map<String, dynamic>> ideiasPendentes = [];

  @override
  void initState() {
    super.initState();
    _loadIdeias();
  }

  Future<void> _loadIdeias() async {
    try {
      final list = await AppRepository.instance.ideiasPendentes();
      setState(() {
        ideiasPendentes = list;
      });
    } catch (e) {
      setState(() {
        ideiasPendentes = [];
      });
      debugPrint("Erro ao carregar ideias: $e");
    }
  }

  Future<void> _aprovar(int ideiaId, int autorId) async {
    await AppRepository.instance.aprovarIdeia(
      ideiaId: ideiaId,
      executivoId: 0, // pode substituir pelo id do executivo logado se desejar
      empreendedorId: autorId,
    );
    await _loadIdeias();
    if (widget.onProjetoAprovadoOuRejeitado != null) {
      widget.onProjetoAprovadoOuRejeitado!();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Projeto aprovado!')),
    );
  }

  Future<void> _rejeitar(int ideiaId) async {
    await AppRepository.instance.rejeitarIdeia(ideiaId);
    await _loadIdeias();
    if (widget.onProjetoAprovadoOuRejeitado != null) {
      widget.onProjetoAprovadoOuRejeitado!();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Projeto rejeitado!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projetos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Projetos Pendentes',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            const SizedBox(height: 20),
            if (ideiasPendentes.isEmpty)
              const Center(
                child: Text('Nenhuma ideia pendente',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ideiasPendentes.length,
                itemBuilder: (context, index) {
                  final item = ideiasPendentes[index];
                  final title = item['title'] ?? 'Sem título';
                  final description = item['description'] ?? '';
                  final status = item['status'] ?? 'Pendente';
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: const Icon(Icons.lightbulb_outline, color: Colors.white),
                      ),
                      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (description.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(description, style: const TextStyle(fontSize: 14)),
                            ),
                          Text('Status: $status'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            onPressed: () => _aprovar(item['id'], item['user_id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () => _rejeitar(item['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
