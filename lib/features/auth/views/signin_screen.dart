import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';

import 'package:plus_vocab/features/auth/views/signup_screen.dart';
import 'package:plus_vocab/features/auth/views/recovery_pass_email_screen.dart';
import 'package:plus_vocab/features/homePage/views/home_screen.dart';

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

  // --- NOVAS CORES DO DESIGN ---
  final Color _blue = const Color(0xFF2563EB);
  final Color _bgLight = const Color(0xFFf3f4f6);
  // --- FIM DAS NOVAS CORES ---

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Função de submit (Mantida - Sem alterações)
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

  @override
  Widget build(BuildContext context) {
    // Leitura do estado (Mantida)
    final authState = context.watch<AuthController>();
    final bool isLoading = authState.isLoading;
    final String? errorMessage = authState.errorMessage;

    // --- ESTRUTURA DO BUILD METHOD ATUALIZADA ---
    return Scaffold(
        backgroundColor: _bgLight, // Cor de fundo do design
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
                          Text(
                            "Comece agora a aprender novas palavras!",
                            style: GoogleFonts.lexend(
                                fontSize: 18,
                                color: _blue,
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
                                      color: _blue),
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
                                  : Text("Entrar",
                                      style: GoogleFonts.lexend(
                                          fontSize: 14, color: Colors.white)),
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
                                      color:
                                          Theme.of(context).colorScheme.error,
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
                                  color: Colors.grey[400],
                                  thickness: 1,
                                  endIndent: 10,
                                ),
                              ),
                              Text(
                                "OU",
                                style: GoogleFonts.lexend(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.grey),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.grey[400],
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
                            onPressed: () {},
                            icon: Image.asset(
                              "assets/images/GoogleLogo.png",
                              height: 18,
                            ),
                            label: Text("Entrar com Google",
                                style: GoogleFonts.lexend(
                                    fontSize: 12, color: Colors.grey[500])),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          RichText(
                            text: TextSpan(
                                style: GoogleFonts.lexend(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.grey),
                                children: [
                                  const TextSpan(text: "Não tem uma conta?  "),
                                  TextSpan(
                                      text: "Criar uma conta",
                                      style: GoogleFonts.lexend(
                                          color: _blue,
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
