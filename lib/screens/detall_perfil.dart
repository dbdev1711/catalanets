import 'package:flutter/material.dart';
import '../models/user_model.dart';

class DetallPerfil {
  static void mostrar(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Color(0xFF121212), // Fons fosc del modal
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Foto de perfil
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: user.photoUrls.isNotEmpty
                            ? Image.network(
                                user.photoUrls.first,
                                width: double.infinity,
                                height: 450,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: 300,
                                width: double.infinity,
                                color: Colors.grey[900],
                                child: const Icon(Icons.person, size: 100, color: Colors.white),
                              ),
                      ),
                      const SizedBox(height: 24),

                      // Nom, Edat i Sexe
                      Text(
                        // He afegit el sexe al costat del nom i edat si existeix
                        "${user.nom}, ${user.edat ?? '??'}${user.sexe != null && user.sexe!.isNotEmpty ? ' (${user.sexe})' : ''}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Secció "Busco" (Destacada)
                      if (user.busco != null && user.busco!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.search, color: Colors.orangeAccent, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "Busco: ${user.busco}",
                                style: const TextStyle(
                                  color: Colors.orangeAccent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 30),
                      const Text(
                        "Estil de vida",
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      Wrap(
                        spacing: 10,
                        runSpacing: 12,
                        children: [
                          if (user.fuma.isNotEmpty) _buildTag(Icons.smoking_rooms, "Fuma: ${user.fuma}"),
                          if (user.beu.isNotEmpty) _buildTag(Icons.local_bar, "Beu: ${user.beu}"),
                          if (user.exercici.isNotEmpty) _buildTag(Icons.fitness_center, "Exercici: ${user.exercici}"),
                          if (user.animals.isNotEmpty) _buildTag(Icons.pets, "Animals: ${user.animals}"),
                          if (user.fills.isNotEmpty) _buildTag(Icons.child_care, "Fills: ${user.fills}"),
                          if (user.volFills.isNotEmpty) _buildTag(Icons.favorite, "Vol fills: ${user.volFills}"),
                          if (user.alimentacio.isNotEmpty) _buildTag(Icons.restaurant, "Alimentació: ${user.alimentacio}"),
                        ],
                      ),

                      const SizedBox(height: 30),
                      const Text(
                        "Interessos",
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: user.interessos.map((i) => Chip(
                          label: Text(
                            i,
                            style: const TextStyle(
                              color: Colors.brown,
                              fontSize: 14,
                              fontWeight: FontWeight.bold
                            )
                          ),
                          backgroundColor: const Color(0xFFFDF0E9),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        )).toList(),
                      ),

                      const SizedBox(height: 30),
                      const Text(
                        "Sobre mi",
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.bio.isEmpty ? "Sense descripció." : user.bio,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.5
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.orangeAccent, size: 18),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}