import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/pratica/exercicio/layout/exercise_practice_shell.dart';
import 'package:plus_vocab/features/pratica/exercicio/modalidades/vocabulary_match_practice_body.dart';
import 'package:plus_vocab/features/pratica/exercicio/models/vocabulary_match_models.dart';

class VocabularyMatchExerciseScreen extends StatefulWidget {
  const VocabularyMatchExerciseScreen({
    super.key,
    required this.practiceTitle,
    required this.question,
    this.currentStepIndex = 0,
    this.totalSteps = 5,
  });

  final String practiceTitle;
  final VocabularyMatchQuestion question;
  final int currentStepIndex;
  final int totalSteps;

  /// Exemplo alinhado ao layout enviado (Figma).
  factory VocabularyMatchExerciseScreen.sampleRestaurant({String practiceTitle = 'Ida a um restaurante'}) {
    return VocabularyMatchExerciseScreen(
      practiceTitle: practiceTitle,
      question: VocabularyMatchQuestion.sampleRestaurant(),
    );
  }

  @override
  State<VocabularyMatchExerciseScreen> createState() => _VocabularyMatchExerciseScreenState();
}

class _VocabularyMatchExerciseScreenState extends State<VocabularyMatchExerciseScreen> {
  int? _selectedWordIndex;
  late List<int?> _associations;
  VocabularyMatchEvaluation? _feedback;

  @override
  void initState() {
    super.initState();
    widget.question.assertValid();
    _associations = List<int?>.filled(widget.question.definitions.length, null);
  }

  bool get _allFilled => _associations.every((e) => e != null);

  void _onWordTap(int wordIndex) {
    setState(() {
      _feedback = null;
      _selectedWordIndex = _selectedWordIndex == wordIndex ? null : wordIndex;
    });
  }

  void _onDefinitionTap(int definitionIndex) {
    if (_selectedWordIndex == null) return;

    setState(() {
      _feedback = null;
      final word = _selectedWordIndex!;
      for (var i = 0; i < _associations.length; i++) {
        if (_associations[i] == word) {
          _associations[i] = null;
        }
      }
      _associations[definitionIndex] = word;
      _selectedWordIndex = null;
    });
  }

  void _onSubmit() {
    if (!_allFilled) return;

    final result = VocabularyMatchEvaluation.evaluate(
      question: widget.question,
      associations: _associations,
    );

    setState(() => _feedback = result);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.isFullyCorrect ? 'Tudo certo!' : 'Revise as associações incorretas.',
          style: GoogleFonts.lexend(color: AppColors.branco),
        ),
        backgroundColor: result.isFullyCorrect ? AppColors.acerto : AppColors.erro,
      ),
    );
  }

  Future<void> _onAbandon() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Abandonar partida?', style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
          content: Text(
            'O progresso desta partida será perdido.',
            style: GoogleFonts.lexend(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Continuar', style: GoogleFonts.lexend(color: AppColors.primaria)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Sair', style: GoogleFonts.lexend(color: AppColors.erro)),
            ),
          ],
        );
      },
    );

    if (leave == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _onInfoTap() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vocabulary Match',
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textoAzul,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Toque em uma palavra e depois na definição correspondente para associar. '
                'Envie quando todos os espaços estiverem preenchidos.',
                style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textoPreto, height: 1.4),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExercisePracticeShell(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textoPreto),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      practiceTitle: widget.practiceTitle,
      currentStepIndex: widget.currentStepIndex,
      totalSteps: widget.totalSteps,
      modalityLabel: 'Vocabulary Match',
      onModalityInfoTap: _onInfoTap,
      miolo: VocabularyMatchPracticeBody(
        question: widget.question,
        selectedWordIndex: _selectedWordIndex,
        associations: _associations,
        onWordTap: _onWordTap,
        onDefinitionTap: _onDefinitionTap,
        feedback: _feedback,
      ),
      canSubmit: _allFilled,
      onSubmit: _onSubmit,
      onAbandonPractice: _onAbandon,
    );
  }
}
