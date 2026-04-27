import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/pratica/exercicio/widgets/practice_audio_transcription_sheet.dart';
import 'package:plus_vocab/features/pratica/exercicio/widgets/practice_feedback_models.dart';

/// Painel de feedback na base da tela após enviar resposta (acerto / erro).
class PracticeFeedbackSheet extends StatelessWidget {
  const PracticeFeedbackSheet({
    super.key,
    required this.content,
  });

  final PracticeFeedbackContent content;

  static Future<void> show(BuildContext context, PracticeFeedbackContent content) {
    return showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PracticeFeedbackSheet(content: content),
    );
  }

  Color get _accent => content.isCorrect ? AppColors.primaria : AppColors.erro;

  String get _title {
    return content.isCorrect
        ? 'Muito bem! Você acertou.'
        : 'Quase! Mas você está evoluindo.';
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bottomInset = mq.viewPadding.bottom;
    final keyboardInset = mq.viewInsets.bottom;
    final showTranscriptionLink =
        !content.hideAnswerDetails && content.audioTranscriptions.isNotEmpty;
    final showAnswerBlocks = !content.hideAnswerDetails;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.branco,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          boxShadow: [
            BoxShadow(
              color: AppColors.sombraElevacao.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottomInset),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.bordaCampo,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _accent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          content.isCorrect ? Icons.check_rounded : Icons.close_rounded,
                          color: AppColors.branco,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _title,
                          style: GoogleFonts.lexend(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _accent,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (showAnswerBlocks &&
                      !content.isCorrect &&
                      content.userAnswerText != null) ...[
                    const SizedBox(height: 18),
                    Text(
                      'Sua resposta',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textoSuave,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _AnswerBox(
                      text: content.userAnswerText!,
                      textColor: AppColors.erro,
                    ),
                  ],
                  if (showAnswerBlocks) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Resposta correta',
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textoSuave,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _AnswerBox(
                      text: content.correctAnswerText.isEmpty ? '—' : content.correctAnswerText,
                      textColor: AppColors.primaria,
                    ),
                  ],
                  if (showTranscriptionLink) ...[
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          PracticeAudioTranscriptionSheet.show(
                            context,
                            entries: content.audioTranscriptions,
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaria,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Ver transcrição do áudio',
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaria,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaria,
                        foregroundColor: AppColors.branco,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Continuar',
                        style: GoogleFonts.lexend(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnswerBox extends StatelessWidget {
  const _AnswerBox({
    required this.text,
    required this.textColor,
  });

  final String text;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.branco,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.bordaCampo),
      ),
      child: Text(
        text,
        style: GoogleFonts.lexend(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          height: 1.35,
          color: textColor,
        ),
      ),
    );
  }
}
