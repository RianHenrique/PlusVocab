import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';

class FillInTheBlanksPracticeBody extends StatelessWidget {
  const FillInTheBlanksPracticeBody({
    super.key,
    required this.textBeforeBlank,
    required this.textAfterBlank,
    required this.answerController,
    required this.placeholder,
    required this.onAnswerChanged,
    required this.fieldBorderColor,
  });

  final String textBeforeBlank;
  final String textAfterBlank;
  final TextEditingController answerController;
  final String placeholder;
  final VoidCallback onAnswerChanged;
  final Color fieldBorderColor;

  @override
  Widget build(BuildContext context) {
    final sentenceStyle = GoogleFonts.lexend(
      fontSize: 19,
      fontWeight: FontWeight.bold,
      color: AppColors.primaria,
      height: 1.24,
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 6,
            children: [
              Text(textBeforeBlank, style: sentenceStyle),
              DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.primaria, width: 2),
                  ),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 24),
                  child: const SizedBox.shrink(),
                ),
              ),
              Text(textAfterBlank, style: sentenceStyle),
            ],
          ),
          const SizedBox(height: 18),
          TextField(
            controller: answerController,
            onChanged: (_) => onAnswerChanged(),
            textCapitalization: TextCapitalization.sentences,
            style: GoogleFonts.lexend(
              fontSize: 16,
              color: AppColors.textoPreto,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: GoogleFonts.lexend(
                fontSize: 14,
                color: AppColors.textoHint,
              ),
              filled: true,
              fillColor: AppColors.branco,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: fieldBorderColor, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: fieldBorderColor, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: fieldBorderColor, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
