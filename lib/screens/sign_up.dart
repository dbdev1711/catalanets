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
  final TextEditingController _nomController = TextEditingController();

  final AuthService _auth = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nomController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final credential = await _auth.signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nomController.text.trim(),
        );

        if (credential != null && credential.user != null) {
          if (!mounted) return;
          showSnackBar(context, "Benvingut/da a Catalanets!", color: Colors.green);

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const App()),
            (route) => false,
          );
        }
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        String missatge = e.code == 'email-already-in-use'
            ? "Aquest email ja està registrat"
            : "Error: ${e.code}";
        showSnackBar(context, missatge, color: Colors.red);
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        showSnackBar(context, "Error en crear el perfil.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text('Nou compte', style: AppStyles.nouCompte),
              AppStyles.sizedBoxHeight20,
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Com et dius?',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (val) => (val == null || val.isEmpty) ? 'Digue\'ns el teu nom' : null,
              ),
              AppStyles.sizedBoxHeight20,
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (val) => (val == null || !val.contains('@')) ? 'Email invàlid' : null,
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
                validator: (val) => (val == null || val.length < 6) ? 'Mínim 6 caràcters' : null,
              ),
              AppStyles.sizedBoxHeight20,
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirma la contrasenya',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (val) => (val != _passwordController.text) ? 'No coincideixen' : null,
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