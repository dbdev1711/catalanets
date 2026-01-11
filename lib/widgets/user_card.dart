import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../screens/detall_perfil.dart';

class UserCard extends StatelessWidget {
  final UserModel user;

  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: user.photoUrls.isNotEmpty
              ? NetworkImage(user.photoUrls.first)
              : const AssetImage('assets/barretina.png') as ImageProvider,
        ),
        title: Text(
          '${user.nom}, ${user.edat}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          user.bio.isNotEmpty ? user.bio : "Sense descripció",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          DetallPerfil.mostrar(context, user);
        },
      ),
    );
  }
}