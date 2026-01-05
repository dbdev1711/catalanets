import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../firebase/auth_service.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  final User? user = FirebaseAuth.instance.currentUser;
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<File?> _images = [null, null, null, null];
  List<String> _existingUrls = [];
  bool _isSaving = false;
  bool _isLoading = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _edatController = TextEditingController();

  String? _genere, _interes, _vullConeixer, _tipusRelacio, _fumes, _beus, _drogues, _tensFills, _volsFills, _religio, _politica;
  List<String> _interessosSeleccionats = [];

  final List<Map<String, String>> _opcionsInteressos = [
    {'nom': 'Castellers', 'emoji': '🏰'}, {'nom': 'Platja', 'emoji': '🏖️'},
    {'nom': 'Escalada', 'emoji': '🧗'}, {'nom': 'Gimnàs', 'emoji': '🏋️'},
    {'nom': 'Nutrició', 'emoji': '🥗'}, {'nom': 'Futbol', 'emoji': '⚽'},
    {'nom': 'Motos', 'emoji': '🏍️'}, {'nom': 'Música', 'emoji': '🎶'},
    {'nom': 'Cuina', 'emoji': '🍳'}, {'nom': 'Muntanya', 'emoji': '🏔️'},
    {'nom': 'Lectura', 'emoji': '📚'}, {'nom': 'Viatjar', 'emoji': '✈️'},
    {'nom': 'Esport', 'emoji': '🏃'}, {'nom': 'Cinema', 'emoji': '🎬'},
    {'nom': 'Tecnologia', 'emoji': '💻'}, {'nom': 'Animals', 'emoji': '🐾'},
    {'nom': 'Fotografia', 'emoji': '📸'}, {'nom': 'Ballar', 'emoji': '💃'},
  ];

  @override
  void initState() {
    super.initState();
    _carregarDadesUsuari();
  }

  Future<void> _carregarDadesUsuari() async {
    if (user == null) return;
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user!.uid).get();
      if (doc.exists && mounted) {
        Map<String, dynamic> dades = doc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = dades['nom'] ?? "";
          _edatController.text = dades['edat']?.toString() ?? "";
          _genere = dades['genere'];
          _interes = dades['interes'];
          _vullConeixer = dades['vullConeixer'];
          _tipusRelacio = dades['tipusRelacio'];
          _fumes = dades['fumes'];
          _beus = dades['beus'];
          _drogues = dades['drogues'];
          _tensFills = dades['tensFills'];
          _volsFills = dades['volsFills'];
          _religio = dades['religio'];
          _politica = dades['politica'];
          _existingUrls = List<String>.from(dades['photoUrls'] ?? []);
          _interessosSeleccionats = List<String>.from(dades['interessos'] ?? []);
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(int index) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 70);
    if (pickedFile != null && mounted) {
      setState(() => _images[index] = File(pickedFile.path));
    }
  }

  void _gestionarInteres(String nom) {
    setState(() {
      if (_interessosSeleccionats.contains(nom)) {
        _interessosSeleccionats.remove(nom);
      } else if (_interessosSeleccionats.length < 4) {
        _interessosSeleccionats.add(nom);
      }
    });
  }

  Future<void> _guardarPerfil() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    try {
      final Map<String, dynamic> dades = {
        'nom': _nameController.text.trim(),
        'edat': _edatController.text.trim(),
        'genere': _genere,
        'interes': _interes,
        'vullConeixer': _vullConeixer,
        'tipusRelacio': _tipusRelacio,
        'interessos': _interessosSeleccionats,
        'fumes': _fumes,
        'beus': _beus,
        'drogues': _drogues,
        'tensFills': _tensFills,
        'volsFills': _volsFills,
        'religio': _religio,
        'politica': _politica,
        'perfilComplet': true,
      };

      await _authService.updateFullProfile(
        uid: user!.uid,
        data: dades,
        imageFiles: _images,
      ).timeout(const Duration(seconds: 60));

      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guardat correctament!'), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Retornem un Container/Material per evitar que el Scaffold de Perfil tapi la BottomNavBar del pare [cite: 2026-01-05]
    if (_isLoading) return const Material(child: Center(child: CircularProgressIndicator(color: Colors.orange)));

    return Material(
      color: Colors.white,
      child: Column(
        children: [
          // Capçalera manual per substituir l'AppBar del Scaffold
          AppBar(
            title: const Text('Perfil'),
            automaticallyImplyLeading: false,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📸 Les meves fotos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _pickImage(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(15),
                            image: _images[index] != null
                                ? DecorationImage(image: FileImage(_images[index]!), fit: BoxFit.cover)
                                : (index < _existingUrls.length ? DecorationImage(image: NetworkImage(_existingUrls[index]), fit: BoxFit.cover) : null),
                          ),
                          child: (_images[index] == null && index >= _existingUrls.length)
                              ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                              : null,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  TextField(controller: _nameController, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: '👤 Nom', border: OutlineInputBorder())),
                  const SizedBox(height: 20),
                  TextField(controller: _edatController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '🎂 Edat', border: OutlineInputBorder())),
                  const SizedBox(height: 20),
                  _buildDropdown('Gènere', '🌈', _genere, ['Dona', 'Home', 'Non-binari'], (v) => setState(() => _genere = v)),
                  _buildDropdown('Interès', '🔍', _interes, ['Dones', 'Homes', 'Tothom'], (v) => setState(() => _interes = v)),
                  _buildDropdown('Busco', '🤝', _vullConeixer, ['Amistat', 'Parella', 'El que sorgeixi'], (v) => setState(() => _vullConeixer = v)),
                  _buildDropdown('Relació', '💍', _tipusRelacio, ['Amistat', 'Oberta', 'Monògama', 'No ho tinc clar'], (v) => setState(() => _tipusRelacio = v)),
                  const SizedBox(height: 20),
                  const Text('🎭 Interessos (Màxim 4)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, children: _opcionsInteressos.map((i) {
                      final sel = _interessosSeleccionats.contains(i['nom']);
                      return FilterChip(label: Text('${i['emoji']} ${i['nom']}'), selected: sel, onSelected: (_) => _gestionarInteres(i['nom']!));
                    }).toList()),
                  const SizedBox(height: 25),
                  _buildDropdown('Fumes?', '🚬', _fumes, ['Sí', 'No', 'Socialment'], (v) => setState(() => _fumes = v)),
                  _buildDropdown('Beus?', '🍺', _beus, ['Sí', 'No', 'Socialment'], (v) => setState(() => _beus = v)),
                  _buildDropdown('Drogues?', '💊', _drogues, ['Sí', 'No'], (v) => setState(() => _drogues = v)),
                  _buildDropdown('Tens fills?', '👶', _tensFills, ['Sí', 'No'], (v) => setState(() => _tensFills = v)),
                  _buildDropdown('Vols fills?', '🍼', _volsFills, ['Sí', 'No', 'No ho sé'], (v) => setState(() => _volsFills = v)),
                  _buildDropdown('Religió', '🙏', _religio, ['Ateu/Agnòstic', 'Catòlic', 'Musulmà', 'Altres'], (v) => setState(() => _religio = v)),
                  _buildDropdown('Política', '🗳️', _politica, ['Esquerra', 'Centre', 'Dreta', 'Apolític'], (v) => setState(() => _politica = v)),
                  const SizedBox(height: 40),
                  SizedBox(width: double.infinity, height: 55, child: ElevatedButton(
                    onPressed: _isSaving ? null : _guardarPerfil,
                    child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('Guardar')
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String emoji, String? value, List<String> options, Function(String?) onChanged) {
    return Padding(padding: const EdgeInsets.only(bottom: 20), child: DropdownButtonFormField<String>(
        initialValue: options.contains(value) ? value : null,
        decoration: InputDecoration(labelText: '$emoji $label', border: const OutlineInputBorder()),
        items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
        onChanged: onChanged,
      ));
  }
}