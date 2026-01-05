import 'package:flutter/material.dart';

class UserProfileDetails extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserProfileDetails({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    List<String> photos = List<String>.from(userData['photoUrls'] ?? []);
    List<String> interessos = List<String>.from(userData['interessos'] ?? []);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fotos en format gran
            SizedBox(
              height: 450,
              child: PageView.builder(
                itemCount: photos.isNotEmpty ? photos.length : 1,
                itemBuilder: (context, index) {
                  return photos.isNotEmpty
                    ? Image.network(photos[index], fit: BoxFit.cover)
                    : Container(color: Colors.grey[200]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${userData['nom']}, ${userData['edat']}",
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),

                  const Text("🎭 Interessos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: interessos.map((i) => Chip(
                      label: Text(i),
                      backgroundColor: Colors.orange[50],
                      side: BorderSide(color: Colors.orange.shade200),
                    )).toList(),
                  ),

                  const Divider(height: 40),

                  _buildInfoTile("🎯 Busca", userData['vullConeixer'], Icons.search),
                  _buildInfoTile("💍 Tipus de relació", userData['tipusRelacio'], Icons.favorite),
                  _buildInfoTile("🚬 Tabac", userData['fumes'], Icons.smoke_free),
                  _buildInfoTile("🍺 Alcohol", userData['beus'], Icons.local_bar),
                  _buildInfoTile("🗳️ Política", userData['politica'], Icons.how_to_vote),
                  _buildInfoTile("🙏 Religió", userData['religio'], Icons.church),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, dynamic value, IconData icon) {
    if (value == null || value == "") return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.orange),
          const SizedBox(width: 15),
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value.toString()),
        ],
      ),
    );
  }
}