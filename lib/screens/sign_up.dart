import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../styles/app_styles.dart';
import '../firebase/auth_service.dart'; // Utilitza la classe AuthService
import '../utils/show_snack_bar.dart';
import '../utils/bottom_nav_bar.dart';

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

          showSnackBar(context, "Compte creat correctament!", color: Colors.green);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavBar()),
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
        showSnackBar(context, "Error en crear el perfil.", color: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  FittedBox(fit: BoxFit.scaleDown,child: const Text('Nou compte', style: AppStyles.nouCompte)),
                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _nomController,
                          label: 'Nom',
                          icon: Icons.person_outline,
                          capitalization: TextCapitalization.words,
                          validator: (val) => (val == null || val.isEmpty) ? 'Escriu el teu nom' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) => (val == null || !val.contains('@')) ? 'Email invàlid' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Contrasenya',
                          icon: Icons.lock,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (val) => (val == null || val.length < 6) ? 'Mínim 6 caràcters' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _confirmPasswordController,
                          label: 'Repeteix contrasenya',
                          icon: Icons.lock,
                          iconColor: _confirmPasswordController.text == _passwordController.text && _confirmPasswordController.text.isNotEmpty
                              ? Colors.green
                              : (_confirmPasswordController.text.isEmpty ? Colors.grey : Colors.red),
                          obscureText: _obscureConfirm,
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                          // Afegim un listener al controlador perquè el color canviï mentre escrius
                          onChanged: (val) => setState(() {}),
                          validator: (val) => (val != _passwordController.text) ? 'No coincideixen' : null,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.orange)
                      : ElevatedButton(
                          onPressed: _handleSignUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: const Text('Registrar-me', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    Color? iconColor,
    void Function(String)? onChanged,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    TextCapitalization capitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: capitalization,
      onChanged: onChanged, // <--- Afegeix aquesta línia
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: iconColor), // <--- Aplica el color a la icona
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
  }
}