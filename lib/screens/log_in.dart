import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../styles/app_styles.dart';
import '../firebase/auth_service.dart';
import '../utils/show_snack_bar.dart';
import '../utils/bottom_nav_bar.dart';
import 'sign_up.dart';
import 'nova_contra.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _auth = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        var user = await _auth.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (!mounted) return;
        setState(() => _isLoading = false);

        if (user != null) {
          final hora = DateTime.now().hour;
          String salutacio = (hora >= 6 && hora < 13) ?
            "Bon dia!" : (hora >= 13 && hora < 21) ? "Bona tarda!" : "Bona nit!";

          showSnackBar(context, salutacio, color: Colors.amberAccent);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavBar()),
          );
        }
      }
      on FirebaseAuthException catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        String missatgeError;

        switch (e.code) {
          case 'invalid-credential':
            missatgeError = "El correu o la contrasenya no són correctes.";
            break;
          case 'user-not-found':
            missatgeError = "No existeix cap usuari amb aquest correu.";
            break;
          case 'wrong-password':
            missatgeError = "La contrasenya és incorrecta.";
            break;
          case 'invalid-email':
            missatgeError = "El format del correu no és vàlid.";
            break;
          case 'user-disabled':
            missatgeError = "Aquest compte ha estat desactivat.";
            break;
          case 'too-many-requests':
            missatgeError = "Massa intents. Torna-ho a provar més tard.";
            break;
          default:
            missatgeError = "Error en l'autenticació: ${e.code}";
        }
        showSnackBar(context, missatgeError, color: Colors.red);
      }
      catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        showSnackBar(context, "S'ha produït un error inesperat.", color: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppStyles.sizedBoxHeight80,
              const Center(child: FittedBox(child: Text('Hola!', style: AppStyles.benvinguda))),
              AppStyles.sizedBoxHeight20,
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (val) => (val == null || val.isEmpty) ? 'Camp obligatori' : null,
              ),
              AppStyles.sizedBoxHeight20,
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Contrasenya',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (val) => (val == null || val.isEmpty) ? 'Introdueix la contrasenya' : null,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => NovaContra(emailPrevi: _emailController.text.trim())));
                  },
                  child: const Text("Has oblidat la contrasenya?", style: AppStyles.oblidat),
                ),
              ),
              AppStyles.sizedBoxHeight20,
              _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(100, 50)),
                    child: const Text('Entrar'),
                  ),
              AppStyles.sizedBoxHeight20,
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUp())),
                child: const Text("No tens compte?", style: AppStyles.noCompte),
              ),
            ],
          ),
        ),
      ),
    );
  }
}