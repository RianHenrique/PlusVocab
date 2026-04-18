import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';

import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/auth/views/signup_screen.dart';
import 'package:plus_vocab/features/auth/views/recovery_pass_email_screen.dart';
import 'package:plus_vocab/features/home/views/home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores (Mantidos)
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // signInWithGoogle
  void _submitLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text;
      final password = _passwordController.text;

      final authController = context.read<AuthController>();

      await authController.signIn(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (authController.errorMessage == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    }
  }

  void signInWithGoogle() async {
    final authController = context.read<AuthController>();

    await authController.signInWithGoogle();

    if (!mounted) return;

    if (authController.errorMessage == null && authController.currentUser != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } else if (authController.errorMessage != null) {
      // Deu erro (ex: 401 do backend), mostra o erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authController.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Leitura do estado (Mantida)
    final authState = context.watch<AuthController>();
    final bool isLoading = authState.isLoading;
    final String? errorMessage = authState.errorMessage;

    // --- ESTRUTURA DO BUILD METHOD ATUALIZADA ---
    return Scaffold(
        backgroundColor: AppColors.fundoClaro,
        body: Stack(children: [
          SizedBox.expand(
              child: Image.asset(
            "assets/images/background.png",
            fit: BoxFit.cover,
          )),
          SafeArea(
            child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Center(
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
                          Text(
                            "Comece agora a aprender novas palavras!",
                            style: GoogleFonts.lexend(
                                fontSize: 18,
                                color: AppColors.textoAzul,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              labelText: "Insira seu email",
                              labelStyle: GoogleFonts.lexend(
                                  fontSize: 12, fontWeight: FontWeight.w300),
                            ),
                            validator: (String? value) {
                              // Sua validação
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira um email';
                              }
                              if (!EmailValidator.validate(value)) {
                                return 'Por favor, insira um email válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            style: GoogleFonts.lexend(fontSize: 14),
                            decoration: InputDecoration(
                                labelText: "Senha",
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
                                      color: AppColors.textoHint),
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
                          Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RecuperarSenhaScreen(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                ),
                                child: Text(
                                  "Esqueci minha senha",
                                  style: GoogleFonts.lexend(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300,
                                      color: AppColors.primaria),
                                ),
                              )),
                          const SizedBox(
                            height: 5,
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _submitLogin,
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
                                  : Text("Entrar",
                                      style: GoogleFonts.lexend(
                                          fontSize: 14, color: AppColors.branco)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (errorMessage != null)
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 10, top: 5),
                              child: Center(
                                child: Text(
                                  errorMessage,
                                  style: GoogleFonts.lexend(
                                      color: AppColors.erro,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: AppColors.linhaDivisoria,
                                  thickness: 1,
                                  endIndent: 10,
                                ),
                              ),
                              Text(
                                "OU",
                                style: GoogleFonts.lexend(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w300,
                                    color: AppColors.textoSuave),
                              ),
                              Expanded(
                                child: Divider(
                                  color: AppColors.linhaDivisoria,
                                  thickness: 1,
                                  indent: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextButton.icon(
                            onPressed: () => signInWithGoogle(),
                            icon: Image.asset(
                              "assets/images/GoogleLogo.png",
                              height: 18,
                            ),
                            label: Text("Entrar com Google",
                                style: GoogleFonts.lexend(
                                    fontSize: 12, color: AppColors.textoSuave)),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          RichText(
                            text: TextSpan(
                                style: GoogleFonts.lexend(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                    color: AppColors.textoSuave),
                                children: [
                                  const TextSpan(text: "Não tem uma conta?  "),
                                  TextSpan(
                                      text: "Criar uma conta",
                                      style: GoogleFonts.lexend(
                                          color: AppColors.primaria,
                                          fontWeight: FontWeight.bold),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const SignUpScreen(),
                                            ),
                                          );
                                        }),
                                ]),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ))),
          )
        ]));
  }
}
