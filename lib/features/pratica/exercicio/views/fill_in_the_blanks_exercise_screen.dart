import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/pratica/exercicio/layout/exercise_practice_shell.dart';
import 'package:plus_vocab/features/pratica/exercicio/modalidades/fill_in_the_blanks_practice_body.dart';
import 'package:plus_vocab/features/pratica/exercicio/models/fill_in_the_blanks_models.dart';

class FillInTheBlanksExerciseScreen extends StatefulWidget {
  const FillInTheBlanksExerciseScreen({
    super.key,
    required this.practiceTitle,
    required this.question,
    this.currentStepIndex = 0,
    this.totalSteps = 5,
  });

  final String practiceTitle;
  final FillInTheBlanksQuestion question;
  final int currentStepIndex;
  final int totalSteps;

  factory FillInTheBlanksExerciseScreen.sampleRestaurant({String practiceTitle = 'Ida a um restaurante'}) {
    return FillInTheBlanksExerciseScreen(
      practiceTitle: practiceTitle,
      question: FillInTheBlanksQuestion.sampleRestaurant(),
    );
  }

  @override
  State<FillInTheBlanksExerciseScreen> createState() => _FillInTheBlanksExerciseScreenState();
}

class _FillInTheBlanksExerciseScreenState extends State<FillInTheBlanksExerciseScreen> {
  late final TextEditingController _answerController;
  bool? _feedbackCorrect;

  bool get _canSubmit => _answerController.text.trim().isNotEmpty;

  Color get _fieldBorderColor {
    if (_feedbackCorrect == null) return AppColors.bordaCampo;
    return _feedbackCorrect! ? AppColors.acerto : AppColors.erro;
  }

  @override
  void initState() {
    super.initState();
    widget.question.assertValid();
    _answerController = TextEditingController();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _onAnswerChanged() {
    setState(() {
      _feedbackCorrect = null;
    });
  }

  void _onSubmit() {
    if (!_canSubmit) return;

    final ok = FillInTheBlanksEvaluation.matchesAnswer(
      userAnswer: _answerController.text,
      acceptedAnswers: widget.question.acceptedAnswers,
    );

    setState(() => _feedbackCorrect = ok);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Resposta correta!' : 'Resposta incorreta.',
          style: GoogleFonts.lexend(color: AppColors.branco),
        ),
        backgroundColor: ok ? AppColors.acerto : AppColors.erro,
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
                'Fill in the Blanks',
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textoAzul,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Complete a lacuna na frase usando o campo abaixo e envie para correção. A resposta da lacula é a uma das palavras anteriormente vista nessa partida.',
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
      modalityLabel: 'Fill in the Blanks',
      onModalityInfoTap: _onInfoTap,
      miolo: FillInTheBlanksPracticeBody(
        textBeforeBlank: widget.question.textBeforeBlank,
        textAfterBlank: widget.question.textAfterBlank,
        answerController: _answerController,
        placeholder: widget.question.placeholder,
        onAnswerChanged: _onAnswerChanged,
        fieldBorderColor: _fieldBorderColor,
      ),
      canSubmit: _canSubmit,
      onSubmit: _onSubmit,
      onAbandonPractice: _onAbandon,
    );
  }
}
