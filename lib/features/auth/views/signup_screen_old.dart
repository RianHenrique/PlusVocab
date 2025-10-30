import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final _formKey = GlobalKey<FormState>();

  // Controladores para capturar o texto dos campos
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    // Limpar os controladores quando o widget for descartado
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Função para lidar com a submissão do formulário
  void _submitSignUp() async {
    // 1. Validar o formulário
    if (_formKey.currentState?.validate() ?? false) {
      // Se for válido, pegar os valores
      final email = _emailController.text;
      final password = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text;

      final authController = context.read<AuthController>();

      await authController.signUp(
      email: email,
      password: password,
      confirmPassword: confirmPassword
      );

      if (!mounted) return;

      if (authController.errorMessage == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            // TODO: Troque pelo seu Widget de Home
            builder: (context) => const Placeholder(child: Center(child: Text('Home Screen'))),
          ),
        );
      }
    }
  }

  Widget _buildTextFieldWithLabel({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            suffixIcon: suffixIcon,
          ),
          validator: validator,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Aqui você leria o *estado* do controller
    final authState = context.watch<AuthController>();
    final bool isLoading = authState.isLoading;
    final String? errorMessage = authState.errorMessage;
    
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Cadastrar-se',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.left,
                ),
                const Text(
                  'Preencha os campos abaixo pra continuar',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 16),

                _buildTextFieldWithLabel(
                  label: 'Digite seu email',
                  controller: _emailController,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira um email';
                    }
                    if (!EmailValidator.validate(value)) {
                      return 'Por favor, insira um email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildTextFieldWithLabel(
                  label: 'Escolha sua senha',
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, digite uma senha';
                    }
                    if (value.length < 6) {
                       return 'A senha deve ter pelo menos 6 caracteres';
                    }
                    if (!value.contains(RegExp(r'[A-Z]'))) {
                      return 'A senha deve conter pelo menos uma letra maiúscula';
                    }
                    if (!value.contains(RegExp(r'[a-z]'))) {
                      return 'A senha deve conter pelo menos uma letra minúscula';
                    }
                    if (!value.contains(RegExp(r'[0-9]'))) {
                      return 'A senha deve conter pelo menos um número';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildTextFieldWithLabel(
                  label: 'Confirme sua senha',
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'As senhas não coincidem';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),

                ElevatedButton(
                  // Desabilita o botão se estiver carregando
                  onPressed: isLoading ? null : _submitSignUp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                        )
                      : const Text('Cadastrar'),
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'Já tem uma conta? Faça login',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
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