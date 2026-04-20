import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/pratica/exercicio/models/practice_session_models.dart';

/// Resumo ao fim da prática: pontuação, grade por exercício, sugestões e ações.
class PracticeSessionSummaryScreen extends StatelessWidget {
  const PracticeSessionSummaryScreen({
    super.key,
    required this.outcome,
    required this.lessonTitle,
    required this.onLeavePractice,
    required this.onStartNewMatch,
  });

  final PracticeSessionOutcome outcome;
  final String lessonTitle;
  final VoidCallback onLeavePractice;
  final VoidCallback onStartNewMatch;

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

  @override
  Widget build(BuildContext context) {
    final theme = GoogleFonts.lexend();
    final total = outcome.totalExercicios;
    final pct = total == 0 ? 0 : ((outcome.totalCorretos / total) * 100).round();

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
                        ..._resultRows(theme),
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
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Adicionar "$w" ao dicionário — em breve.',
                                        style: theme.copyWith(color: AppColors.branco),
                                      ),
                                      backgroundColor: AppColors.primaria,
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.bordaCampo),
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
                            style: theme.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
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

  List<Widget> _resultRows(TextStyle theme) {
    final list = outcome.resultados;
    final out = <Widget>[];
    for (var i = 0; i < list.length; i += 2) {
      final left = _resultCell(i, list[i], theme);
      final right = i + 1 < list.length ? _resultCell(i + 1, list[i + 1], theme) : const SizedBox();
      out.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: left),
              const SizedBox(width: 16),
              Expanded(child: right),
            ],
          ),
        ),
      );
    }
    return out;
  }

  Widget _resultCell(int index, ExerciseResultEntry r, TextStyle theme) {
    final n = index + 1;
    final label = '$n. ${_modalityLabel(r.modalidade)}';
    final ok = r.foiCorreto;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.copyWith(
            fontSize: 15,
            color: AppColors.textoSuave,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          ok ? 'Correta!' : 'Incorreta!',
          style: theme.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: ok ? AppColors.primaria : AppColors.erro,
          ),
        ),
      ],
    );
  }
}
