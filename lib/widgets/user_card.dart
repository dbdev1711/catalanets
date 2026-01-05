import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../widgets/detall_perfil.dart';

class UserCard extends StatefulWidget {
  final Map<String, dynamic> userData;
  const UserCard({super.key, required this.userData});

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  // Fem servir un controlador propi per a les fotos de cada usuari [cite: 2026-01-05]
  final PageController _cardPageController = PageController();

  @override
  Widget build(BuildContext context) {
    final List<dynamic> photos = widget.userData['photoUrls'] ??
                                (widget.userData['photoUrl'] != null ? [widget.userData['photoUrl']] : []);

    return Stack(
      children: [
        // 1. Galeria HORITZONTAL amb gestos forçats [cite: 2026-01-05]
        Positioned.fill(
          child: RawGestureDetector(
            gestures: {
              AllowMultipleHorizontalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                  AllowMultipleHorizontalDragGestureRecognizer>(
                () => AllowMultipleHorizontalDragGestureRecognizer(),
                (AllowMultipleHorizontalDragGestureRecognizer instance) {
                  instance.onEnd = (_) {}; // Activa el reconeixedor
                },
              ),
            },
            child: PageView.builder(
              controller: _cardPageController,
              scrollDirection: Axis.horizontal,
              // NeverScrollableScrollPhysics perquè el RawGestureDetector farà la feina
              // O usem AlwaysScrollable per assegurar que respon [cite: 2026-01-05]
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => DetallPerfil.mostrar(context, widget.userData),
                  child: Image.network(
                    photos[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[900],
                      child: const Icon(Icons.person, color: Colors.white54, size: 100),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // 2. Indicadors de fotos (Ratlletes)
        if (photos.length > 1)
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Row(
              children: List.generate(photos.length, (index) => Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              )),
            ),
          ),

        // 3. Informació bàsica
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            ignoring: false,
            child: GestureDetector(
              onTap: () => DetallPerfil.mostrar(context, widget.userData),
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
                      "${widget.userData['nom'] ?? 'Anònim'}, ${widget.userData['edat'] ?? '?'}",
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Llisca de costat per fotos • Toca per detalls",
                      style: TextStyle(color: Colors.orange, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Classe auxiliar per permetre múltiples gestos horitzontals alhora [cite: 2026-01-05]
class AllowMultipleHorizontalDragGestureRecognizer extends HorizontalDragGestureRecognizer {
  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }
}