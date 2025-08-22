import 'package:flutter/material.dart';

class SelecaoScreen extends StatefulWidget {
  const SelecaoScreen({super.key});

  @override
  State<SelecaoScreen> createState() => _SelecaoScreenState();
}

class _SelecaoScreenState extends State<SelecaoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Inova Euro',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
            ),
            ),

            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12
                    ),
                  ),
                  onPressed: () {

                    },
                    child: const Text('Executivo'),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: (const EdgeInsets.symmetric(
                           horizontal: 24, vertical: 12)
                        ),
                        onPressed: () {
                          
                        }, 
                      child: const Text(
                        'Empreendedor',
                        style: TextStyle(color: Colors.black),
                    ),
                  ),  
                ],
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text.rich(
                  TextSpan(
                    text: 'By clicking continue, you agree to our ',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    children: [
                      TextSpan(
                        text: 'Terms of Service',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
                        ),
                        const TextSpan(text: 'and'),
                        TextSpan(
                          text:'Privacy Policy',
                          style: const TextStyle(
                            fontSize: 12,
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
                          ),
                          const TextSpan(text: 'by BlueFarma'),
                    ],
                  ),
                  textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}