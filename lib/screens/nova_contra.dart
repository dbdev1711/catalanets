import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../styles/app_styles.dart';
import '../firebase/auth_service.dart';
import '../utils/show_snack_bar.dart';

class NovaContra extends StatefulWidget {
  final String emailPrevi;

  const NovaContra({Key? key, this.emailPrevi = ""}) : super(key: key);

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
        // Crida al mètode que hem afegit a l'AuthService
        await _auth.sendPasswordReset(_emailController.text.trim());

        if (!mounted) return;
        setState(() => _isLoading = false);
        showSnackBar(context, "Revisa la teva bústia o l'spam passats uns minuts",
            color: Colors.green);
        Navigator.pop(context);

      }
      on FirebaseAuthException catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);

        String missatge;
        switch (e.code) {
          case 'user-not-found':
            missatge = "No hi ha cap usuari registrat amb aquest correu";
            break;
          case 'invalid-email':
            missatge = "L'adreça de correu no és vàlida";
            break;
          default:
            missatge = "Error: ${e.message}";
        }
        showSnackBar(context, missatge, color: Colors.red);
      }
      catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        showSnackBar(context, "S'ha produït un error inesperat");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recupera't"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppStyles.sizedBoxHeight40,

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correu electrònic',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (val) => (val == null || val.isEmpty) ? 'Introdueix el teu email' : null,
              ),

              AppStyles.sizedBoxHeight40,

              _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _handleResetPassword,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Envia'm l'enllaç"),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}