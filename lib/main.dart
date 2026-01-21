import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase/firebase_options.dart';
import 'screens/log_in.dart';
import 'screens/normativa.dart';
import 'utils/bottom_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  // Utilitzem una variable local per evitar problemes de tipus amb null
  final bool firstTime = prefs.getBool('isfirsttime') ?? true;

  runApp(App(isFirstTime: firstTime));
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class App extends StatelessWidget {
  final bool isFirstTime;

  // El constructor requereix el booleà per evitar el TypeError
  const App({super.key, required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: MyCustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
      title: 'Catalanets',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.orange,
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(fontSize: 35, color: Colors.black),
          centerTitle: true,
        ),
      ),
      home: isFirstTime
          ? const Normativa()
          : StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                // Si l'usuari ja té sessió, va directament a la pantalla principal
                if (snapshot.hasData) {
                  return const BottomNavBar();
                }
                // Si no té sessió, a LogIn
                return const LogIn();
              },
            ),
    );
  }
}