import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../styles/app_styles.dart';
import '../firebase/auth_service.dart';
import '../utils/show_snack_bar.dart';
import '../main.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final AuthService _auth = AuthService();
  bool _isLoading = false;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final user = await _auth.signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (!mounted) return;
        setState(() => _isLoading = false);

        if (user != null) {
          showSnackBar(context, "Rep la benvinguda a Catalanets!", color: Colors.green);

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const App()),
            (route) => false,
          );
        }
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);

        String missatge;
        switch (e.code) {
          case 'email-already-in-use':
            missatge = "Aquest email ja està registrat";
            break;
          case 'invalid-email':
            missatge = "El format de l'email és incorrecte";
            break;
          case 'weak-password':
            missatge = "La contrasenya és massa feble";
            break;
          default:
            missatge = "Error en el registre: ${e.code}";
        }
        showSnackBar(context, missatge, color: Colors.red);
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        showSnackBar(context, "S'ha produït un error inesperat.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text('Nou compte', style: AppStyles.nouCompte),
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
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (val) => (val == null || val.length < 6) ? 'Mínim 6 caràcters' : null,
              ),
              AppStyles.sizedBoxHeight20,
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirma la contrasenya',
                  prefixIcon: _confirmPasswordController.text.isEmpty
                      ? const Icon(Icons.lock_outline)
                      : _passwordController.text == _confirmPasswordController.text
                          ? const Icon(Icons.lock, color: Colors.green)
                          : const Icon(Icons.lock_outline, color: Colors.red),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (val) => (val != _passwordController.text) ? 'Les contrasenyes no coincideixen' : null,
              ),
              AppStyles.sizedBoxHeight40,
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _handleSignUp,
                      child: const Text('Registrar-me'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}