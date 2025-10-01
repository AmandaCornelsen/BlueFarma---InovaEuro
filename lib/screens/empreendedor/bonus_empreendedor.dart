import 'package:flutter/material.dart';
import 'package:inovaeuro/database_help.dart';

class BonusEmpreendedor extends StatefulWidget {
  final int userId; 

  const BonusEmpreendedor({super.key, required this.userId});

  @override
  State<BonusEmpreendedor> createState() => _BonusEmpreendedorState();
}

class _BonusEmpreendedorState extends State<BonusEmpreendedor> {
  int pontos = 0;

  @override
  void initState() {
    super.initState();
    _loadPontos();
  }

  Future<void> _loadPontos() async {
    final db = DatabaseHelper.instance;
    final dbClient = await db.database;

    final res = await dbClient.query(
      'users',
      where: 'id = ?',
      whereArgs: [widget.userId],
      limit: 1,
    );

    if (res.isNotEmpty) {
      setState(() {
        pontos = res.first['points'] as int;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> beneficios = [
      {'titulo': 'Desconto em cursos', 'pts': 400},
      {'titulo': 'Mentoria exclusiva', 'pts': 600},
      {'titulo': 'Networking VIP', 'pts': 800},
      {'titulo': 'Voucher em tecnologia', 'pts': 1200},
      {'titulo': 'Viagem de inovação', 'pts': 2500},
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Resumo',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text('Pontos acumulados: $pontos',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: (pontos / 2500).clamp(0.0, 1.0),
                      minHeight: 12,
                      backgroundColor: Colors.grey[300],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Benefícios desbloqueados',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: beneficios.length,
                itemBuilder: (context, idx) {
                  final b = beneficios[idx];
                  final desbloqueado = pontos >= (b['pts'] as int);
                  return Card(
                    color: desbloqueado ? Colors.green[100] : Colors.grey[200],
                    child: ListTile(
                      leading: Icon(
                        desbloqueado ? Icons.star : Icons.lock_outline,
                        color: desbloqueado ? Colors.green : Colors.grey,
                      ),
                      title: Text(b['titulo'] as String),
                      subtitle: Text('${b['pts']} pontos'),
                      trailing: desbloqueado
                          ? const Text("Liberado!",
                              style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold))
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
