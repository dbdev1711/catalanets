import 'package:flutter/material.dart';
import '../widgets/detall_perfil.dart';

class UserCard extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserCard({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> photos = userData['photoUrls'] ??
        (userData['photoUrl'] != null ? [userData['photoUrl']] : []);
    final List<dynamic> interessos = userData['interessos'] ?? [];

    return GestureDetector(
      onTap: () => DetallPerfil.mostrar(context, userData),
      child: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          children: [
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
                    colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
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

                    if (userData['ubicacioNom'] != null && userData['ubicacioNom'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.orange, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              userData['ubicacioNom'],
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 12),

                    if (interessos.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: interessos.take(3).map((interes) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            interes.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        )).toList(),
                      ),

                    const SizedBox(height: 12),
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