import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import 'signin_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores (Mantidos)
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Estados de visibilidade (Mantidos)
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // --- NOVAS CORES DO DESIGN (COPIADAS DO SIGNIN) ---
  final Color _primaryPurple = const Color(0xFF4e7fa5);
  final Color _textBlue = const Color(0xFF4e7fa5);
  final Color _bgLight = const Color(0xFFf3f4f6);
  // --- FIM DAS NOVAS CORES ---

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Função de submit (Mantida - Sem alterações)
  void _submitSignUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text;
      final password = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text;

      final authController = context.read<AuthController>();

      await authController.signUp(
          email: email, password: password, confirmPassword: confirmPassword);

      if (!mounted) return;

      if (authController.errorMessage == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            // TODO: Troque pelo seu Widget de Home
            builder: (context) =>
                const Placeholder(child: Center(child: Text('Home Screen'))),
          ),
        );
      }
    }
  }

  // O helper _buildTextFieldWithLabel foi removido.

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
                  'assets/images/+Vocab.png', // Caminho atualizado
                  height: 80,
                ),
                const SizedBox(height: 16),
                Text(
                  'Crie sua Conta', // Texto de Cadastro
                  style: GoogleFonts.poppins( // Fonte atualizada
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _textBlue,
                  ),
                ),
                Text(
                  'Preencha os dados para registrar', // Texto de Cadastro
                  style: GoogleFonts.poppins( // Fonte atualizada
                    fontSize: 16,
                    fontWeight: FontWeight.w400, // Peso atualizado
                    color: _textBlue.withValues(alpha: 1), // Opacidade atualizada
                  ),
                ),
                const SizedBox(height: 40),

                // --- SEÇÃO INFERIOR: CARD DO FORMULÁRIO ---
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
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
                        TextFormField(
                          controller: _emailController, // Seu controller
                          style: GoogleFonts.poppins( // Fonte atualizada
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "Email",
                            prefixIcon:
                                const Icon(Icons.person, color: Colors.grey),
                            contentPadding: const EdgeInsets.symmetric( // Padding atualizado
                                horizontal: 8, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: _primaryPurple, width: 2.0),
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
                        const SizedBox(height: 10), // Espaçamento atualizado

                        // --- Campo Senha (Estilizado) ---
                        TextFormField(
                          controller: _passwordController, // Seu controller
                          style: GoogleFonts.poppins( // Fonte atualizada
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          obscureText: !_isPasswordVisible, // Seu estado
                          decoration: InputDecoration(
                            hintText: "Senha",
                            prefixIcon:
                                const Icon(Icons.lock_outline, color: Colors.grey),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
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
                              borderSide:
                                  BorderSide(color: Colors.grey.shade200),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) { // Sua validação de senha forte
                            if (value == null || value.isEmpty) {
                              return 'Por favor, digite uma senha';
                            }
                            if (value.length < 8) {
                              return 'A senha deve ter pelo menos 6 caracteres';
                            }
                            // Você pode adicionar mais validações se desejar
                            return null;
                          },
                        ),
                        const SizedBox(height: 10), // Espaçamento atualizado

                        // --- Campo Confirmar Senha (Novo/Estilizado) ---
                        TextFormField(
                          controller:
                              _confirmPasswordController, // Seu controller
                          style: GoogleFonts.poppins( // Fonte atualizada
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          obscureText:
                              !_isConfirmPasswordVisible, // Seu estado
                          decoration: InputDecoration(
                            hintText: "Confirmar Senha",
                            prefixIcon:
                                const Icon(Icons.lock_outline, color: Colors.grey),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () { // Sua lógica
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade200),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) { // Sua validação de confirmação
                            if (value != _passwordController.text) {
                              return 'As senhas não coincidem';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 5), // Espaçamento atualizado (não tem "esqueceu senha")

                        // --- Exibição de Erro (Mantida) ---
                        if (errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 16.0),
                            child: Center(
                              child: Text(
                                errorMessage,
                                style: GoogleFonts.poppins( // Fonte atualizada
                                    color:
                                        Theme.of(context).colorScheme.error),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        const SizedBox(height: 10),

                        // --- Botão de CADASTRAR (Estilizado) ---
                        SizedBox(
                          width: double.infinity,
                          height: 40, // Altura atualizada
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryPurple, // Cor do design
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8), // Borda atualizada
                              ),
                            ),
                            onPressed: isLoading ? null : _submitSignUp, // Sua lógica
                            child: isLoading
                                ? const SizedBox( // Seu loading
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 3, color: Colors.white),
                                  )
                                : Text(
                                    "CADASTRAR", // Texto de Cadastro
                                    style: GoogleFonts.poppins( // Fonte atualizada
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500, // Peso atualizado
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 15), // Espaçamento atualizado

                        // --- Divisor "ou" (Estilizado) ---
                        Row(
                          children: [
                            Expanded(
                                child: Divider(
                                    color: Colors.grey.shade300,
                                    thickness: 1.5)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                "ou",
                                style: GoogleFonts.inter( // Mantido Inter (conforme signin)
                                    color: Colors.grey.shade400,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ),
                            Expanded(
                                child: Divider(
                                    color: Colors.grey.shade300,
                                    thickness: 1.5)),
                          ],
                        ),
                        const SizedBox(height: 15), // Espaçamento atualizado

                        // --- Botão Google (Estilizado) ---
                        SizedBox(
                          width: double.infinity,
                          height: 40, // Altura atualizada
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.grey.shade100,
                              side: BorderSide.none, // Sem borda
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8), // Borda atualizada
                              ),
                            ),
                            icon: Image.asset( // Seu ícone
                              'assets/images/GoogleLogo.png',
                              height: 18, // Altura atualizada
                            ),
                            label: Text(
                              "CADASTRAR COM GOOGLE", // Texto de Cadastro
                              style: GoogleFonts.inter( // Mantido Inter (conforme signin)
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
                        const SizedBox(height: 20), // Espaçamento atualizado

                        // --- Rodapé Login (Estilizado) ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Já tem uma conta?",
                              style:
                                  GoogleFonts.poppins(fontWeight: FontWeight.w500), // Fonte atualizada
                            ),
                            TextButton(
                              onPressed: () { // Sua navegação
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                } else {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SignInScreen()));
                                }
                              },
                              child: Text(
                                "Entrar",
                                style: GoogleFonts.poppins( // Fonte atualizada
                                    color: _primaryPurple,
                                    fontWeight: FontWeight.w500), // Peso atualizado
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 10), // Espaçamento atualizado
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