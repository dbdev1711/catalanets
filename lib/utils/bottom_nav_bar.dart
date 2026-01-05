import 'package:flutter/material.dart';
import '../screens/perfil.dart';
import '../screens/gent.dart';
import '../screens/xats.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 1;

  final List<Widget> _pantalles = [
    const Perfil(),
    const Gent(),
    const Xats(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Forcem que el contingut no passi per sota de la barra [cite: 2026-01-05]
      extendBody: false,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pantalles,
      ),
      bottomNavigationBar: Container(
        // Afegim una vora superior per separar clarament del fons negre de Gent
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white12, width: 0.5)),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // Vital per a Chrome [cite: 2026-01-05]
          backgroundColor: Colors.white,
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Gent'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Xats'),
          ],
        ),
      ),
    );
  }
}