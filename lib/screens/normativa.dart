import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../styles/app_styles.dart';
import '../utils/show_snack_bar.dart';
import 'log_in.dart';

class Normativa extends StatefulWidget {
  const Normativa({super.key});

  @override
  State<Normativa> createState() => _NormativaState();
}

class _NormativaState extends State<Normativa> {
  bool _isAccepted = false;
  bool _canInteract = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 10), () {
      if (mounted) setState(() => _canInteract = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startApp() async {
    final user = FirebaseAuth.instance.currentUser;

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LogIn()),
      );
    }

    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('acceptacions_normativa')
            .doc(user.uid)
            .set({
          'uid': user.uid,
          'data_acceptacio': FieldValue.serverTimestamp(),
          'acceptat': true,
        });
      }
      catch (e) {
        if (mounted) showSnackBar(context, "Error al registrar l'acceptació.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mqd = MediaQuery.of(context).copyWith(
      textScaler: const TextScaler.linear(1.0),
    );

    return MediaQuery(
      data: mqd,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('Normativa i Privadesa')
          )
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const _NormaItem(
                          titol: '1. Edat mínima d\'ús',
                          text: 'L\'edat mínima legal és 18 anys.'
                        ),
                        AppStyles.sizedBoxHeight20,
                        const _NormaItem(
                          titol: '2. Respecte',
                          text: 'No es permeten insults, bully o l\'odi.\nCompartim una bona experiència.'
                        ),
                        AppStyles.sizedBoxHeight20,
                        const _NormaItem(
                          titol: '3. Comunitat',
                          text: 'Espai per catalanoparlants.'
                        ),
                        AppStyles.sizedBoxHeight20,
                        const _NormaItem(
                          titol: '3. Contingut Prohibit',
                          text: 'Violència o material sexual.'
                        ),
                        AppStyles.sizedBoxHeight20,
                        const _NormaItem(
                          titol: '4. Protecció de Dades (RGPD)',
                          text: 'Les dades es guarden a Google.\nS\'esborren en eliminar el perfil.'
                        ),
                        AppStyles.sizedBoxHeight20,
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Center(
                            child: Text(
                              'Qualsevol usuari podrà marcar el perfil que '
                                  'incompleixi la normativa i serà esborrat indefinidament.',
                              style: AppStyles.normativaBold.copyWith(fontSize: 21),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AppStyles.sizedBoxHeight40,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        "Accepto les condicions",
                        style: AppStyles.okNormes.copyWith(fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _canInteract
                        ? null
                        : () => showSnackBar(context, "Llegeix les normes."),
                      child: Checkbox(
                        value: _isAccepted,
                        onChanged: _canInteract
                            ? (bool? value) {
                                setState(() => _isAccepted = value ?? false);
                                if (_isAccepted) _startApp();
                              }
                            : null,
                        activeColor: Colors.orange,
                      ),
                    ),
                  ],
                ),
                AppStyles.sizedBoxHeight20,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NormaItem extends StatelessWidget {
  final String titol;
  final String text;
  const _NormaItem({required this.titol, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Text(titol, style: AppStyles.normativaTitol.copyWith(fontSize: 24))
        ),
        const SizedBox(height: 2),
        Text(
          text,
          style: AppStyles.normativaText.copyWith(fontSize: 20),
          maxLines: 2,
          overflow: TextOverflow.ellipsis
        ),
      ],
    );
  }
}