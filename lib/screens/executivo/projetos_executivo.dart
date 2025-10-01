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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE1BEE7), Color(0xFF7C4DFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Projetos Executivo'),
          backgroundColor: Color(0xFF7C4DFF),
          elevation: 6,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Projetos Pendentes',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF7C4DFF)),
                  textAlign: TextAlign.center),
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
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 8,
                      color: Colors.white.withOpacity(0.96),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Color(0xFFB388FF),
                                  child: const Icon(Icons.lightbulb_outline, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF7C4DFF))),
                                ),
                              ],
                            ),
                            if (description.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                                child: Text(description, style: TextStyle(fontSize: 15, color: Colors.black87)),
                              ),
                            const SizedBox(height: 6),
                            Text('Status: $status', style: TextStyle(color: Color(0xFF7C4DFF), fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    elevation: 2,
                                  ),
                                  icon: const Icon(Icons.check_circle),
                                  label: const Text('Aprovar'),
                                  onPressed: () => _aprovar(item['id'], item['user_id']),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    elevation: 2,
                                  ),
                                  icon: const Icon(Icons.cancel),
                                  label: const Text('Rejeitar'),
                                  onPressed: () => _rejeitar(item['id']),
                                ),
                              ],
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
      ),
    );
  }
}
