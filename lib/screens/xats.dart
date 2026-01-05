import 'package:flutter/material.dart';

class Xats extends StatelessWidget {
  const Xats({super.key});

  @override
  Widget build(BuildContext context) {
    // Retornem Material per evitar el conflicte de Scaffolds que tapa la barra a Chrome [cite: 2026-01-05]
    return Material(
      color: Colors.white,
      child: Column(
        children: [
          // Capçalera manual per substituir l'AppBar [cite: 2026-01-05]
          AppBar(
            title: const Text('Xats'),
            automaticallyImplyLeading: false, // Evita que surti la fletxa de tornar enrere
          ),
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    "Aquí veuràs els teus missatges",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}