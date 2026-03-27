import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_checking/view_models/auth_view_model.dart';
import 'package:smart_checking/ui/pages/home_page.dart';

const kGreen = Color(0xFF0CC17C);
const kRed   = Color(0xFFF52626);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey      = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final vm      = context.read<AuthViewModel>();
    final success = await vm.login();

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: kGreen,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 25),

// Logo Appareil Photo
              ClipRect(
                child: Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                      'assets/logo-smart-cheking.png'
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                'SmartChecking',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const Text(
                'Snap-Clic-Enregistré !',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 40),
              // Card blanche avec le formulaire
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text(
                          'Je me connecte',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0CC17C),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Champ email
                        TextFormField(
                          controller: _emailCtrl,
                          onChanged: vm.setEmail,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration(
                            'Nom d\'Utilisateur, Email ou Téléphone',
                          ),
                          validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'Champ requis'
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // Champ mot de passe
                        TextFormField(
                          controller: _passwordCtrl,
                          onChanged: vm.setPassword,
                          obscureText: vm.obscurePassword,
                          decoration: _inputDecoration('Mot de Passe').copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                vm.obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: vm.togglePasswordVisibility,
                            ),
                          ),
                          validator: (v) =>
                          (v == null || v.length < 6)
                              ? 'Min. 6 caractères'
                              : null,
                        ),

                        // Message d'erreur
                        if (vm.errorMessage != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            vm.errorMessage!,
                            style: const TextStyle(color: kRed, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Bouton connexion
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: vm.isLoading ? null : _onLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: vm.isLoading
                                ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                                : const Text(
                              'Se Connecter',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Mention légale
              const Text(
                'En vous connectant vous acceptez\nles termes et politiques de vie privée',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Décoration commune pour les champs
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kGreen, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kRed),
      ),
    );
  }
}