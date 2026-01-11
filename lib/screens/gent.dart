import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'detall_perfil.dart';

class GentScreen extends StatelessWidget {
  const GentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return SafeArea(
      child: Scaffold(
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No hi ha ningú disponible."));

            final docs = snapshot.data!.docs.where((doc) => doc.id != currentUid).toList();

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final user = UserModel.fromMap(docs[index].data() as Map<String, dynamic>);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user.photoUrls.isNotEmpty
                          ? NetworkImage(user.photoUrls.first)
                          : null,
                      child: user.photoUrls.isEmpty ? const Icon(Icons.person) : null,
                    ),
                    title: Text("${user.nom}, ${user.edat}"),
                    subtitle: Text(
                      user.bio,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    onTap: () => DetallPerfil.mostrar(context, user),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}