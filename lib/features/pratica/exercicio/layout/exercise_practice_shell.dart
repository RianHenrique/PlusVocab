import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/pratica/exercicio/widgets/exercise_modality_label.dart';
import 'package:plus_vocab/features/pratica/exercicio/widgets/exercise_progress_dots.dart';
import 'package:plus_vocab/features/pratica/exercicio/widgets/exercise_submit_bar.dart';

/// Layout comum às modalidades: cabeçalho fixo, miolo rolável e rodapé fixo.
class ExercisePracticeShell extends StatelessWidget {
  const ExercisePracticeShell({
    super.key,
    required this.practiceTitle,
    required this.currentStepIndex,
    required this.totalSteps,
    required this.modalityLabel,
    required this.onModalityInfoTap,
    required this.miolo,
    required this.canSubmit,
    required this.onSubmit,
    required this.onAbandonPractice,
    this.statusLabel = 'Prática em andamento',
    this.submitLabel = 'Enviar',
    this.abandonLabel = 'Abandonar partida?',
    this.leading,
    this.footerBeforeSubmit,
  });

  final String statusLabel;
  final String practiceTitle;
  final int currentStepIndex;
  final int totalSteps;
  final String modalityLabel;
  final VoidCallback onModalityInfoTap;
  final Widget miolo;
  final bool canSubmit;
  final VoidCallback onSubmit;
  final VoidCallback onAbandonPractice;
  final String submitLabel;
  final String abandonLabel;
  final Widget? leading;
  final Widget? footerBeforeSubmit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.branco,
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (leading != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: leading,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: Column(
                    children: [
                      Text(
                        statusLabel,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lexend(
                          fontSize: 13,
                          color: AppColors.textoSuave,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        practiceTitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lexend(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaria,
                          height: 1.22,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ExerciseProgressDots(
                        total: totalSteps,
                        currentIndex: currentStepIndex,
                      ),
                      const SizedBox(height: 12),
                      ExerciseModalityLabel(
                        label: modalityLabel,
                        onInfoTap: onModalityInfoTap,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
                    child: miolo,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (footerBeforeSubmit != null) ...[
                        footerBeforeSubmit!,
                        const SizedBox(height: 12),
                      ],
                      ExerciseSubmitBar(
                        canSubmit: canSubmit,
                        onSubmit: onSubmit,
                        submitLabel: submitLabel,
                        abandonLabel: abandonLabel,
                        onAbandon: onAbandonPractice,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
