import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'chat_screen.dart';

class MissatgesScreen extends StatelessWidget {
  const MissatgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return const Scaffold(body: Center(child: Text("Sessió no iniciada")));

    return SafeArea(
      child: Scaffold(
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('matches')
              .where('users', arrayContains: currentUid)
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("Encara no tens cap match."));
      
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final matchDoc = snapshot.data!.docs[index];
                final List usersIds = matchDoc['users'];
                final otherUid = usersIds.firstWhere((id) => id != currentUid, orElse: () => null);
      
                if (otherUid == null) return const SizedBox.shrink();
      
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(otherUid).get(),
                  builder: (context, userSnap) {
                    if (userSnap.connectionState == ConnectionState.waiting) return const ListTile(title: Text("Carregant..."));
                    if (!userSnap.hasData || !userSnap.data!.exists) return const SizedBox.shrink();
      
                    final user = UserModel.fromMap(userSnap.data!.data() as Map<String, dynamic>);
      
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.photoUrls.isNotEmpty
                            ? NetworkImage(user.photoUrls.first)
                            : null,
                        child: user.photoUrls.isEmpty ? const Icon(Icons.person) : null,
                      ),
                      title: Text(user.nom),
                      subtitle: const Text("Teniu un nou match!"),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(otherUser: user, matchId: matchDoc.id)
                        )
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}