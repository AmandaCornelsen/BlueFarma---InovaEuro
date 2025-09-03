import 'package:flutter/material.dart';

class LightEmpreendedor extends StatefulWidget {
  final List<Map<String, dynamic>> ideias;
  final Function(Map<String, dynamic>) onSubmit;

  const LightEmpreendedor({
    super.key,
    required this.ideias,
    required this.onSubmit,
  });

  @override
  State<LightEmpreendedor> createState() => _LightEmpreendedorState();
}

class _LightEmpreendedorState extends State<LightEmpreendedor> {
  final _formKey = GlobalKey<FormState>();
  String nome = '', ideia = '', setor = '';
  DateTime? prazo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Submeta sua ideia', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(decoration: InputDecoration(labelText: 'Nome do projeto'), onChanged: (v) => nome = v),
                TextFormField(decoration: InputDecoration(labelText: 'Ideia'), onChanged: (v) => ideia = v),
                TextFormField(decoration: InputDecoration(labelText: 'Setor'), onChanged: (v) => setor = v),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Prazo (dias)'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => prazo = DateTime.now().add(Duration(days: int.tryParse(v) ?? 0)),
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    final novaIdeia = {
                      'nome': nome,
                      'ideia': ideia,
                      'setor': setor,
                      'prazo': prazo,
                      'status': 'Em análise',
                    };
                    widget.onSubmit(novaIdeia);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ideia submetida!')));
                  },
                  child: Text('Submeter'),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: widget.ideias.isEmpty
                ? Center(child: Text('Nenhuma ideia submetida'))
                : ListView.builder(
                    itemCount: widget.ideias.length,
                    itemBuilder: (context, idx) {
                      final item = widget.ideias[idx];
                      return Card(
                        child: ListTile(
                          title: Text(item['nome']),
                          subtitle: Text('Status: ${item['status']}'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}