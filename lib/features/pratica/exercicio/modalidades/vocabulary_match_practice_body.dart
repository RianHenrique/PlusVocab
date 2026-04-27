import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/pratica/exercicio/models/vocabulary_match_models.dart';

class VocabularyMatchPracticeBody extends StatelessWidget {
  const VocabularyMatchPracticeBody({
    super.key,
    required this.question,
    required this.selectedWordIndex,
    required this.associations,
    required this.onWordTap,
    required this.onDefinitionTap,
    this.feedback,
    this.isInteractionEnabled = true,
  });

  final VocabularyMatchQuestion question;
  final int? selectedWordIndex;
  final VocabularyMatchUserAssociations associations;
  final ValueChanged<int> onWordTap;
  final ValueChanged<int> onDefinitionTap;
  final VocabularyMatchEvaluation? feedback;
  final bool isInteractionEnabled;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(question.words.length, (i) {
                final selected = selectedWordIndex == i;
                final isPaired = associations.any((a) => a == i);
                final Color fillColor =
                    isPaired ? AppColors.primaria : AppColors.branco;
                final Color labelColor =
                    isPaired ? AppColors.branco : AppColors.textoPreto;
                final Color borderColor = isPaired
                    ? (selected ? AppColors.branco : AppColors.primaria)
                    : (selected ? AppColors.primaria : AppColors.bordaCampo);
                final double borderWidth = selected ? 2 : 1;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: isInteractionEnabled ? () => onWordTap(i) : null,
                      borderRadius: BorderRadius.circular(10),
                      splashColor: isPaired
                          ? AppColors.branco.withValues(alpha: 0.2)
                          : AppColors.primaria.withValues(alpha: 0.12),
                      highlightColor: isPaired
                          ? AppColors.branco.withValues(alpha: 0.1)
                          : AppColors.primaria.withValues(alpha: 0.06),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: borderColor,
                            width: borderWidth,
                          ),
                        ),
                        child: Text(
                          question.words[i],
                          style: GoogleFonts.lexend(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: labelColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Definições:',
            style: GoogleFonts.lexend(
              fontSize: 13,
              color: AppColors.textoSuave,
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(question.definitions.length, (defIndex) {
            final assignedWordIndex = associations[defIndex];
            final assignedLabel = assignedWordIndex != null
                ? question.words[assignedWordIndex]
                : null;

            Color borderColor = AppColors.bordaCampo;
            if (feedback != null &&
                defIndex < feedback!.perDefinitionCorrect.length) {
              borderColor = feedback!.perDefinitionCorrect[defIndex]
                  ? AppColors.acerto
                  : AppColors.erro;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: AppColors.branco,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: isInteractionEnabled
                      ? () => onDefinitionTap(defIndex)
                      : null,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (assignedLabel != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              assignedLabel,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lexend(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaria,
                              ),
                            ),
                          ),
                        Text(
                          question.definitions[defIndex],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textoPreto,
                            height: 1.28,
                          ),
                        ),
                      ],
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
}
