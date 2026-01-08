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
      extendBody: false,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pantalles,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.orange,
            unselectedItemColor: Colors.grey,
            currentIndex: _selectedIndex,
            elevation: 0,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
              BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Gent'),
              BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Xats'),
            ],
          ),
        ),
      ),
    );
  }
}