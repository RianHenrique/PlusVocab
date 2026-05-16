import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/dicionario/models/dicionario_service.dart';
import 'package:plus_vocab/features/pratica/exercicio/models/practice_session_models.dart';
import 'package:provider/provider.dart';

/// Resumo ao fim da prática: pontuação, grade por exercício, sugestões e ações.
class PracticeSessionSummaryScreen extends StatelessWidget {
  const PracticeSessionSummaryScreen({
    super.key,
    required this.outcome,
    required this.lessonTitle,
    required this.onLeavePractice,
    required this.onStartNewMatch,
    this.onReviewQuestionTap,
  });

  final PracticeSessionOutcome outcome;
  final String lessonTitle;
  final VoidCallback onLeavePractice;
  final VoidCallback onStartNewMatch;
  final ValueChanged<int>? onReviewQuestionTap;

  static String _modalityLabel(String modality) {
    switch (modality) {
      case PracticeExerciseModality.vocabMatch:
        return 'Vocabulary Match';
      case PracticeExerciseModality.listeningComprehension:
        return 'Listening Comprehension';
      case PracticeExerciseModality.fillBlanks:
        return 'Fill in the Blanks';
      case PracticeExerciseModality.dialogueCompletion:
        return 'Dialogue Completion';
      default:
        return modality.replaceAll('_', ' ');
    }
  }

  static String _displayWord(String w) {
    final t = w.trim();
    if (t.isEmpty) return t;
    return t[0].toUpperCase() + t.substring(1);
  }

  static Future<void> _confirmarEAdicionarPalavra(
      BuildContext context, String word) async {
    final theme = GoogleFonts.lexend();
    final label = _displayWord(word);
    final service = context.read<DicionarioService>();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        var loading = false;
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return PopScope(
              canPop: !loading,
              child: AlertDialog(
                title: Text(
                  'Adicionar ao dicionário',
                  style: GoogleFonts.lexend(
                      fontWeight: FontWeight.w600, color: AppColors.textoAzul),
                ),
                content: loading
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            color: AppColors.primaria,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Adicionando ao dicionário…',
                            textAlign: TextAlign.center,
                            style:
                                GoogleFonts.lexend(fontSize: 14, height: 1.4),
                          ),
                        ],
                      )
                    : Text(
                        'Deseja adicionar "$label" ao seu dicionário?',
                        style: GoogleFonts.lexend(fontSize: 14, height: 1.4),
                      ),
                actions: loading
                    ? const <Widget>[]
                    : [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text('Cancelar',
                              style: GoogleFonts.lexend(
                                  color: AppColors.textoSecundario)),
                        ),
                        FilledButton(
                          onPressed: () async {
                            setDialogState(() => loading = true);
                            try {
                              final result =
                                  await service.adicionarPalavra(word);
                              if (!ctx.mounted) return;
                              Navigator.of(ctx).pop();
                              if (!context.mounted) return;
                              final msg = result.reativada
                                  ? 'A palavra "$label" já estava no dicionário e foi reativada.'
                                  : 'Palavra "$label" adicionada ao dicionário.';
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(msg,
                                      style: theme.copyWith(
                                          color: AppColors.branco)),
                                  backgroundColor: AppColors.primaria,
                                ),
                              );
                            } catch (e) {
                              if (!ctx.mounted) return;
                              Navigator.of(ctx).pop();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString(),
                                      style: theme.copyWith(
                                          color: AppColors.branco)),
                                  backgroundColor: AppColors.erro,
                                ),
                              );
                            }
                          },
                          style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primaria),
                          child: Text('Adicionar',
                              style:
                                  GoogleFonts.lexend(color: AppColors.branco)),
                        ),
                      ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = GoogleFonts.lexend();
    final total = outcome.totalExercicios;
    final pct =
        total == 0 ? 0 : ((outcome.totalCorretos / total) * 100).round();

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Prática finalizada',
                          textAlign: TextAlign.center,
                          style: theme.copyWith(
                            fontSize: 13,
                            color: AppColors.textoSuave,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          lessonTitle,
                          textAlign: TextAlign.center,
                          style: theme.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaria,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Sua pontuação foi',
                          textAlign: TextAlign.center,
                          style: theme.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textoSuave,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$pct%',
                          textAlign: TextAlign.center,
                          style: theme.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaria,
                          ),
                        ),
                        const SizedBox(height: 28),
                        if (onReviewQuestionTap != null &&
                            outcome.resultados.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.touch_app_outlined,
                                  size: 15, color: AppColors.primaria),
                              const SizedBox(width: 4),
                              Text(
                                'Toque na questão para rever sua resposta',
                                style: theme.copyWith(
                                  fontSize: 13,
                                  color: AppColors.primaria,
                                  fontWeight: FontWeight.w500,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                        _resultGrid(theme),
                        const SizedBox(height: 28),
                        Text(
                          'Sugestão de palavra da partida',
                          style: theme.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textoAzul,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: outcome.sugestoesPalavras.map((w) {
                            return Material(
                              color: AppColors.branco,
                              borderRadius: BorderRadius.circular(12),
                              elevation: 1,
                              shadowColor: AppColors.sombraCard,
                              child: InkWell(
                                onTap: () =>
                                    _confirmarEAdicionarPalavra(context, w),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: AppColors.bordaCampo),
                                  ),
                                  child: Text(
                                    _displayWord(w),
                                    style: theme.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaria,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Clique na palavra para adicioná-la ao seu dicionário',
                          style: theme.copyWith(
                            fontSize: 12,
                            color: AppColors.textoSuave,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: onStartNewMatch,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColors.primaria,
                            foregroundColor: AppColors.branco,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Iniciar nova partida',
                            style: theme.copyWith(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: onLeavePractice,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.erro,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: Text(
                          'Deixar prática',
                          style: theme.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.erro,
                          ),
                        ),
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

  Widget _resultGrid(TextStyle theme) {
    final items = outcome.resultados;
    if (items.isEmpty) return const SizedBox.shrink();
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += 2) {
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _resultCell(i, items[i], theme)),
              const SizedBox(width: 10),
              if (i + 1 < items.length)
                Expanded(child: _resultCell(i + 1, items[i + 1], theme))
              else
                const Expanded(child: SizedBox.shrink()),
            ],
          ),
        ),
      );
      if (i + 2 < items.length) rows.add(const SizedBox(height: 10));
    }
    return Column(children: rows);
  }

  Widget _resultCell(int index, ExerciseResultEntry r, TextStyle theme) {
    final n = index + 1;
    final label = '$n. ${_modalityLabel(r.modalidade)}';
    final ok = r.foiCorreto;
    final acertoCor = ok ? AppColors.acerto : AppColors.erro;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.copyWith(
            fontSize: 12,
            color: AppColors.textoSuave,
            height: 1.25,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                ok ? 'Correta!' : 'Incorreta!',
                style: theme.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: acertoCor,
                ),
              ),
            ),
            if (onReviewQuestionTap != null)
              Icon(Icons.chevron_right_rounded, color: acertoCor, size: 20),
          ],
        ),
      ],
    );

    if (onReviewQuestionTap == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: acertoCor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: acertoCor.withValues(alpha: 0.25)),
        ),
        child: content,
      );
    }

    return Material(
      color: acertoCor.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onReviewQuestionTap!(index),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: acertoCor.withValues(alpha: 0.25)),
          ),
          child: content,
        ),
      ),
    );
  }
}
