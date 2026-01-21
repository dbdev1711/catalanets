import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../firebase/auth_service.dart';
import '../utils/show_snack_bar.dart';
import '../styles/app_styles.dart';

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
  final TextEditingController _passController = TextEditingController();

  List<String> _interessosSeleccionats = [];

  // Variables noves
  String _sexe = '';
  String _busco = '';

  // Variables existents
  String _fuma = '';
  String _beu = '';
  String _exercici = '';
  String _animals = '';
  String _fills = '';
  String _volFills = '';
  String _alimentacio = '';

  final List<String> _interessos = [
    'Castells', 'Pintar', 'Muntanya', 'Cuina', 'Cine', 'Series', 'Gimnàs',
    'Vins', 'Lectura', 'Escalada', 'Música', 'Viatjar', 'Museus', 'Cantar', 'Ballar',
    'Fotos', 'Jocs', 'Dev', 'Ioga', 'Córrer', 'Bici', 'Cartes',
    'Futbol', 'Teatre', 'Escacs', 'Tenis', 'Història', 'Política', 'Animals',
    'Plantes', 'Idiomes', 'Social', 'Platja', 'Esquí', 'Bàsquet', 'Pàdel'
  ];

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _edatController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _carregarPerfil() async {
    if (_uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(_uid).get();
      if (!mounted) return;

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          _user = UserModel.fromMap(data);
          _nomController.text = data['nom'] ?? '';
          _edatController.text = (data['edat'] != null && data['edat'] != 0) ? data['edat'].toString() : '';
          _interessosSeleccionats = List<String>.from(data['interessos'] ?? []);

          List<String> savedPhotos = List<String>.from(data['photoUrls'] ?? []);
          _photos = List.filled(4, null);
          for (int i = 0; i < savedPhotos.length && i < 4; i++) {
            _photos[i] = savedPhotos[i];
          }

          _sexe = data['sexe'] ?? '';
          _busco = data['busco'] ?? '';
          _fuma = data['fuma'] ?? '';
          _beu = data['beu'] ?? '';
          _exercici = data['exercici'] ?? '';
          _animals = data['animals'] ?? '';
          _fills = data['fills'] ?? '';
          _volFills = data['volFills'] ?? '';
          _alimentacio = data['alimentacio'] ?? '';
        });
      }
    } catch (e) {
      if (mounted) showSnackBar(context, "Error en carregar les dades");
    } finally {
      if (mounted) setState(() => _isInitialLoading = false);
    }
  }

  Future<void> _pickImage(int index) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (picked != null && mounted) {
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
          'sexe': _sexe,
          'busco': _busco,
          'fuma': _fuma,
          'beu': _beu,
          'exercici': _exercici,
          'animals': _animals,
          'fills': _fills,
          'volFills': _volFills,
          'alimentacio': _alimentacio,
        },
        photos: _photos,
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

  void _confirmarEliminacio() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Esborrar compte?"),
        content: const Text("Acció permanent.\nS'esborraran les teves dades."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel·lar")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _mostrarDialegContrasenya();
            },
            child: const Text("Continuar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _mostrarDialegContrasenya() {
  final TextEditingController localPassController = TextEditingController();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text("Seguretat"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Introdueix la contrasenya per confirmar l'eliminació."),
          const SizedBox(height: 15),
          TextField(
            controller: localPassController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Contrasenya",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () async {
                final email = FirebaseAuth.instance.currentUser?.email;
                if (email != null) {
                  try {
                    await _auth.sendPasswordReset(email);
                    if (mounted) {
                      showSnackBar(context, "Correu enviat a $email", color: Colors.blue);
                    }
                  } catch (e) {
                    if (mounted) showSnackBar(context, "Error en enviar el correu", color: Colors.red);
                  }
                }
              },
              child: const Text("He oblidat la contrasenya?", style:
              AppStyles.oblidatContra),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            localPassController.dispose();
            Navigator.pop(context);
          },
          child: const Text("Cancel·lar"),
        ),
        ElevatedButton(
          onPressed: () async {
            if (localPassController.text.isEmpty) return;
            try {
              await _auth.reauthenticateAndDelete(localPassController.text);
              localPassController.dispose();
              if (mounted) Navigator.pop(context);
            } catch (e) {
              if (mounted) showSnackBar(context, "Contrasenya incorrecta", color: Colors.red);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text("Esborrar definitivament", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  ).then((_) {
    localPassController.dispose();
  });
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

              // Secció nova: Identitat i Intencions
              const Align(alignment: Alignment.centerLeft, child: Text("Identitat i Intencions", style: TextStyle(fontWeight: FontWeight.bold))),
              const SizedBox(height: 10),
              _buildDropdown("Sóc...", _sexe, ['Home', 'Dona'], (v) => setState(() => _sexe = v!)),
              _buildDropdown("Busco...", _busco, ['Amistat', 'Estabilitat', 'Poliamor', 'Diversió'], (v) => setState(() => _busco = v!)),

              const SizedBox(height: 25),
              const Align(alignment: Alignment.centerLeft, child: Text("Estil de vida", style: TextStyle(fontWeight: FontWeight.bold))),
              const SizedBox(height: 10),
              _buildDropdown("Fumes?", _fuma, ['No', 'Socialment', 'Sí'], (v) => setState(() => _fuma = v!)),
              _buildDropdown("Beus?", _beu, ['No', 'Socialment', 'Sí'], (v) => setState(() => _beu = v!)),
              _buildDropdown("Fas exercici?", _exercici, ['Mai', 'A vegades', 'Sovint'], (v) => setState(() => _exercici = v!)),
              _buildDropdown("Tens animals?", _animals, ['No', 'Gat', 'Gos', 'Altres'], (v) => setState(() => _animals = v!)),
              _buildDropdown("Tens fills?", _fills, ['No', 'Sí'], (v) => setState(() => _fills = v!)),
              _buildDropdown("Vols fills?", _volFills, ['No', 'Sí', 'No ho sé'], (v) => setState(() => _volFills = v!)),
              _buildDropdown("Alimentació?", _alimentacio, ['De tot', 'Vegetarià/ana', 'Vegà/ana', 'Celíac/a', 'Altres'], (v) => setState(() => _alimentacio = v!)),

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
                itemCount: _interessos.length,
                itemBuilder: (context, index) {
                  final interes = _interessos[index];
                  final seleccionat = _interessosSeleccionats.contains(interes);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        seleccionat ? _interessosSeleccionats.remove(interes) : _interessosSeleccionats.add(interes);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: seleccionat ? Colors.orange[100] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: seleccionat ? Colors.orange : Colors.transparent, width: 2),
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
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
                    onPressed: _confirmarEliminacio,
                    icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                    label: const Text("Esborrar compte", style: TextStyle(color: Colors.redAccent, fontSize: 16)),
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