import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/pratica/exercicio/models/vocabulary_match_models.dart';

/// Paleta de cores por par palavra-definição.
const _kPairColors = [
  Color(0xFF2563EB), // azul (primaria)
  Color(0xFF7C3AED), // roxo
  Color(0xFF059669), // verde
  Color(0xFFD97706), // âmbar
  Color(0xFFDC2626), // vermelho
  Color(0xFF0891B2), // ciano
];

Color _pairColor(int wordIndex) => _kPairColors[wordIndex % _kPairColors.length];

class VocabularyMatchPracticeBody extends StatelessWidget {
  const VocabularyMatchPracticeBody({
    super.key,
    required this.question,
    required this.selectedWordIndex,
    required this.associations,
    required this.onWordTap,
    required this.onDefinitionTap,
    this.onWordDroppedOnDefinition,
    this.feedback,
    this.isInteractionEnabled = true,
  });

  final VocabularyMatchQuestion question;
  final int? selectedWordIndex;
  final VocabularyMatchUserAssociations associations;
  final ValueChanged<int> onWordTap;
  final ValueChanged<int> onDefinitionTap;

  /// Chamado quando uma palavra é arrastada até uma definição.
  /// Parâmetros: (defIndex, wordIndex).
  final void Function(int defIndex, int wordIndex)? onWordDroppedOnDefinition;

  final VocabularyMatchEvaluation? feedback;
  final bool isInteractionEnabled;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Linha de palavras arrastáveis / tocáveis
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(question.words.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _WordChip(
                    word: question.words[i],
                    wordIndex: i,
                    color: _pairColor(i),
                    isSelected: selectedWordIndex == i,
                    isPaired: associations.any((a) => a == i),
                    isInteractionEnabled: isInteractionEnabled,
                    onTap: () => onWordTap(i),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Arraste ou toque para associar:',
            style: GoogleFonts.lexend(
              fontSize: 13,
              color: AppColors.textoSuave,
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(question.definitions.length, (defIndex) {
            final assignedWordIndex = associations[defIndex];
            final assignedColor =
                assignedWordIndex != null ? _pairColor(assignedWordIndex) : null;
            final assignedLabel = assignedWordIndex != null
                ? question.words[assignedWordIndex]
                : null;

            Color borderColor = AppColors.bordaCampo;
            if (feedback != null &&
                defIndex < feedback!.perDefinitionCorrect.length) {
              borderColor = feedback!.perDefinitionCorrect[defIndex]
                  ? AppColors.acerto
                  : AppColors.erro;
            } else if (assignedColor != null) {
              borderColor = assignedColor;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _DefinitionDropTarget(
                defIndex: defIndex,
                definitionText: question.definitions[defIndex],
                assignedLabel: assignedLabel,
                assignedColor: assignedColor,
                borderColor: borderColor,
                isInteractionEnabled: isInteractionEnabled,
                onTap: () => onDefinitionTap(defIndex),
                onDrop: onWordDroppedOnDefinition != null
                    ? (wordIdx) => onWordDroppedOnDefinition!(defIndex, wordIdx)
                    : null,
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Palavra arrastável

class _WordChip extends StatelessWidget {
  const _WordChip({
    required this.word,
    required this.wordIndex,
    required this.color,
    required this.isSelected,
    required this.isPaired,
    required this.isInteractionEnabled,
    required this.onTap,
  });

  final String word;
  final int wordIndex;
  final Color color;
  final bool isSelected;
  final bool isPaired;
  final bool isInteractionEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final chip = _chipWidget(opacity: 1.0);
    if (!isInteractionEnabled) return chip;

    return Draggable<int>(
      data: wordIndex,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.9,
          child: _buildContainer(
            fillColor: color,
            textColor: Colors.white,
            borderColor: color,
            borderWidth: 2,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: _buildContainer(
          fillColor: isPaired ? color : AppColors.branco,
          textColor: isPaired ? Colors.white : AppColors.textoPreto,
          borderColor: color.withValues(alpha: 0.4),
          borderWidth: 1,
        ),
      ),
      child: GestureDetector(onTap: onTap, child: chip),
    );
  }

  Widget _chipWidget({required double opacity}) {
    return Opacity(
      opacity: opacity,
      child: _buildContainer(
        fillColor: isPaired ? color : AppColors.branco,
        textColor: isPaired ? Colors.white : AppColors.textoPreto,
        borderColor: isSelected
            ? color
            : isPaired
                ? color
                : AppColors.bordaCampo,
        borderWidth: isSelected || isPaired ? 2 : 1,
      ),
    );
  }

  Widget _buildContainer({
    required Color fillColor,
    required Color textColor,
    required Color borderColor,
    required double borderWidth,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.18),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        word,
        style: GoogleFonts.lexend(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Definição com DragTarget

class _DefinitionDropTarget extends StatelessWidget {
  const _DefinitionDropTarget({
    required this.defIndex,
    required this.definitionText,
    required this.assignedLabel,
    required this.assignedColor,
    required this.borderColor,
    required this.isInteractionEnabled,
    required this.onTap,
    required this.onDrop,
  });

  final int defIndex;
  final String definitionText;
  final String? assignedLabel;
  final Color? assignedColor;
  final Color borderColor;
  final bool isInteractionEnabled;
  final VoidCallback onTap;
  final ValueChanged<int>? onDrop;

  @override
  Widget build(BuildContext context) {
    if (!isInteractionEnabled) {
      return _buildBox(isHovering: false);
    }

    return DragTarget<int>(
      onAcceptWithDetails: (details) {
        if (onDrop != null) onDrop!(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        final hovering = candidateData.isNotEmpty;
        return GestureDetector(
          onTap: onTap,
          child: _buildBox(isHovering: hovering),
        );
      },
    );
  }

  Widget _buildBox({required bool isHovering}) {
    final effectiveBorder =
        isHovering ? AppColors.primaria : borderColor;
    final effectiveBg = isHovering
        ? AppColors.primaria.withValues(alpha: 0.07)
        : assignedColor != null
            ? assignedColor!.withValues(alpha: 0.06)
            : AppColors.branco;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: effectiveBorder,
          width: isHovering || assignedColor != null ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (assignedLabel != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: assignedColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      assignedLabel!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Text(
            definitionText,
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
    );
  }
}
