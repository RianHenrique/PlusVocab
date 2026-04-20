import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/pratica/exercicio/layout/exercise_practice_shell.dart';
import 'package:plus_vocab/features/pratica/exercicio/modalidades/listening_comprehension_practice_body.dart';
import 'package:plus_vocab/features/pratica/exercicio/models/listening_comprehension_models.dart';

class ListeningComprehensionExerciseScreen extends StatefulWidget {
  const ListeningComprehensionExerciseScreen({
    super.key,
    required this.practiceTitle,
    required this.question,
    this.currentStepIndex = 3,
    this.totalSteps = 5,
  });

  final String practiceTitle;
  final ListeningComprehensionQuestion question;
  final int currentStepIndex;
  final int totalSteps;

  factory ListeningComprehensionExerciseScreen.sampleRestaurant({String practiceTitle = 'Ida a um restaurante'}) {
    return ListeningComprehensionExerciseScreen(
      practiceTitle: practiceTitle,
      question: ListeningComprehensionQuestion.sampleRestaurant(),
    );
  }

  @override
  State<ListeningComprehensionExerciseScreen> createState() => _ListeningComprehensionExerciseScreenState();
}

class _ListeningComprehensionExerciseScreenState extends State<ListeningComprehensionExerciseScreen> {
  late FlutterTts _tts;

  bool _speaking = false;
  int? _selectedIndex;
  bool _showResult = false;
  int? _submittedIndex;

  bool get _canSubmit => _selectedIndex != null;

  @override
  void initState() {
    super.initState();
    widget.question.assertValid();
    _tts = FlutterTts();
    _configureTts();
    _tts.setCompletionHandler(() {
      if (mounted) {
        setState(() => _speaking = false);
      }
    });
  }

  Future<void> _configureTts() async {
    await _tts.setLanguage(widget.question.ttsLanguage);
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> _playListening() async {
    setState(() => _speaking = true);
    await _tts.stop();
    await _tts.speak(widget.question.listeningScript);
  }

  void _onOption(int index) {
    setState(() {
      if (_showResult) {
        _showResult = false;
        _submittedIndex = null;
      }
      _selectedIndex = _selectedIndex == index ? null : index;
    });
  }

  void _onSubmit() {
    if (!_canSubmit) return;

    final ok = ListeningComprehensionEvaluation.isCorrect(
      selectedOptionIndex: _selectedIndex,
      correctOptionIndex: widget.question.correctOptionIndex,
    );

    setState(() {
      _showResult = true;
      _submittedIndex = _selectedIndex;
    });

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
                'Listening Comprehension',
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textoAzul,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Toque no ícone para ouvir o áudio. Em seguida escolha a alternativa correta para a pergunta na tela e envie.',
                style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textoPreto, height: 1.4),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
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
      modalityLabel: 'Listening Comprehension',
      onModalityInfoTap: _onInfoTap,
      miolo: ListeningComprehensionPracticeBody(
        onPlayListening: _playListening,
        isPlayingListening: _speaking,
        questionText: widget.question.questionText,
        options: widget.question.options,
        selectedOptionIndex: _selectedIndex,
        onOptionSelected: _onOption,
        showResult: _showResult,
        correctOptionIndex: widget.question.correctOptionIndex,
        submittedOptionIndex: _submittedIndex,
      ),
      canSubmit: _canSubmit,
      onSubmit: _onSubmit,
      onAbandonPractice: _onAbandon,
    );
  }
}
