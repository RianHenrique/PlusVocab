import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';

class ExerciseSubmitBar extends StatelessWidget {
  const ExerciseSubmitBar({
    super.key,
    required this.canSubmit,
    required this.onSubmit,
    required this.onAbandon,
    this.submitLabel = 'Enviar',
    this.abandonLabel = 'Abandonar partida?',
    this.showAbandon = true,
  });

  final bool canSubmit;
  final VoidCallback onSubmit;
  final VoidCallback onAbandon;
  final String submitLabel;
  final String abandonLabel;
  final bool showAbandon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: canSubmit ? onSubmit : null,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor:
                  canSubmit ? AppColors.primaria : AppColors.bordaCampo,
              foregroundColor: AppColors.branco,
              disabledBackgroundColor: AppColors.bordaCampo,
              disabledForegroundColor: AppColors.branco,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              submitLabel,
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (showAbandon) ...[
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: onAbandon,
              child: Text(
                abandonLabel,
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.erro,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
