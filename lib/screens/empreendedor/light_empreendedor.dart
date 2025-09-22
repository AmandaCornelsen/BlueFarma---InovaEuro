import 'package:flutter/material.dart';
import 'package:inovaeuro/current_user.dart';
import 'package:inovaeuro/data/app_repository.dart';


typedef ProjetoCallback = void Function();

class LightEmpreendedor extends StatefulWidget {
  final ProjetoCallback? onProjetoAtualizado;
  const LightEmpreendedor({super.key, this.onProjetoAtualizado});

  @override
  State<LightEmpreendedor> createState() => LightEmpreendedorState();
}

class LightEmpreendedorState extends State<LightEmpreendedor> {
  final _formKey = GlobalKey<FormState>();
  String nome = '';
  String descricao = '';
  String setor = '';
  String setorOutro = '';
  int? tempoEstimado;

  final List<String> setores = [
    'Tecnologia',
    'Farmácia',
    'Administração',
    'Diretoria',
    'Sustentabilidade',
    'Outro'
  ];

  Future<void> _adicionarIdeia() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      await AppRepository.instance.criarIdeia(
        titulo: nome,
        descricao: descricao,
        categoria: setor == 'Outro' ? setorOutro : setor,
        duracaoDias: tempoEstimado ?? 0,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Projeto submetido com sucesso!')),
      );
      _formKey.currentState?.reset();
      setState(() {
        setor = '';
        setorOutro = '';
      });
      if (widget.onProjetoAtualizado != null) {
        widget.onProjetoAtualizado!();
      }
    }
  }

  Future<List<Map<String, dynamic>>> _getProjetos() async {
    final todas = await AppRepository.instance.ultimasIdeias(100);
    final userId = CurrentUser.instance.id;
    return todas.where((p) => p['user_id'] == userId).toList();
  }

  // Removido botão de aprovação do empreendedor (não faz sentido para o próprio dono)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Empreendedorismo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Submeta sua ideia',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Nome do projeto',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Campo obrigatório' : null,
                    onSaved: (v) => nome = v!,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Descrição da ideia',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    maxLines: 3,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Campo obrigatório' : null,
                    onSaved: (v) => descricao = v!,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Tempo estimado (dias)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Campo obrigatório';
                      if (int.tryParse(v) == null) return 'Digite um número válido';
                      return null;
                    },
                    onSaved: (v) => tempoEstimado = int.tryParse(v!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Setor',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    value: setor.isEmpty ? null : setor,
                    items: setores
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => setor = v ?? ''),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  if (setor == 'Outro') ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Informe o setor',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) {
                        if (setor == 'Outro' && (v == null || v.isEmpty))
                          return 'Campo obrigatório';
                        return null;
                      },
                      onSaved: (v) => setorOutro = v ?? '',
                    ),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _adicionarIdeia,
                    icon: const Icon(Icons.send),
                    label: const Text('Submeter'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text('Projetos submetidos',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 12),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _getProjetos(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final projetos = snapshot.data!;
                if (projetos.isEmpty) {
                  return const Center(
                      child: Text('Nenhum projeto submetido',
                          style: TextStyle(fontSize: 16, color: Colors.grey)));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: projetos.length,
                  itemBuilder: (context, idx) {
                    final item = projetos[idx];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 4,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple,
                          child: const Icon(Icons.lightbulb, color: Colors.white),
                        ),
                        title: Text(item['title'],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Text('Status: ${item['status']}'),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
