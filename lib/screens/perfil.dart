import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../firebase/auth_service.dart';
import '../utils/show_snack_bar.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final AuthService _auth = AuthService();
  final _uid = FirebaseAuth.instance.currentUser?.uid;
  bool _isLoading = false;
  bool _isInitialLoading = true;
  UserModel? _user;

  XFile? _pickedFile;
  Uint8List? _webImageBytes;

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _edatController = TextEditingController();
  List<String> _interessosSeleccionats = [];

  final List<String> _opcionsInteressos = [
    'Castells', 'Pintar', 'Muntanya', 'Cuina', 'Cine', 'Series', 'Gimnàs',
    'Vi i Cava', 'Lectura', 'Esport', 'Música', 'Viatjar', 'Festes Majors', 'Cantar'
  ];

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    if (_uid == null) {
      setState(() => _isInitialLoading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(_uid).get();

      if (doc.exists && doc.data() != null) {
        setState(() {
          _user = UserModel.fromMap(doc.data()!);
          _nomController.text = _user?.nom ?? '';
          _bioController.text = _user?.bio ?? '';
          _edatController.text = _user?.edat != 0 ? _user!.edat.toString() : '';
          _interessosSeleccionats = List<String>.from(_user?.interessos ?? []);
          _isInitialLoading = false;
        });
      } else {
        setState(() => _isInitialLoading = false);
      }
    } catch (e) {
      setState(() => _isInitialLoading = false);
      if (mounted) showSnackBar(context, "Error al carregar: $e", color: Colors.red);
    }
  }

  Future<void> _seleccionarImatge() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _pickedFile = picked;
        _webImageBytes = bytes;
      });
    }
  }

  Future<void> _guardarCanvis() async {
    if (_uid == null) return;
    setState(() => _isLoading = true);

    try {
      final edatInt = int.tryParse(_edatController.text) ?? (_user?.edat ?? 18);

      await _auth.updateFullProfile(
        uid: _uid!,
        data: {
          'nom': _nomController.text.trim(),
          'bio': _bioController.text.trim(),
          'edat': edatInt,
          'interessos': _interessosSeleccionats,
          'photoUrls': _user?.photoUrls ?? [],
        },
        imageFile: _pickedFile,
      );

      if (mounted) {
        showSnackBar(context, "Perfil actualitzat!", color: Colors.green);
        _carregarPerfil();
      }
    } catch (e) {
      if (mounted) showSnackBar(context, "Error al guardar: $e", color: Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    ImageProvider? finalImage;
    if (_webImageBytes != null) {
      finalImage = MemoryImage(_webImageBytes!);
    } else if (_user?.photoUrls.isNotEmpty ?? false) {
      finalImage = NetworkImage(_user!.photoUrls.first);
    }

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GestureDetector(
                onTap: _seleccionarImatge,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: finalImage,
                  child: finalImage == null
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextField(controller: _nomController, decoration: const InputDecoration(labelText: "Nom")),
              TextField(
                controller: _edatController,
                decoration: const InputDecoration(labelText: "Edat"),
                keyboardType: TextInputType.number
              ),
              TextField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: "Biografia"),
                maxLines: 3
              ),
              const SizedBox(height: 25),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Interessos", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Wrap(
                spacing: 8,
                children: _opcionsInteressos.map((i) => FilterChip(
                  label: Text(i),
                  selected: _interessosSeleccionats.contains(i),
                  showCheckmark: false,
                  onSelected: (val) {
                    setState(() {
                      val ? _interessosSeleccionats.add(i) : _interessosSeleccionats.remove(i);
                    });
                  },
                )).toList(),
              ),
              const SizedBox(height: 30),
              _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _guardarCanvis,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    child: const Text("Guardar canvis")
                  ),
              const Divider(height: 50),
              TextButton.icon(
                onPressed: () => _auth.signOut(),
                icon: const Icon(Icons.logout),
                label: const Text("Tancar sessió"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}