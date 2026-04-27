import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:plus_vocab/core/services/storage_service.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/auth/controllers/auth_controller.dart';
import 'package:plus_vocab/features/auth/views/signin_screen.dart';
import 'package:plus_vocab/features/home/views/home_screen.dart';
import 'package:plus_vocab/features/user/models/user_service.dart';

const List<(String apiValue, String labelPt)> _fluencyChoices = [
  ('beginner', 'Iniciante'),
  ('intermediate', 'Intermediário'),
  ('advanced', 'Avançado'),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _areaController = TextEditingController();
  final _ageController = TextEditingController();

  String? _fluencyApi;
  bool _mostrarProximasPalavras = true;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _mostrarAjudaProximasPalavras() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Mostrar próximas palavras',
          style: GoogleFonts.lexend(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Quando ativado, o app pode exibir sugestões de vocabulário relacionado durante a prática. '
          'A preferência fica salva neste aparelho.',
          style: GoogleFonts.lexend(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Entendi', style: GoogleFonts.lexend(color: AppColors.primaria)),
          ),
        ],
      ),
    );
  }

  Future<void> _continuar() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final age = int.tryParse(_ageController.text.trim());
    if (age == null || age < 5 || age > 120) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Informe uma idade válida entre 5 e 120 anos.', style: GoogleFonts.lexend()),
          backgroundColor: AppColors.erro,
        ),
      );
      return;
    }
    if (_fluencyApi == null || _fluencyApi!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selecione sua fluência.', style: GoogleFonts.lexend()),
          backgroundColor: AppColors.erro,
        ),
      );
      return;
    }

    final auth = context.read<AuthController>();
    final userId = auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sessão inválida. Faça login novamente.', style: GoogleFonts.lexend()),
          backgroundColor: AppColors.erro,
        ),
      );
      return;
    }

    final name = _nameController.text.trim();
    final area = _areaController.text.trim();

    final userService = context.read<UserService>();
    final storage = context.read<StorageService>();

    setState(() => _submitting = true);
    try {
      final body = <String, dynamic>{
        'name': name,
        'occupationArea': area,
        'age': age,
        'fluency': _fluencyApi!,
        'locale': 'pt-BR',
      };
      final atualizado = await userService.updateProfile(userId, body);
      await auth.updateCachedUserProfile(atualizado);
      await storage.setMostrarProximasPalavras(_mostrarProximasPalavras);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString(), style: GoogleFonts.lexend()),
          backgroundColor: AppColors.erro,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _voltarParaLogin() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await context.read<AuthController>().logOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (route) => false,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.fundoClaro,
        body: Stack(
          children: [
            SizedBox.expand(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    width: MediaQuery.of(context).size.width * 0.9,
                    padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.branco,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.sombraCard,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Image.asset(
                              'assets/images/PlusVocab2.png',
                              height: 30,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Vamos ajustar o +Vocab para você',
                            style: GoogleFonts.lexend(
                              fontSize: 18,
                              color: AppColors.textoAzul,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 22),
                          _labeledField(
                            label: 'Nome',
                            child: TextFormField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textoPreto),
                              decoration: _fieldDecoration(hint: 'Digite seu nome aqui'),
                              validator: (v) {
                                final t = v?.trim() ?? '';
                                if (t.length < 2) return 'Informe seu nome (mínimo 2 caracteres).';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          _labeledField(
                            label: 'Área de interesse',
                            child: TextFormField(
                              controller: _areaController,
                              textCapitalization: TextCapitalization.sentences,
                              style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textoPreto),
                              decoration: _fieldDecoration(
                                hint: 'Digite sua area de interesse aqui',
                              ),
                              validator: (v) {
                                if ((v?.trim() ?? '').isEmpty) {
                                  return 'Informe sua área de atuação ou estudo.';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          _labeledField(
                            label: 'Idade',
                            child: TextFormField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textoPreto),
                              decoration: _fieldDecoration(
                                hint: 'Digite sua idade aqui',
                              ),
                              validator: (v) {
                                if ((v?.trim() ?? '').isEmpty) {
                                  return 'Informe sua idade.';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          _labeledField(
                            label: 'Fluência',
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: AppColors.branco,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.bordaCampo),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _fluencyApi,
                                  isExpanded: true,
                                  hint: Text(
                                    'Selecione',
                                    style: GoogleFonts.lexend(fontSize: 13, color: AppColors.textoHint),
                                  ),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 20,
                                    color: AppColors.textoSecundario,
                                  ),
                                  style: GoogleFonts.lexend(fontSize: 13, color: AppColors.textoPreto),
                                  items: _fluencyChoices
                                      .map(
                                        (e) => DropdownMenuItem<String>(
                                          value: e.$1,
                                          child: Text(e.$2, style: GoogleFonts.lexend(fontSize: 13)),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) => setState(() => _fluencyApi = v),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'Mostrar próximas palavras?',
                                        style: GoogleFonts.lexend(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textoPreto,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      icon: Icon(
                                        Icons.info_outline,
                                        size: 20,
                                        color: AppColors.primaria.withValues(alpha: 0.85),
                                      ),
                                      onPressed: _mostrarAjudaProximasPalavras,
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _mostrarProximasPalavras,
                                onChanged: (v) => setState(() => _mostrarProximasPalavras = v),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                thumbColor: const WidgetStatePropertyAll<Color>(AppColors.branco),
                                trackColor: WidgetStateProperty.resolveWith((states) {
                                  if (states.contains(WidgetState.selected)) {
                                    return AppColors.primaria;
                                  }
                                  return null;
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            height: 48,
                            child: FilledButton(
                              onPressed: _submitting ? null : _continuar,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primaria,
                                foregroundColor: AppColors.branco,
                                disabledBackgroundColor: AppColors.primaria.withValues(alpha: 0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _submitting
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.branco,
                                      ),
                                    )
                                  : Text(
                                      'Continuar',
                                      style: GoogleFonts.lexend(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 44,
                            child: TextButton(
                              onPressed: _submitting ? null : _voltarParaLogin,
                              child: Text(
                                'Voltar para o login',
                                style: GoogleFonts.lexend(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textoSecundario,
                                ),
                              ),
                            ),
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
      ),
    );
  }

  InputDecoration _fieldDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.lexend(fontSize: 14, color: AppColors.textoHint),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.bordaCampo),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.bordaCampo),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaria, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.erro),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.erro),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: AppColors.branco,
    );
  }

  Widget _labeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textoSecundario,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
