import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';

import 'package:plus_vocab/features/auth/views/signin_screen.dart';

class ResetPassScreen extends StatefulWidget {
  const ResetPassScreen({super.key, required this.email, required this.resetToken});

  final String email;
  final String resetToken;

  @override
  State<ResetPassScreen> createState() => _ResetPassScreenState();
}

class _ResetPassScreenState extends State<ResetPassScreen> {
  final _formKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isPasswordConfirmVisible = false;

  final Color _blue = const Color(0xFF2563EB);
  final Color _bgLight = const Color(0xFFf3f4f6);

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  void _submitRecoveryCode() async {
    if (_formKey.currentState?.validate() ?? false) {
      final newPassword = _passwordController.text;

      final authController = context.read<AuthController>();

      await authController.resetPassword(email: widget.email, resetToken: widget.resetToken, newPassword: newPassword);

      if (!mounted) return;

      if (authController.errorMessage == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const SignInScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthController>();
    final bool isLoading = authState.isLoading;
    final String? errorMessage = authState.errorMessage;

    return Scaffold(
      backgroundColor: _bgLight,
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              "assets/images/background.png",
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(
                    maxWidth: 400), // Limita a largura para telas maiores
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                margin: const EdgeInsets.symmetric(vertical: 20),
                width: MediaQuery.of(context).size.width * 0.85,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                    )
                  ],
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Image.asset(
                            "assets/images/PlusVocab2.png",
                            height: 30,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Escolha sua nova senha",
                            style: GoogleFonts.lexend(
                                fontSize: 18,
                                color: _blue,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          style: GoogleFonts.lexend(fontSize: 14),
                          decoration: InputDecoration(
                              labelText: "Insira uma nova senha",
                              labelStyle: GoogleFonts.lexend(
                                  fontSize: 12, fontWeight: FontWeight.w300),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                                icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey),
                                iconSize: 18,
                              )),
                          validator: (value) {
                            // Sua validação
                            if (value == null || value.isEmpty) {
                              return 'Por favor, digite uma senha';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: _passwordConfirmController,
                          obscureText: !_isPasswordConfirmVisible,
                          style: GoogleFonts.lexend(fontSize: 14),
                          decoration: InputDecoration(
                              labelText: "Confirme sua nova senha",
                              labelStyle: GoogleFonts.lexend(
                                  fontSize: 12, fontWeight: FontWeight.w300),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isPasswordConfirmVisible =
                                        !_isPasswordConfirmVisible;
                                  });
                                },
                                icon: Icon(
                                    _isPasswordConfirmVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey),
                                iconSize: 18,
                              )),
                          validator: (value) {
                            // Sua validação
                            if (value != _passwordController.text) {
                              return 'As senhas não coincidem';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _submitRecoveryCode,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: _blue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8))),
                            child: isLoading
                                ? const SizedBox(
                                    // Seu loading
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 3, color: Colors.white),
                                  )
                                : Text("Enviar",
                                    style: GoogleFonts.lexend(
                                        fontSize: 14, color: Colors.white)),
                          ),
                        ),
                        errorMessage != null
                            ? const SizedBox(height: 10)
                            : const SizedBox(height: 0),
                        if (errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5, top: 5),
                            child: Center(
                              child: Text(
                                errorMessage,
                                style: GoogleFonts.lexend(
                                    color: Theme.of(context).colorScheme.error,
                                    fontWeight: FontWeight.w300,
                                    fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const SignInScreen(),
                                ),
                              );
                            },
                            child: Text("Voltar para o login",
                                style: GoogleFonts.lexend(
                                    fontSize: 12, color: _blue))),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
