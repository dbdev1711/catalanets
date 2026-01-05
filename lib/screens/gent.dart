import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/user_card.dart';

class Gent extends StatefulWidget {
  const Gent({super.key});

  @override
  State<Gent> createState() => _GentState();
}

class _GentState extends State<Gent> {
  final PageController _pageController = PageController();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  int _currentIndex = 0;

  // Funció per registrar la interacció a la base de dades [cite: 2025-12-30]
  Future<void> _registrarInteraccio(String targetUserId, bool isLike) async {
    if (_currentUserId == null) return;

    final String col = isLike ? 'likes' : 'dislikes';

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUserId)
        .collection(col)
        .doc(targetUserId)
        .set({
          'timestamp': FieldValue.serverTimestamp(),
        });

    // Aquí podries afegir la lògica per comprovar si hi ha un Match!
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<QuerySnapshot>(
        // Agafem els usuaris que NO som nosaltres i que tenen el perfil complet
        stream: FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, isNotEqualTo: _currentUserId)
            .where('perfilComplet', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }

          final users = snapshot.data?.docs ?? [];

          if (users.isEmpty) {
            return const Center(
              child: Text("No hi ha ningú més a prop",
                style: TextStyle(color: Colors.white70, fontSize: 16))
            );
          }

          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical, // Scroll vertical per canviar d'usuari
            physics: const BouncingScrollPhysics(),
            itemCount: users.length,
            onPageChanged: (index) {
              // Quan l'usuari canvia de pàgina, detectem si ha anat cap avall o cap amunt
              bool haAnatAvall = index > _currentIndex;

              // Opcional: Registrar automàticament com a Like si va cap avall
              // o Dislike si va cap amunt (estil vertical Tinder)
              _registrarInteraccio(users[_currentIndex].id, haAnatAvall);

              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final data = users[index].data() as Map<String, dynamic>;

              return Container(
                // Marges per respectar la BottomNavBar blanca que veiem a les fotos
                margin: const EdgeInsets.only(bottom: kBottomNavigationBarHeight),
                child: UserCard(userData: data),
              );
            },
          );
        },
      ),
    );
  }
}