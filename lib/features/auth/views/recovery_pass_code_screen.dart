import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';

import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/auth/views/signin_screen.dart';
import 'package:plus_vocab/features/auth/views/reset_pass_screen.dart';

class RecoveryPassCodeScreen extends StatefulWidget {
  const RecoveryPassCodeScreen({super.key, required this.email});

  final String email;

  @override
  State<RecoveryPassCodeScreen> createState() => _RecoveryPassCodeScreenState();
}

class _RecoveryPassCodeScreenState extends State<RecoveryPassCodeScreen> {
  final _formKey = GlobalKey<FormState>();

  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _submitRecoveryCode() async {
    if (_formKey.currentState?.validate() ?? false) {
      final code = _codeController.text;

      final authController = context.read<AuthController>();

      final resetToken = await authController.sendRecoveryCode(
        email: widget.email,
        code: code
      );

      if (!mounted) return;

      if (authController.errorMessage == null && resetToken != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ResetPassScreen(
              email: widget.email,
              resetToken: resetToken,
            ),
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
      backgroundColor: AppColors.fundoClaro,
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
                  color: AppColors.branco,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.sombraCard,
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
                            "Digite o código enviado para o seu email",
                            style: GoogleFonts.lexend(
                                fontSize: 18,
                                color: AppColors.textoAzul,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            labelText: "Insira o código",
                            labelStyle: GoogleFonts.lexend(
                                fontSize: 12, fontWeight: FontWeight.w300),
                          ),
                          validator: (String? value) {
                            // Sua validação
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira o código';
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
                                backgroundColor: AppColors.primaria,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8))),
                            child: isLoading
                                ? const SizedBox(
                                    // Seu loading
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 3, color: AppColors.branco),
                                  )
                                : Text("Enviar",
                                    style: GoogleFonts.lexend(
                                        fontSize: 14, color: AppColors.branco)),
                          ),
                        ),
                        errorMessage != null ?const SizedBox(height: 10) : const SizedBox(height: 0),
                        if (errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5, top: 5),
                            child: Center(
                              child: Text(
                                errorMessage,
                                style: GoogleFonts.lexend(
                                  color: AppColors.erro,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 12
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        const SizedBox(height: 5,),
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
                                    fontSize: 12, color: AppColors.primaria))),
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
