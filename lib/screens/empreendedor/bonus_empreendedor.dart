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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE1BEE7), Color(0xFF7C4DFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text('Bonificação',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7C4DFF),
                      letterSpacing: 1.2,
                    )),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: Colors.white.withOpacity(0.95),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.emoji_events, color: Color(0xFF7C4DFF), size: 32),
                          const SizedBox(width: 10),
                          Text('Resumo', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF7C4DFF))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Pontos acumulados:', style: TextStyle(fontSize: 16, color: Colors.black87)),
                      Text('$pontos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Color(0xFF7C4DFF))),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: (pontos / 2500).clamp(0.0, 1.0),
                        minHeight: 14,
                        backgroundColor: Color(0xFFE1BEE7),
                        color: Color(0xFF7C4DFF),
                      ),
                      const SizedBox(height: 8),
                      Text('Meta: 2500 pontos', style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Benefícios desbloqueados',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF7C4DFF))),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: beneficios.length,
                  itemBuilder: (context, idx) {
                    final b = beneficios[idx];
                    final desbloqueado = pontos >= (b['pts'] as int);
                    return Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: desbloqueado ? Color(0xFFD1C4E9) : Colors.white,
                      child: ListTile(
                        leading: Icon(
                          desbloqueado ? Icons.star : Icons.lock_outline,
                          color: desbloqueado ? Color(0xFF7C4DFF) : Colors.grey,
                          size: 32,
                        ),
                        title: Text(b['titulo'] as String, style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7C4DFF))),
                        subtitle: Text('${b['pts']} pontos', style: TextStyle(color: Colors.black54)),
                        trailing: desbloqueado
                            ? Text("Liberado!",
                                style: TextStyle(
                                    color: Color(0xFF7C4DFF),
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
      ),
    );
  }
}
