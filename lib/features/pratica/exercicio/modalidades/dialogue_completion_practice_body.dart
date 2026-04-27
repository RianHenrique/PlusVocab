import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';

class DialogueCompletionPracticeBody extends StatelessWidget {
  const DialogueCompletionPracticeBody({
    super.key,
    required this.promptLine,
    required this.lineCount,
    required this.onPlayLine,
    required this.userTranscript,
    required this.isListening,
    required this.onMicPointerDown,
    required this.onMicPointerUpOrCancel,
    this.transcriptFeedbackCorrect,
    this.onSkip,
    this.microphoneEnabled = true,
  });

  final String promptLine;
  final int lineCount;
  final ValueChanged<int> onPlayLine;
  final String userTranscript;
  final bool isListening;
  final VoidCallback onMicPointerDown;
  final VoidCallback onMicPointerUpOrCancel;
  final bool? transcriptFeedbackCorrect;
  final bool microphoneEnabled;

  /// Se não for nulo, exibe o botão "Pular" ao final (preenche resposta inválida e segue o fluxo de envio).
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final transcriptBorder = transcriptFeedbackCorrect == null
        ? AppColors.bordaCampo
        : (transcriptFeedbackCorrect! ? AppColors.acerto : AppColors.erro);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            promptLine,
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaria,
              height: 1.28,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(lineCount, (index) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : 6,
                    right: index == lineCount - 1 ? 0 : 6,
                  ),
                  child: Material(
                    color: AppColors.branco,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () => onPlayLine(index),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.bordaCampo),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.volume_up_rounded,
                                color: AppColors.primaria, size: 24),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final style = GoogleFonts.lexend(
                                    fontSize: 13,
                                    letterSpacing: 0.5,
                                    color: AppColors.textoSuave,
                                  );
                                  const dot = '·';
                                  final painter = TextPainter(
                                    text: TextSpan(text: dot, style: style),
                                    textDirection: TextDirection.ltr,
                                  )..layout();
                                  final w = painter.width;
                                  final count = w > 0
                                      ? (constraints.maxWidth / w).floor()
                                      : 12;
                                  final safeCount = count.clamp(8, 200);
                                  return Text(
                                    List.filled(safeCount, dot).join(),
                                    maxLines: 1,
                                    overflow: TextOverflow.clip,
                                    style: style,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Text(
            'Segure para gravar',
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: 14,
              color: AppColors.textoSuave,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown:
                  microphoneEnabled ? (_) => onMicPointerDown() : null,
              onPointerUp:
                  microphoneEnabled ? (_) => onMicPointerUpOrCancel() : null,
              onPointerCancel:
                  microphoneEnabled ? (_) => onMicPointerUpOrCancel() : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isListening ? AppColors.primaria : AppColors.branco,
                  border: Border.all(
                    color: AppColors.primaria,
                    width: isListening ? 0 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.sombraElevacao
                          .withValues(alpha: isListening ? 0.22 : 0.15),
                      blurRadius: isListening ? 12 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.mic,
                  size: 38,
                  color: isListening ? AppColors.branco : AppColors.textoPreto,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Você falou:',
            style: GoogleFonts.lexend(
              fontSize: 14,
              color: AppColors.textoSuave,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.branco,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: transcriptBorder),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sombraCard,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              userTranscript.isEmpty ? '—' : userTranscript,
              textAlign: TextAlign.center,
              style: GoogleFonts.lexend(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.28,
                color: userTranscript.isEmpty
                    ? AppColors.textoHint
                    : AppColors.textoPreto,
              ),
            ),
          ),
          if (onSkip != null) ...[
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textoSecundario,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(
                  'Pular',
                  style: GoogleFonts.lexend(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
