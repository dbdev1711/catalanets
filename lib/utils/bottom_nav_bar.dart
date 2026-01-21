import 'package:flutter/material.dart';
import '../screens/perfil.dart';
import '../screens/gent.dart';
import '../screens/missatges.dart';

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
    const MissatgesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pantalles,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 90,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.orange[800],
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          elevation: 0,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Gent'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Missatges'),
          ],
        ),
      ),
    );
  }
}