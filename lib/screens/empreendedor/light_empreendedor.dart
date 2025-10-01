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
          title: const Text('Submeta sua ideia'),
          backgroundColor: Color(0xFF7C4DFF),
          elevation: 6,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 10,
                color: Colors.white.withOpacity(0.97),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Nome do projeto',
                            prefixIcon: Icon(Icons.lightbulb, color: Color(0xFF7C4DFF)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            filled: true,
                            fillColor: Color(0xFFE1BEE7),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
                          onSaved: (v) => nome = v!,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Descrição da ideia',
                            prefixIcon: Icon(Icons.description, color: Color(0xFF7C4DFF)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            filled: true,
                            fillColor: Color(0xFFE1BEE7),
                          ),
                          maxLines: 3,
                          validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
                          onSaved: (v) => descricao = v!,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Tempo estimado (dias)',
                            prefixIcon: Icon(Icons.timer, color: Color(0xFF7C4DFF)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            filled: true,
                            fillColor: Color(0xFFE1BEE7),
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
                            prefixIcon: Icon(Icons.business, color: Color(0xFF7C4DFF)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            filled: true,
                            fillColor: Color(0xFFE1BEE7),
                          ),
                          value: setor.isEmpty ? null : setor,
                          items: setores.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (v) => setState(() => setor = v ?? ''),
                          validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
                        ),
                        if (setor == 'Outro') ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Informe o setor',
                              prefixIcon: Icon(Icons.edit, color: Color(0xFF7C4DFF)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              filled: true,
                              fillColor: Color(0xFFE1BEE7),
                            ),
                            validator: (v) {
                              if (setor == 'Outro' && (v == null || v.isEmpty)) return 'Campo obrigatório';
                              return null;
                            },
                            onSaved: (v) => setorOutro = v ?? '',
                          ),
                        ],
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF7C4DFF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                          ),
                          onPressed: _adicionarIdeia,
                          icon: const Icon(Icons.send),
                          label: const Text('Submeter', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text('Projetos submetidos',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7C4DFF)),
                  textAlign: TextAlign.center),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 6,
                        color: Colors.white.withOpacity(0.96),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color(0xFF7C4DFF),
                            child: const Icon(Icons.lightbulb, color: Colors.white),
                          ),
                          title: Text(item['title'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF7C4DFF))),
                          subtitle: Text('Status: ${item['status']}', style: TextStyle(color: Colors.black87)),
                        ),
                      );
                    },
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
