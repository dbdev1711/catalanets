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
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where(FieldPath.documentId, isNotEqualTo: _currentUserId)
              .where('perfilComplet', isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              );
            }

            final users = snapshot.data?.docs ?? [];

            if (users.isEmpty) {
              return const Center(
                child: Text(
                  "No hi ha ningú més a prop",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              );
            }

            return PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              itemCount: users.length,
              onPageChanged: (index) {
                bool haAnatAvall = index > _currentIndex;
                _registrarInteraccio(users[_currentIndex].id, haAnatAvall);
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final data = users[index].data() as Map<String, dynamic>;
                return UserCard(userData: data);
              },
            );
          },
        ),
      ),
    );
  }
}