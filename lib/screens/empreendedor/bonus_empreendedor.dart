import 'package:flutter/material.dart';

class BonusEmpreendedor extends StatelessWidget {
  final int enviados;
  final int aprovados;
  final int pontos;

  const BonusEmpreendedor({
    super.key,
    required this.enviados,
    required this.aprovados,
    required this.pontos,
  });

  @override
  Widget build(BuildContext context) {
    List<String> beneficios = [
      if (pontos >= 100) 'Desconto em cursos',
      if (pontos >= 200) 'Mentoria exclusiva',
      if (pontos >= 300) 'Networking VIP',
    ];

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard de Bonificação', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('Projetos enviados: $enviados'),
          Text('Projetos aprovados: $aprovados'),
          Text('Pontos acumulados: $pontos', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          LinearProgressIndicator(value: pontos / 500),
          SizedBox(height: 12),
          Text('Benefícios desbloqueados:', style: TextStyle(fontWeight: FontWeight.bold)),
          ...beneficios.map((b) => ListTile(title: Text(b))),
        ],
      ),
    );
  }
}