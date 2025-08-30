import 'package:flutter/material.dart';

class ProjetoDetailScreen extends StatelessWidget {
  final String title;
  final String imageUrl;
  final double statusPercent; // Exemplo: 0.0 a 1.0
  final String investimento;

  const ProjetoDetailScreen({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.statusPercent,
    required this.investimento,
  });

  @override
  Widget build(BuildContext context) {
    final percentText = (statusPercent * 100).toStringAsFixed(0) + '%';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imageUrl, fit: BoxFit.cover),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: statusPercent,
                        strokeWidth: 6,
                        color: Colors.purple,
                        backgroundColor: Colors.grey.shade300,
                      ),
                      Center(
                        child: Text(percentText,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: LinearProgressIndicator(
                    value: statusPercent,
                    color: Colors.purple,
                    backgroundColor: Colors.grey.shade300,
                    minHeight: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Investimento: $investimento',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // ação ao adicionar ao dashboard
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Adicionar ao dashboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
