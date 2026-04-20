import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/pratica/exercicio/layout/exercise_practice_shell.dart';
import 'package:plus_vocab/features/pratica/exercicio/modalidades/dialogue_completion_practice_body.dart';
import 'package:plus_vocab/features/pratica/exercicio/models/dialogue_completion_models.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class DialogueCompletionExerciseScreen extends StatefulWidget {
  const DialogueCompletionExerciseScreen({
    super.key,
    required this.practiceTitle,
    required this.question,
    this.currentStepIndex = 1,
    this.totalSteps = 5,
  });

  final String practiceTitle;
  final DialogueCompletionQuestion question;
  final int currentStepIndex;
  final int totalSteps;

  factory DialogueCompletionExerciseScreen.sampleRestaurant({String practiceTitle = 'Ida a um restaurante'}) {
    return DialogueCompletionExerciseScreen(
      practiceTitle: practiceTitle,
      question: DialogueCompletionQuestion.sampleRestaurant(),
    );
  }

  @override
  State<DialogueCompletionExerciseScreen> createState() => _DialogueCompletionExerciseScreenState();
}

class _DialogueCompletionExerciseScreenState extends State<DialogueCompletionExerciseScreen> {
  late FlutterTts _tts;
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _speechAvailable = false;
  String _speechListenLocaleId = 'en_US';
  bool _listening = false;
  String _liveTranscript = '';
  String _committedTranscript = '';
  bool? _feedbackCorrect;

  String get _displayTranscript {
    if (_listening && _liveTranscript.isNotEmpty) return _liveTranscript;
    if (_committedTranscript.isNotEmpty) return _committedTranscript;
    return _liveTranscript;
  }

  bool get _canSubmit => _committedTranscript.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    widget.question.assertValid();
    _tts = FlutterTts();
    _configureTts();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initSpeech();
      if (!_speechAvailable && mounted) {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        if (mounted) await _initSpeech();
      }
    });
  }

  Future<void> _configureTts() async {
    await _tts.setLanguage(widget.question.ttsLanguage);
    await _tts.setSpeechRate(0.48);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> _initSpeech() async {
    final ok = await _speech.initialize(
      onStatus: (_) {},
      onError: (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );
    if (ok) {
      final locales = await _speech.locales();
      _speechListenLocaleId = DialogueCompletionSpeechLocales.pickInstalledOrFallback(
        locales.map((e) => e.localeId),
        widget.question.ttsLanguage,
      );
    }
    if (!mounted) return;
    setState(() => _speechAvailable = ok);
  }

  Future<void> _ensureSpeechReady() async {
    if (_speechAvailable) return;
    await _initSpeech();
    if (_speechAvailable || !mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    await _initSpeech();
  }

  Future<void> _playLine(int index) async {
    if (index < 0 || index >= widget.question.obscuredLineAudios.length) return;
    await _tts.stop();
    await _tts.speak(widget.question.obscuredLineAudios[index]);
  }

  Future<void> _onMicDown() async {
    await _ensureSpeechReady();
    if (!_speechAvailable) {
      if (!mounted) return;
      final err = _speech.lastError;
      final hint = err != null ? '\n(${err.errorMsg})' : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 6),
          content: Text(
            'Não foi possível iniciar o reconhecimento de fala. '
            'No Android, verifique o app Google, permissão de microfone e idioma de entrada (inglês).$hint',
            style: GoogleFonts.lexend(color: AppColors.branco, height: 1.35),
          ),
          backgroundColor: AppColors.erro,
        ),
      );
      return;
    }

    setState(() {
      _feedbackCorrect = null;
      _listening = true;
      _liveTranscript = '';
    });

    await _speech.stop();
    await _speech.listen(
      localeId: _speechListenLocaleId,
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _liveTranscript = result.recognizedWords;
          if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
            _committedTranscript = result.recognizedWords.trim();
          }
        });
      },
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  Future<void> _onMicUp() async {
    if (!_listening) return;

    await _speech.stop();

    if (!mounted) return;

    setState(() {
      _listening = false;
      final fallback = _liveTranscript.trim();
      if (_committedTranscript.isEmpty && fallback.isNotEmpty) {
        _committedTranscript = fallback;
      }
      _liveTranscript = '';
    });
  }

  Future<void> _onSkip() async {
    await _speech.stop();
    if (!mounted) return;
    setState(() {
      _listening = false;
      _liveTranscript = '';
      _committedTranscript = '-';
      _feedbackCorrect = false;
    });
    _onSubmit();
  }

  void _onSubmit() {
    if (!_canSubmit) return;

    final ok = DialogueCompletionEvaluation.matchesTranscript(
      userTranscript: _committedTranscript,
      acceptedAnswers: widget.question.acceptedAnswers,
    );

    setState(() => _feedbackCorrect = ok);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Resposta aceita!' : 'Tente de novo com outra formulação.',
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
                'Dialogue Completion',
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textoAzul,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                DialogueCompletionPracticeCopy.infoSheetInstructions,
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
    _speech.stop();
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
      modalityLabel: 'Dialogue Completion',
      onModalityInfoTap: _onInfoTap,
      miolo: DialogueCompletionPracticeBody(
        promptLine: widget.question.promptLine,
        lineCount: widget.question.obscuredLineAudios.length,
        onPlayLine: (i) => _playLine(i),
        userTranscript: _displayTranscript,
        isListening: _listening,
        onMicPointerDown: _onMicDown,
        onMicPointerUpOrCancel: _onMicUp,
        transcriptFeedbackCorrect: _feedbackCorrect,
        onSkip: _onSkip,
      ),
      canSubmit: _canSubmit,
      onSubmit: _onSubmit,
      onAbandonPractice: _onAbandon,
    );
  }
}
