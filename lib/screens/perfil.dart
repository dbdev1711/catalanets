import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../firebase/auth_service.dart';
import '../utils/show_snack_bar.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  final AuthService _auth = AuthService();
  final _uid = FirebaseAuth.instance.currentUser?.uid;
  bool _isLoading = false;
  bool _isInitialLoading = true;
  UserModel? _user;

  List<dynamic> _photos = List.filled(4, null);

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _edatController = TextEditingController();
  List<String> _interessosSeleccionats = [];

  String _fuma = '';
  String _beu = '';
  String _exercici = '';
  String _animals = '';
  String _fills = '';
  String _volFills = '';
  String _alimentacio = '';

  final List<String> _opcionsInteressos = [
    'Castells', 'Pintar', 'Muntanya', 'Cuina', 'Cine', 'Series', 'Gimnàs',
    'Vi - Cava', 'Lectura', 'Escalada', 'Música', 'Viatjar', 'Museus', 'Cantar', 'Ballar',
    'Fotografia', 'Videojocs', 'Tecnologia', 'Ioga', 'Atletisme', 'Ciclisme', 'Cartes',
    'Gastronomia', 'Teatre', 'Escacs', 'Tenis', 'Historia', 'Politica', 'Animals',
    'Jardineria', 'Idiomes', 'Voluntariat', 'Platja', 'Esquí', 'Bricolatge', 'Pàdel'
  ];

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    if (_uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(_uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          _user = UserModel.fromMap(data);
          _nomController.text = data['nom'] ?? '';
          _edatController.text = (_user?.edat != null && _user!.edat != 0) ? _user!.edat.toString() : '';
          _interessosSeleccionats = List<String>.from(data['interessos'] ?? []);

          List<String> savedPhotos = List<String>.from(data['photoUrls'] ?? []);
          for (int i = 0; i < savedPhotos.length && i < 4; i++) {
            _photos[i] = savedPhotos[i];
          }

          _fuma = data['fuma'] ?? '';
          _beu = data['beu'] ?? '';
          _exercici = data['exercici'] ?? '';
          _animals = data['animals'] ?? '';
          _fills = data['fills'] ?? '';
          _volFills = data['volFills'] ?? '';
          _alimentacio = data['alimentacio'] ?? '';
          _isInitialLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isInitialLoading = false);
    }
  }

  Future<void> _pickImage(int index) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (picked != null) {
      setState(() => _photos[index] = picked);
    }
  }

  Future<void> _guardarCanvis() async {
    if (_uid == null) return;
    setState(() => _isLoading = true);
    try {
      await _auth.updateFullProfile(
        uid: _uid!,
        data: {
          'nom': _nomController.text.trim(),
          'edat': int.tryParse(_edatController.text) ?? 0,
          'interessos': _interessosSeleccionats,
          'fuma': _fuma, 'beu': _beu, 'exercici': _exercici,
          'animals': _animals, 'fills': _fills, 'volFills': _volFills,
          'alimentacio': _alimentacio,
          'photoUrls': _photos.whereType<String>().toList(),
        },
        imageFile: _photos.firstWhere((p) => p is XFile, orElse: () => null),
      );
      if (mounted) {
        showSnackBar(context, "Perfil actualitzat!", color: Colors.green);
        _carregarPerfil();
      }
    } catch (e) {
      if (mounted) showSnackBar(context, "Error al guardar", color: Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildPhotoTile(int index) {
    dynamic photo = _photos[index];
    return GestureDetector(
      onTap: () => _pickImage(index),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
          image: photo != null
            ? DecorationImage(
                image: photo is XFile ? FileImage(File(photo.path)) : NetworkImage(photo) as ImageProvider,
                fit: BoxFit.cover)
            : null,
        ),
        child: photo == null ? const Icon(Icons.add_a_photo, color: Colors.grey) : null,
      ),
    );
  }

  Widget _buildDropdown(String titol, String valorActual, List<String> opcions, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titol, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        DropdownButtonFormField<String>(
          value: valorActual.isEmpty ? null : valorActual,
          isExpanded: true,
          items: opcions.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(contentPadding: EdgeInsets.zero),
          hint: const Text(""),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
                itemCount: 4,
                itemBuilder: (context, index) => _buildPhotoTile(index),
              ),
              const SizedBox(height: 25),
              TextField(controller: _nomController, decoration: const InputDecoration(labelText: "Nom")),
              TextField(controller: _edatController, decoration: const InputDecoration(labelText: "Edat"), keyboardType: TextInputType.number),
              const SizedBox(height: 25),
              const Align(alignment: Alignment.centerLeft, child: Text("Estil de vida", style: TextStyle(fontWeight: FontWeight.bold))),
              const SizedBox(height: 10),
              _buildDropdown("Fumes?", _fuma, ['No', 'Socialment', 'Sí'], (v) => setState(() => _fuma = v!)),
              _buildDropdown("Beus?", _beu, ['No', 'Socialment', 'Sí'], (v) => setState(() => _beu = v!)),
              _buildDropdown("Fas exercici?", _exercici, ['Mai', 'A vegades', 'Sovint'], (v) => setState(() => _exercici = v!)),
              _buildDropdown("Tens animals?", _animals, ['No', 'Gat', 'Gos', 'Altres'], (v) => setState(() => _animals = v!)),
              _buildDropdown("Tens fills?", _fills, ['No', 'Sí'], (v) => setState(() => _fills = v!)),
              _buildDropdown("Vols fills?", _volFills, ['No', 'Sí', 'No ho sé'], (v) => setState(() => _volFills = v!)),
              _buildDropdown("Alimentacio?", _alimentacio, ['De tot', 'Vegetarià/ana', 'Vegà/ana', 'Celíac/a', 'Altres'], (v) => setState(() => _alimentacio = v!)),
              const SizedBox(height: 25),
              const Align(alignment: Alignment.centerLeft, child: Text("Interessos", style: TextStyle(fontWeight: FontWeight.bold))),
              const SizedBox(height: 15),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.0,
                ),
                itemCount: _opcionsInteressos.length,
                itemBuilder: (context, index) {
                  final interes = _opcionsInteressos[index];
                  final seleccionat = _interessosSeleccionats.contains(interes);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        seleccionat ? _interessosSeleccionats.remove(interes) : _interessosSeleccionats.add(interes);
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: seleccionat ? Colors.orange[100] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: seleccionat ? Colors.orange : Colors.transparent, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          interes,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: seleccionat ? FontWeight.bold : FontWeight.normal,
                            color: seleccionat ? Colors.orange[900] : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              _isLoading ? const CircularProgressIndicator() : ElevatedButton(
                onPressed: _guardarCanvis,
                style: ElevatedButton.styleFrom(minimumSize: const Size(150, 50)),
                child: const Text("Guardar canvis", style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _auth.signOut(),
                    icon: const Icon(Icons.logout, color: Colors.grey),
                    label: const Text("Tancar sessió", style: TextStyle(color: Colors.grey, fontSize: 18)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}