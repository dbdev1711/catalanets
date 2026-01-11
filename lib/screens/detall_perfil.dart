import 'package:flutter/material.dart';
import '../models/user_model.dart';

class DetallPerfil {

  static void mostrar(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF121212),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    if (user.photoUrls.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 25),
                        child: SizedBox(
                          height: 350,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: user.photoUrls.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 280,
                                margin: const EdgeInsets.only(right: 15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image: NetworkImage(user.photoUrls[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                    Text(
                      "${user.nom}, ${user.edat}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),

                    _buildInfoTile(Icons.notes, "Bio", user.bio),

                    const SizedBox(height: 30),
                    const Text(
                      "Interessos",
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),

                    Wrap(
                      spacing: 10,
                      children: user.interessos.map((i) => Chip(label: Text(i))).toList(),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildInfoTile(IconData icon, String title, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return ListTile(
      leading: Icon(icon, color: Colors.orange),
      title: Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      subtitle: Text(value, style: const TextStyle(color: Colors.white, fontSize: 16)),
    );
  }
}