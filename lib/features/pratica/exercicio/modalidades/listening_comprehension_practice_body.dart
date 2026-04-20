import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';

class ListeningComprehensionPracticeBody extends StatelessWidget {
  const ListeningComprehensionPracticeBody({
    super.key,
    required this.onPlayListening,
    required this.isPlayingListening,
    required this.questionText,
    required this.options,
    required this.selectedOptionIndex,
    required this.onOptionSelected,
    this.showResult = false,
    this.correctOptionIndex,
    this.submittedOptionIndex,
  });

  final VoidCallback onPlayListening;
  final bool isPlayingListening;
  final String questionText;
  final List<String> options;
  final int? selectedOptionIndex;
  final ValueChanged<int> onOptionSelected;
  final bool showResult;
  final int? correctOptionIndex;
  final int? submittedOptionIndex;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Toque para escutar',
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: 13,
              color: AppColors.textoSuave,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Material(
              color: AppColors.branco,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onPlayListening,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.branco,
                    border: Border.all(
                      color: AppColors.primaria,
                      width: isPlayingListening ? 3 : 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.sombraElevacao.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.graphic_eq_rounded,
                    size: 40,
                    color: isPlayingListening ? AppColors.primaria : AppColors.textoPreto,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            questionText,
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.primaria,
              height: 1.28,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(options.length, (index) {
            final borderStyle = _optionBorder(
              index: index,
              selected: selectedOptionIndex == index,
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: AppColors.branco,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () => onOptionSelected(index),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: borderStyle.color,
                        width: borderStyle.width,
                      ),
                    ),
                    child: Text(
                      options[index],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaria,
                        height: 1.22,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  ({Color color, double width}) _optionBorder({
    required int index,
    required bool selected,
  }) {
    if (showResult && correctOptionIndex != null && submittedOptionIndex != null) {
      if (index == correctOptionIndex) {
        return (color: AppColors.acerto, width: 3);
      }
      if (index == submittedOptionIndex && submittedOptionIndex != correctOptionIndex) {
        return (color: AppColors.erro, width: 3);
      }
      return (color: AppColors.bordaCampo, width: 1);
    }

    if (selected) {
      return (color: AppColors.primaria, width: 3);
    }
    return (color: AppColors.bordaCampo, width: 1);
  }
}
