import 'package:flutter/material.dart';
import '../widgets/detall_perfil.dart';

class UserCard extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserCard({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    // Sincronització de fotos: usem photoUrls que és la llista de Firestore [cite: 2026-01-05]
    final List<dynamic> photos = userData['photoUrls'] ??
                                (userData['photoUrl'] != null ? [userData['photoUrl']] : []);

    return GestureDetector(
      // CRIDA AL NOU WIDGET: Obrim el detall que hem creat abans [cite: 2026-01-05]
      onTap: () => DetallPerfil.mostrar(context, userData),
      child: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          children: [
            // 1. Galeria d'imatges
            PageView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              itemBuilder: (context, index) {
                return Image.network(
                  photos[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[900],
                    child: const Icon(Icons.person, color: Colors.white54, size: 100),
                  ),
                );
              },
            ),

            // 2. Indicadors de fotos
            if (photos.length > 1)
              Positioned(
                top: 20,
                left: 10,
                right: 10,
                child: Row(
                  children: List.generate(photos.length, (index) => Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  )),
                ),
              ),

            // 3. Informació bàsica (Nom i Edat) [cite: 2026-01-05]
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${userData['nom'] ?? 'Anònim'}, ${userData['edat'] ?? '?'}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                      ),
                    ),
                    if (userData['tipusRelacio'] != null)
                      Text(
                        userData['tipusRelacio'],
                        style: const TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                    const SizedBox(height: 8),
                    const Text(
                      "Toca per veure més detalls",
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}