import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import 'signup_screen.dart';

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
  final Color _primaryPurple = const Color(0xFF4e7fa5);
  final Color _textBlue = const Color(0xFF4e7fa5);
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
            // TODO: Troque pelo seu Widget de Home
            builder: (context) =>
                const Scaffold(
                  body: SafeArea(child: Text('Home Screen - Login bem sucedido!'))
                ),
          ),
        );
      }
    }
  }

  // O helper _buildTextFieldWithLabel foi removido pois
  // os campos de Email e Senha no novo design são muito diferentes
  // e é mais fácil criá-los inline no build method.

  @override
  Widget build(BuildContext context) {
    // Leitura do estado (Mantida)
    final authState = context.watch<AuthController>();
    final bool isLoading = authState.isLoading;
    final String? errorMessage = authState.errorMessage;

    // --- ESTRUTURA DO BUILD METHOD ATUALIZADA ---
    return Scaffold(
      backgroundColor: _bgLight, // Cor de fundo do design
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                
                // --- SEÇÃO SUPERIOR: LOGO E TEXTOS ---
                Image.asset(
                  'assets/images/+Vocab.png', // MANTIDO - Troque pela sua logo +Vocab
                  height: 80, // Altura ajustada
                ),
                const SizedBox(height: 16),
                Text(
                  'Bem Vindo', // Texto do design
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _textBlue,
                  ),
                ),
                Text(
                  'Faça login para continuar', // Texto do design
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: _textBlue.withValues(alpha: 1),
                  ),
                ),
                const SizedBox(height: 40),

                // --- SEÇÃO INFERIOR: CARD DO FORMULÁRIO ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Form(
                    key: _formKey, // Sua _formKey
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        // --- Campo Email (Estilizado) ---
                        Text(
                          "Email",
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController, // Seu controller
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: _primaryPurple, width: 2.0),
                            ),
                          ),
                          validator: (String? value) { // Sua validação
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira um email';
                            }
                            if (!EmailValidator.validate(value)) {
                              return 'Por favor, insira um email válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),

                        // --- Campo Senha (Estilizado) ---
                        TextFormField(
                          controller: _passwordController, // Seu controller
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          obscureText: !_isPasswordVisible, // Seu estado
                          decoration: InputDecoration(
                            hintText: "Senha",
                            prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () { // Sua lógica
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade200),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                           validator: (value) { // Sua validação
                            if (value == null || value.isEmpty) {
                              return 'Por favor, digite uma senha';
                            }
                            return null;
                          },
                        ),

                        // --- Botão Esqueceu a Senha (Novo) ---
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () { /* TODO: Lógica "esqueceu senha" */ },
                            child: Text(
                              "Esqueceu a senha",
                              style: GoogleFonts.poppins(
                                color: _primaryPurple,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),

                        // --- Exibição de Erro (Mantida) ---
                        if (errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Center(
                              child: Text(
                                errorMessage,
                                style: GoogleFonts.inter(
                                    color: Theme.of(context).colorScheme.error),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                        // --- Botão de LOGIN (Estilizado) ---
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryPurple, // Cor do design
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: isLoading ? null : _submitLogin, // Sua lógica
                            child: isLoading
                                ? const SizedBox( // Seu loading
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 3, color: Colors.white),
                                  )
                                : Text(
                                    "ENTRAR", // Texto do design
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // --- Divisor "ou" (Estilizado) ---
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1.5)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                "ou",
                                style: GoogleFonts.inter(
                                    color: Colors.grey.shade400,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1.5)),
                          ],
                        ),
                        const SizedBox(height: 15),

                        // --- Botão Google (Estilizado) ---
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.grey.shade100,
                              side: BorderSide.none, // Sem borda
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: Image.asset( // Seu ícone
                              'assets/images/GoogleLogo.png',
                              height: 18,
                            ),
                            label: Text(
                              "ENTRAR COM GOOGLE", // Texto do design
                              style: GoogleFonts.inter(
                                color: _textBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            onPressed: () { // Sua lógica (TODO)
                              // final authController = context.read<AuthController>();
                              // authController.signInWithGoogle();
                              print('Botão Google pressionado');
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // --- Rodapé Cadastre-se (Estilizado) ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Não tem uma conta?",
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                            ),
                            TextButton(
                              onPressed: () { // Sua navegação
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const SignUpScreen()));
                              },
                              child: Text(
                                "Cadastre-se",
                                style: GoogleFonts.poppins(
                                    color: _primaryPurple,
                                    fontWeight: FontWeight.w500),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}