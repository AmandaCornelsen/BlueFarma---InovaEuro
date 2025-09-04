import 'package:flutter/material.dart';
import 'store_empreendedor.dart';

class BonusEmpreendedor extends StatelessWidget {
  const BonusEmpreendedor({super.key});

  @override
  Widget build(BuildContext context) {
    final pontos = EmpreendedorStore.instance.pontosGlobais;

    List<Map<String, dynamic>> beneficios = [
      {'titulo': 'Desconto em cursos', 'pts': 100},
      {'titulo': 'Mentoria exclusiva', 'pts': 200},
      {'titulo': 'Networking VIP', 'pts': 300},
      {'titulo': 'Voucher em tecnologia', 'pts': 400},
      {'titulo': 'Viagem de inovação', 'pts': 500},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Bonificação'),
        actions: [BonusStar()],
      ),
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
                    Text('Pontos acumulados: $pontos', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: (pontos / 500).clamp(0.0, 1.0),
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
                          ? const Text("Liberado!", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
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

/// Widget global da estrela
class BonusStar extends StatefulWidget {
  const BonusStar({super.key});

  @override
  State<BonusStar> createState() => _BonusStarState();
}

class _BonusStarState extends State<BonusStar> {
  @override
  Widget build(BuildContext context) {
    final pontos = EmpreendedorStore.instance.pontosGlobais;
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
