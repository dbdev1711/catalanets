import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:somcatalanets/utils/bottom_nav_bar.dart';
import './firebase/firebase_options.dart';
import './screens/normativa.dart';
import './screens/log_in.dart';

void main() async {
  // Assegura que els bindings de Flutter estiguin inicialitzats abans d'usar Firebase o SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialització de Firebase amb les opcions per defecte segons la plataforma
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Obtenim l'estat de la primera execució per saber si l'usuari ha acceptat la normativa
  final prefs = await SharedPreferences.getInstance();
  final bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

  runApp(App(isFirstRun: isFirstRun));
}

class App extends StatelessWidget {
  final bool isFirstRun;

  const App({super.key, required this.isFirstRun});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Catalanets',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.orange, // Color temàtic basat en la barretina
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 18),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      // Lògica de navegació:
      // 1. Si isFirstRun és cert, enviem a la pantalla de Normativa [cite: 2025-12-30]
      // 2. Si no, escoltem el flux d'autenticació de Firebase [cite: 2025-12-30]
      home: isFirstRun
          ? const Normativa()
          : StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                // Mentre es verifica la sessió, mostrem un indicador de càrrega
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(color: Colors.orange),
                    ),
                  );
                }

                // Si el snapshot té dades, l'usuari està loguejat i va a la pantalla principal
                if (snapshot.hasData) {
                  return const BottomNavBar();
                }

                // Si no hi ha sessió activa, l'usuari ha de fer Log In
                return const LogIn();
              },
            ),
    );
  }
}