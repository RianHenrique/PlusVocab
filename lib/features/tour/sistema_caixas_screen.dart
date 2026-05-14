import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/home/views/home_screen.dart';

class SistemaCaixasScreen extends StatelessWidget {
  const SistemaCaixasScreen({super.key, this.fromOnboarding = true});

  /// Quando `true` (padrão), desabilita o botão voltar e o botão "Entendi"
  /// navega para a HomeScreen removendo todas as rotas anteriores.
  /// Quando `false`, permite voltar normalmente e o botão "Entendi" apenas faz pop.
  final bool fromOnboarding;

  void _continuar(BuildContext context) {
    if (fromOnboarding) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !fromOnboarding,
      child: Scaffold(
        backgroundColor: AppColors.fundoClaro,
        body: Stack(
          children: [
            SizedBox.expand(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.25),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                          22, fromOnboarding ? 32 : 12, 22, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!fromOnboarding) ...[
                            IconButton(
                              icon: const Icon(Icons.chevron_left, size: 28),
                              color: AppColors.textoPreto,
                              onPressed: () => Navigator.of(context).pop(),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              style: IconButton.styleFrom(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap),
                              constraints: const BoxConstraints(
                                  minWidth: 36, minHeight: 36),
                            ),
                            const SizedBox(height: 8),
                          ] else ...[
                            Center(
                              child: Image.asset(
                                'assets/images/PlusVocab2.png',
                                height: 30,
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                          Text(
                            'Como você aprende no +Vocab',
                            style: GoogleFonts.lexend(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textoAzul,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.branco,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.sombraCard,
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/explicacao_repeticao_espacada.png',
                              width: double.infinity,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Cada palavra passa por níveis até você dominar de verdade.',
                            style: GoogleFonts.lexend(
                              fontSize: 15,
                              height: 1.5,
                              color: AppColors.textoPreto,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const _RuleItem(
                            icon: Icons.check_circle_outline,
                            text: 'Acertou → avança de nível',
                            color: AppColors.acerto,
                          ),
                          const SizedBox(height: 12),
                          const _RuleItem(
                            icon: Icons.replay_outlined,
                            text: 'Errou → volta ao início',
                            color: AppColors.erro,
                          ),
                          const SizedBox(height: 12),
                          const _RuleItem(
                            icon: Icons.auto_awesome_outlined,
                            text: 'O app revisa automaticamente',
                            color: AppColors.primaria,
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primaria.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primaria.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.lightbulb_outline,
                                  color: AppColors.primaria,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Quando uma palavra chega na última caixa, você realmente aprendeu.',
                                    style: GoogleFonts.lexend(
                                      fontSize: 13,
                                      height: 1.4,
                                      color: AppColors.primaria,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Seu objetivo é levar o máximo de palavras até o nível final.',
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              height: 1.45,
                              color: AppColors.textoSecundario,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: () => _continuar(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaria,
                          foregroundColor: AppColors.branco,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          fromOnboarding ? 'Entendi, vamos praticar' : 'Entendi',
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleItem extends StatelessWidget {
  const _RuleItem({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Text(
          text,
          style: GoogleFonts.lexend(
            fontSize: 14,
            color: AppColors.textoPreto,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
