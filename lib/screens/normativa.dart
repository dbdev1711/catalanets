import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../styles/app_styles.dart';
import '../utils/bottom_nav_bar.dart';
import '../utils/show_snack_bar.dart';
import 'gent.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showSnackBar(context, "Llegeix les normes per continuar (25s).", color: Colors.orange);
    });
    _timer = Timer(const Duration(seconds: 25), () {
      if (mounted) {
        setState(() {
          _canInteract = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startApp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstRun', false);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavBar()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Normativa i Privadesa'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('1. Benvinguda a Catalanets', style: AppStyles.normativaTitol),
                      Text('Aquesta app és un espai segur per catalanoparlants. L’ús de l’aplicació implica l’acceptació d’aquestes normes.', style: AppStyles.normativaText),
                      AppStyles.sizedBoxHeight20,
                      Text('2. Respecte i Civisme', style: AppStyles.normativaTitol),
                      Text('No es permetrà cap tipus de falta de respecte, discriminació o contingut inadequat als xats o espais comuns.', style: AppStyles.normativaText),
                      AppStyles.sizedBoxHeight20,
                      Text('3. Protecció de Dades (RGPD)', style: AppStyles.normativaTitol),
                      Text('Les teves dades es guarden de forma segura a Firebase. En cap moment compartirem la teva informació amb tercers.', style: AppStyles.normativaText),
                      AppStyles.sizedBoxHeight20,
                      Text('4. Responsabilitat', style: AppStyles.normativaTitol),
                      Text('L’usuari és responsable del contingut que publica i comparteix amb altres usuaris.', style: AppStyles.normativaText),
                      AppStyles.sizedBoxHeight30,
                      Text('Qualsevol usuari podrà bloquejar un usuari que incompleixi la normativa.', style: AppStyles.potBloquejar)
                    ],
                  ),
                ),
              ),
              AppStyles.sizedBoxHeight30,
              Padding(
                padding: const EdgeInsets.all(5),
                child: Center(
                  child: IntrinsicWidth(
                    child: GestureDetector(
                      onTap: _canInteract? null
                          : () => showSnackBar(
                                context,
                                "Si us plau, llegeix les normes.",
                                color: Colors.orange,
                              ),
                      child: Opacity(
                        opacity: _canInteract ? 1.0 : 0.5,
                        child: CheckboxListTile(
                          title: const Text(
                            "Accepto les condicions",
                            style: AppStyles.okNormes,
                          ),
                          value: _isAccepted,
                          onChanged: _canInteract
                              ? (bool? value) {
                                  setState(() {
                                    _isAccepted = value ?? false;
                                  });
                                  if (_isAccepted) {
                                    _startApp();
                                  }
                                }
                              : null,
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: Colors.orange,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}