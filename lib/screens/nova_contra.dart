import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../styles/app_styles.dart';
import '../firebase/auth_service.dart';
import '../utils/show_snack_bar.dart';

class NovaContra extends StatefulWidget {
  final String emailPrevi;

  const NovaContra({super.key, this.emailPrevi = ""});

  @override
  State<NovaContra> createState() => _NovaContraState();
}

class _NovaContraState extends State<NovaContra> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final AuthService _auth = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.emailPrevi;
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await _auth.sendPasswordReset(_emailController.text.trim());

        if (!mounted) return;
        setState(() => _isLoading = false);

        showSnackBar(
          context,
          "Enllaç enviat. Revisa la bústia d'entrada o l'spam.",
          color: Colors.green
        );

        Navigator.pop(context);

      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);

        String missatge;
        switch (e.code) {
          case 'user-not-found':
            missatge = "No hi ha cap compte amb aquest correu.";
            break;
          case 'invalid-email':
            missatge = "El format del correu no és vàlid.";
            break;
          default:
            missatge = "No s'ha pogut enviar l'enllaç.";
        }
        showSnackBar(context, missatge, color: Colors.red);
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        showSnackBar(context, "Error inesperat.", color: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recuperar contrasenya"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppStyles.sizedBoxHeight40,
              const Icon(Icons.lock_reset, size: 80, color: Colors.grey),
              AppStyles.sizedBoxHeight20,
              const Text(
                "T'enviarem un correu electrònic amb un enllaç per restablir la teva contrasenya.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              AppStyles.sizedBoxHeight40,
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correu electrònic',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (val) => (val == null || val.isEmpty) ? 'Escriu el teu email' : null,
              ),
              AppStyles.sizedBoxHeight40,
              _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleResetPassword,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("Enviar enllaç"),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}