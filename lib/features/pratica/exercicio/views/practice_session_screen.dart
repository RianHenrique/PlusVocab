import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/pratica/exercicio/layout/exercise_practice_shell.dart';
import 'package:plus_vocab/features/pratica/exercicio/logic/practice_session_exercise_adapters.dart';
import 'package:plus_vocab/features/pratica/exercicio/modalidades/dialogue_completion_practice_body.dart';
import 'package:plus_vocab/features/pratica/exercicio/modalidades/fill_in_the_blanks_practice_body.dart';
import 'package:plus_vocab/features/pratica/exercicio/modalidades/listening_comprehension_practice_body.dart';
import 'package:plus_vocab/features/pratica/exercicio/modalidades/vocabulary_match_practice_body.dart';
import 'package:plus_vocab/features/pratica/exercicio/models/fill_in_the_blanks_models.dart';
import 'package:plus_vocab/features/pratica/exercicio/models/listening_comprehension_models.dart';
import 'package:plus_vocab/features/pratica/exercicio/data/vocab_practice_service.dart';
import 'package:plus_vocab/features/pratica/exercicio/models/dialogue_completion_models.dart';
import 'package:plus_vocab/features/pratica/exercicio/models/practice_session_models.dart';
import 'package:plus_vocab/features/pratica/exercicio/models/vocabulary_match_models.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:plus_vocab/features/pratica/exercicio/views/practice_session_loading_screen.dart';
import 'package:plus_vocab/features/pratica/exercicio/views/practice_session_summary_screen.dart';
import 'package:plus_vocab/features/pratica/exercicio/widgets/practice_audio_transcription_builder.dart';
import 'package:plus_vocab/features/pratica/exercicio/widgets/practice_audio_transcription_sheet.dart';
import 'package:plus_vocab/features/pratica/exercicio/widgets/practice_feedback_content_builder.dart';
import 'package:plus_vocab/features/pratica/exercicio/widgets/practice_feedback_sheet.dart';
import 'package:plus_vocab/features/pratica/exercicio/widgets/practice_feedback_models.dart';
import 'package:provider/provider.dart';

class _ExerciseSlotState {
  List<int?>? vocabularyAssociations;
  int? vocabularySelectedWord;
  VocabularyMatchEvaluation? vocabularyFeedback;

  int? listeningSelected;
  bool listeningShowResult = false;
  int? listeningSubmitted;

  String fillDraft = '';

  String dialogueCommittedTranscript = '';
  String dialogueLiveTranscript = '';
  bool dialogueListening = false;
  bool? dialogueTranscriptFeedback;
}

class PracticeSessionReviewSlotSnapshot {
  const PracticeSessionReviewSlotSnapshot({
    this.vocabularyAssociations,
    this.vocabularyFeedback,
    this.listeningSelected,
    this.listeningShowResult = false,
    this.listeningSubmitted,
    this.fillDraft = '',
    this.dialogueCommittedTranscript = '',
    this.dialogueTranscriptFeedback,
    this.vocabularyQuestionFrozen,
    this.listeningQuestionFrozen,
  });

  final List<int?>? vocabularyAssociations;
  final VocabularyMatchEvaluation? vocabularyFeedback;
  final int? listeningSelected;
  final bool listeningShowResult;
  final int? listeningSubmitted;
  final String fillDraft;
  final String dialogueCommittedTranscript;
  final bool? dialogueTranscriptFeedback;

  /// Instância usada na partida (mesmo embaralhamento da UI); necessário para revisão bater com os índices salvos.
  final VocabularyMatchQuestion? vocabularyQuestionFrozen;
  final ListeningComprehensionQuestion? listeningQuestionFrozen;
}

class PracticeSessionReviewSnapshot {
  const PracticeSessionReviewSnapshot({
    required this.slots,
    required this.resultados,
  });

  final List<PracticeSessionReviewSlotSnapshot> slots;
  final List<ExerciseResultEntry> resultados;
}

/// Orquestra a lista de exercícios da sessão: respostas em memória, correção local e fluxo até o resumo.
class PracticeSessionScreen extends StatefulWidget {
  const PracticeSessionScreen({
    super.key,
    required this.session,
    this.practiceTitle = 'Prática PlusVocab',
    this.themeId,
    this.reviewSnapshot,
    this.initialExerciseIndex = 0,
  });

  final PracticeSessionPayload session;
  final String practiceTitle;

  /// Identificador do tema na API; usado para nova partida e fluxo que vem da lista de temas.
  final String? themeId;
  final PracticeSessionReviewSnapshot? reviewSnapshot;
  final int initialExerciseIndex;

  @override
  State<PracticeSessionScreen> createState() => _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends State<PracticeSessionScreen> {
  late final List<_ExerciseSlotState> _slots;
  late final List<ExerciseResultEntry?> _resultados;
  late final TextEditingController _fillController;
  late FlutterTts _tts;
  int _currentIndex = 0;
  bool _listeningSpeaking = false;
  bool _isBetweenExercises = false;

  /// Ordem embaralhada fixa por índice (evita re-sort a cada rebuild).
  final Map<int, VocabularyMatchQuestion> _vocabularyQuestionByIndex = {};
  final Map<int, ListeningComprehensionQuestion> _listeningQuestionByIndex = {};
  final Map<int, DialogueCompletionQuestion> _dialogueQuestionByIndex = {};

  final stt.SpeechToText _dialogueSpeech = stt.SpeechToText();
  bool _dialogueSpeechReady = false;
  String _dialogueListenLocaleId = 'en_US';

  PracticeSessionPayload get _session => widget.session;
  bool get _isReviewMode => widget.reviewSnapshot != null;

  int get _total => _session.exercicios.length;

  PracticeExerciseItem get _currentItem => _session.exercicios[_currentIndex];

  VocabularyMatchQuestion _vocabularyQuestionForIndex(int index) {
    return _vocabularyQuestionByIndex.putIfAbsent(
      index,
      () => PracticeSessionExerciseAdapters.vocabularyMatchFromItem(
        _session.exercicios[index],
        practiceSessionId: _session.practiceSessionId,
        exerciseIndex: index,
      ),
    );
  }

  ListeningComprehensionQuestion _listeningQuestionForIndex(int index) {
    return _listeningQuestionByIndex.putIfAbsent(
      index,
      () => PracticeSessionExerciseAdapters.listeningFromItem(
        _session.exercicios[index],
        practiceSessionId: _session.practiceSessionId,
        exerciseIndex: index,
      ),
    );
  }

  DialogueCompletionQuestion _dialogueQuestionForIndex(int index) {
    return _dialogueQuestionByIndex.putIfAbsent(
      index,
      () => PracticeSessionExerciseAdapters.dialogueCompletionFromItem(
          _session.exercicios[index]),
    );
  }

  String _dialogueDisplayTranscript(_ExerciseSlotState slot) {
    if (slot.dialogueListening && slot.dialogueLiveTranscript.isNotEmpty) {
      return slot.dialogueLiveTranscript;
    }
    if (slot.dialogueCommittedTranscript.isNotEmpty) {
      return slot.dialogueCommittedTranscript;
    }
    return slot.dialogueLiveTranscript;
  }

  Future<void> _initDialogueSpeech() async {
    final ok = await _dialogueSpeech.initialize(
      onStatus: (_) {},
      onError: (_) {
        if (mounted) setState(() {});
      },
    );
    if (ok) {
      final locales = await _dialogueSpeech.locales();
      _dialogueListenLocaleId =
          DialogueCompletionSpeechLocales.pickInstalledOrFallback(
        locales.map((e) => e.localeId),
        'en-US',
      );
    }
    if (!mounted) return;
    setState(() => _dialogueSpeechReady = ok);
  }

  Future<void> _ensureDialogueSpeechReady() async {
    if (_dialogueSpeechReady) return;
    await _initDialogueSpeech();
    if (_dialogueSpeechReady || !mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    await _initDialogueSpeech();
  }

  Future<void> _playDialogueLine(int index) async {
    if (_currentIndex < 0 || _currentIndex >= _total) return;
    if (_session.exercicios[_currentIndex].modalidade !=
        PracticeExerciseModality.dialogueCompletion) {
      return;
    }
    final q = _dialogueQuestionForIndex(_currentIndex);
    if (index < 0 || index >= q.obscuredLineAudios.length) return;
    await _tts.setLanguage(q.ttsLanguage);
    await _tts.setSpeechRate(0.48);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.stop();
    await _tts.speak(q.obscuredLineAudios[index]);
  }

  Future<void> _dialogueMicDown() async {
    await _ensureDialogueSpeechReady();
    if (!_dialogueSpeechReady) {
      if (!mounted) return;
      final err = _dialogueSpeech.lastError;
      final hint = err != null
          ? '\n\nDetalhe técnico: ${err.errorMsg}'
          : '\n\nConfira se o reconhecimento de voz do Google está ativo e atualizado nas configurações do Android.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 6),
          content: Text(
            'Não foi possível iniciar o reconhecimento de fala do aparelho. '
            'No Android, além do microfone, o sistema precisa do serviço de voz (em geral pelo app Google). '
            'Confira se ele está instalado e atualizado e se o idioma de entrada inclui inglês.$hint',
            style: GoogleFonts.lexend(color: AppColors.branco, height: 1.35),
          ),
          backgroundColor: AppColors.erro,
        ),
      );
      return;
    }
    final slot = _slots[_currentIndex];
    setState(() {
      slot.dialogueTranscriptFeedback = null;
      slot.dialogueListening = true;
      slot.dialogueLiveTranscript = '';
    });
    await _dialogueSpeech.stop();
    await _dialogueSpeech.listen(
      localeId: _dialogueListenLocaleId,
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          final s = _slots[_currentIndex];
          s.dialogueLiveTranscript = result.recognizedWords;
          if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
            s.dialogueCommittedTranscript = result.recognizedWords.trim();
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

  Future<void> _dialogueMicUp() async {
    final slot = _slots[_currentIndex];
    if (!slot.dialogueListening) return;
    await _dialogueSpeech.stop();
    if (!mounted) return;
    setState(() {
      slot.dialogueListening = false;
      final fallback = slot.dialogueLiveTranscript.trim();
      if (slot.dialogueCommittedTranscript.isEmpty && fallback.isNotEmpty) {
        slot.dialogueCommittedTranscript = fallback;
      }
      slot.dialogueLiveTranscript = '';
    });
  }

  void _skipDialogueExercise() {
    if (_isBetweenExercises) return;
    if (_currentItem.modalidade != PracticeExerciseModality.dialogueCompletion)
      return;
    final slot = _slots[_currentIndex];
    unawaited(_dialogueSpeech.stop());
    setState(() {
      slot.dialogueListening = false;
      slot.dialogueLiveTranscript = '';
      slot.dialogueCommittedTranscript = '-';
      slot.dialogueTranscriptFeedback = false;
    });
    _onPrimarySubmit();
  }

  @override
  void initState() {
    super.initState();
    final clampedInitialIndex = _total == 0
        ? 0
        : widget.initialExerciseIndex.clamp(0, _total - 1) as int;
    _currentIndex = clampedInitialIndex;
    _slots =
        List<_ExerciseSlotState>.generate(_total, (_) => _ExerciseSlotState());
    _resultados = List<ExerciseResultEntry?>.filled(_total, null);
    if (_isReviewMode) {
      _restoreFromReviewSnapshot(widget.reviewSnapshot!);
    }
    _fillController = TextEditingController();
    _tts = FlutterTts();
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _listeningSpeaking = false);
    });
    _syncFillControllerFromSlot();
    if (!_isReviewMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _initDialogueSpeech();
        if (!_dialogueSpeechReady && mounted) {
          await Future<void>.delayed(const Duration(milliseconds: 500));
          if (mounted) await _initDialogueSpeech();
        }
      });
    }
  }

  @override
  void dispose() {
    _fillController.dispose();
    _tts.stop();
    _dialogueSpeech.stop();
    super.dispose();
  }

  void _restoreFromReviewSnapshot(PracticeSessionReviewSnapshot snapshot) {
    for (var i = 0; i < _total; i++) {
      if (i < snapshot.slots.length) {
        final source = snapshot.slots[i];
        final target = _slots[i];
        target.vocabularyAssociations = source.vocabularyAssociations == null
            ? null
            : List<int?>.from(source.vocabularyAssociations!);
        target.vocabularyFeedback = source.vocabularyFeedback == null
            ? null
            : VocabularyMatchEvaluation(
                isFullyCorrect: source.vocabularyFeedback!.isFullyCorrect,
                perDefinitionCorrect: List<bool>.from(
                    source.vocabularyFeedback!.perDefinitionCorrect),
              );
        target.listeningSelected = source.listeningSelected;
        target.listeningShowResult = source.listeningShowResult;
        target.listeningSubmitted = source.listeningSubmitted;
        target.fillDraft = source.fillDraft;
        target.dialogueCommittedTranscript = source.dialogueCommittedTranscript;
        target.dialogueTranscriptFeedback = source.dialogueTranscriptFeedback;
        if (source.vocabularyQuestionFrozen != null) {
          _vocabularyQuestionByIndex[i] = source.vocabularyQuestionFrozen!;
        }
        if (source.listeningQuestionFrozen != null) {
          _listeningQuestionByIndex[i] = source.listeningQuestionFrozen!;
        }
      }
      if (i < snapshot.resultados.length) {
        _resultados[i] = snapshot.resultados[i];
      }
    }
  }

  PracticeSessionReviewSnapshot _buildReviewSnapshot() {
    for (var i = 0; i < _total; i++) {
      final item = _session.exercicios[i];
      switch (item.modalidade) {
        case PracticeExerciseModality.vocabMatch:
          _vocabularyQuestionForIndex(i);
          break;
        case PracticeExerciseModality.listeningComprehension:
          _listeningQuestionForIndex(i);
          break;
        default:
          break;
      }
    }
    final slots = <PracticeSessionReviewSlotSnapshot>[];
    for (var i = 0; i < _slots.length; i++) {
      final slot = _slots[i];
      slots.add(
        PracticeSessionReviewSlotSnapshot(
          vocabularyAssociations: slot.vocabularyAssociations == null
              ? null
              : List<int?>.from(slot.vocabularyAssociations!),
          vocabularyFeedback: slot.vocabularyFeedback == null
              ? null
              : VocabularyMatchEvaluation(
                  isFullyCorrect: slot.vocabularyFeedback!.isFullyCorrect,
                  perDefinitionCorrect: List<bool>.from(
                      slot.vocabularyFeedback!.perDefinitionCorrect),
                ),
          listeningSelected: slot.listeningSelected,
          listeningShowResult: slot.listeningShowResult,
          listeningSubmitted: slot.listeningSubmitted,
          fillDraft: slot.fillDraft,
          dialogueCommittedTranscript: slot.dialogueCommittedTranscript,
          dialogueTranscriptFeedback: slot.dialogueTranscriptFeedback,
          vocabularyQuestionFrozen: _vocabularyQuestionByIndex[i],
          listeningQuestionFrozen: _listeningQuestionByIndex[i],
        ),
      );
    }
    final resultados = _resultados.map((e) => e!).toList();
    return PracticeSessionReviewSnapshot(slots: slots, resultados: resultados);
  }

  void _syncFillControllerFromSlot() {
    if (_currentItem.modalidade == PracticeExerciseModality.fillBlanks) {
      _fillController.text = _slots[_currentIndex].fillDraft;
    }
  }

  void _persistFillDraftBeforeLeave(int index) {
    final item = _session.exercicios[index];
    if (item.modalidade == PracticeExerciseModality.fillBlanks) {
      _slots[index].fillDraft = _fillController.text;
    }
  }

  void _goToIndex(int nextIndex, {bool clearTransitionLock = false}) {
    if (nextIndex < 0 || nextIndex >= _total) return;
    _persistFillDraftBeforeLeave(_currentIndex);
    final leavingDialogue = _session.exercicios[_currentIndex].modalidade ==
        PracticeExerciseModality.dialogueCompletion;
    if (leavingDialogue) {
      unawaited(_dialogueSpeech.stop());
    }
    setState(() {
      if (leavingDialogue) {
        _slots[_currentIndex].dialogueListening = false;
      }
      _currentIndex = nextIndex;
      if (clearTransitionLock) {
        _isBetweenExercises = false;
      }
      _syncFillControllerFromSlot();
    });
  }

  Future<void> _configureTtsForListening(PracticeExerciseItem item) async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> _playListening(PracticeExerciseItem item) async {
    final script = item.text?.trim() ?? '';
    if (script.isEmpty) return;
    await _configureTtsForListening(item);
    setState(() => _listeningSpeaking = true);
    await _tts.stop();
    await _tts.speak(script);
  }

  bool _canSubmitCurrent() {
    final item = _currentItem;
    switch (item.modalidade) {
      case PracticeExerciseModality.vocabMatch:
        final assoc = _slots[_currentIndex].vocabularyAssociations;
        if (assoc == null) return false;
        return assoc.every((e) => e != null);
      case PracticeExerciseModality.listeningComprehension:
        return _slots[_currentIndex].listeningSelected != null;
      case PracticeExerciseModality.fillBlanks:
        return _fillController.text.trim().isNotEmpty;
      case PracticeExerciseModality.dialogueCompletion:
        return _slots[_currentIndex]
            .dialogueCommittedTranscript
            .trim()
            .isNotEmpty;
      default:
        return false;
    }
  }

  Future<void> _onAbandon() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Abandonar partida?',
              style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
          content: Text(
            'O progresso desta partida será perdido.',
            style: GoogleFonts.lexend(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Continuar',
                  style: GoogleFonts.lexend(color: AppColors.primaria)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Sair',
                  style: GoogleFonts.lexend(color: AppColors.erro)),
            ),
          ],
        );
      },
    );
    if (leave == true && mounted) {
      unawaited(_dialogueSpeech.stop());
      Navigator.of(context).pop();
    }
  }

  void _showInfoSheet(String title, String body) {
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
                title,
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textoAzul,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                body,
                style: GoogleFonts.lexend(
                    fontSize: 14, color: AppColors.textoPreto, height: 1.4),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onModalityInfoTap(String modality) {
    switch (modality) {
      case PracticeExerciseModality.vocabMatch:
        _showInfoSheet(
          'Vocabulary Match',
          'Toque em uma palavra e depois na definição correspondente para associar. '
              'Use Próximo para registrar a correção deste exercício e avançar.',
        );
        break;
      case PracticeExerciseModality.listeningComprehension:
        _showInfoSheet(
          'Listening Comprehension',
          'Toque no ícone para ouvir o texto. Em seguida escolha a alternativa correta e avance.',
        );
        break;
      case PracticeExerciseModality.fillBlanks:
        _showInfoSheet(
          'Fill in the Blanks',
          'Complete a lacuna usando o campo abaixo. A resposta é comparada ao gabarito recebido do backend.',
        );
        break;
      case PracticeExerciseModality.dialogueCompletion:
        _showInfoSheet(
          'Dialogue Completion',
          DialogueCompletionPracticeCopy.infoSheetInstructions,
        );
        break;
      default:
        _showInfoSheet('Exercício', 'Modalidade não suportada neste fluxo.');
    }
  }

  String _modalityLabel(String modality) {
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
        return modality;
    }
  }

  Future<void> _finishExerciseStep(PracticeFeedbackContent feedback) async {
    if (!mounted) return;
    setState(() => _isBetweenExercises = true);
    await PracticeFeedbackSheet.show(context, feedback);
    if (!mounted) return;
    if (_currentIndex >= _total - 1) {
      await _openSummary();
      return;
    }
    _goToIndex(_currentIndex + 1, clearTransitionLock: true);
  }

  void _onPrimarySubmit() {
    if (!_canSubmitCurrent() || _isBetweenExercises) return;

    final item = _currentItem;
    final slot = _slots[_currentIndex];

    switch (item.modalidade) {
      case PracticeExerciseModality.vocabMatch:
        final q = _vocabularyQuestionForIndex(_currentIndex);
        q.assertValid();
        final assoc = slot.vocabularyAssociations;
        if (assoc == null || !assoc.every((e) => e != null)) return;

        final evaluation = VocabularyMatchEvaluation.evaluate(
            question: q, associations: assoc);
        final ok = evaluation.isFullyCorrect;
        setState(() => slot.vocabularyFeedback = evaluation);
        _resultados[_currentIndex] = ExerciseResultEntry(
          palavrasChave: List<String>.from(item.palavrasChave),
          modalidade: item.modalidade,
          foiCorreto: ok,
        );
        final feedback =
            PracticeFeedbackContentBuilder.vocabularyMatch(isCorrect: ok);
        unawaited(_finishExerciseStep(feedback));
        return;

      case PracticeExerciseModality.listeningComprehension:
        final q = _listeningQuestionForIndex(_currentIndex);
        q.assertValid();
        final selected = slot.listeningSelected;
        final ok = ListeningComprehensionEvaluation.isCorrect(
          selectedOptionIndex: selected,
          correctOptionIndex: q.correctOptionIndex,
        );
        setState(() {
          slot.listeningShowResult = true;
          slot.listeningSubmitted = selected;
        });
        _resultados[_currentIndex] = ExerciseResultEntry(
          palavrasChave: List<String>.from(item.palavrasChave),
          modalidade: item.modalidade,
          foiCorreto: ok,
        );
        final feedback = PracticeFeedbackContentBuilder.listening(
          isCorrect: ok,
          question: q,
          selectedOptionIndex: selected,
        );
        unawaited(_finishExerciseStep(feedback));
        return;

      case PracticeExerciseModality.fillBlanks:
        slot.fillDraft = _fillController.text;
        final q = PracticeSessionExerciseAdapters.fillBlanksFromItem(item);
        q.assertValid();
        final ok = FillInTheBlanksEvaluation.matchesAnswer(
          userAnswer: slot.fillDraft,
          acceptedAnswers: q.acceptedAnswers,
        );
        _resultados[_currentIndex] = ExerciseResultEntry(
          palavrasChave: List<String>.from(item.palavrasChave),
          modalidade: item.modalidade,
          foiCorreto: ok,
        );
        setState(() {});
        final feedback = PracticeFeedbackContentBuilder.fillBlanks(
          isCorrect: ok,
          question: q,
          userAnswer: slot.fillDraft,
        );
        unawaited(_finishExerciseStep(feedback));
        return;

      case PracticeExerciseModality.dialogueCompletion:
        final q = _dialogueQuestionForIndex(_currentIndex);
        final spoken = slot.dialogueCommittedTranscript.trim();
        if (spoken.isEmpty) return;
        final ok = DialogueCompletionEvaluation.matchesTranscript(
          userTranscript: spoken,
          acceptedAnswers: q.acceptedAnswers,
        );
        setState(() => slot.dialogueTranscriptFeedback = ok);
        _resultados[_currentIndex] = ExerciseResultEntry(
          palavrasChave: List<String>.from(item.palavrasChave),
          modalidade: item.modalidade,
          foiCorreto: ok,
        );
        final feedback = PracticeFeedbackContentBuilder.dialogueCompletion(
          isCorrect: ok,
          question: q,
          userTranscript: spoken,
        );
        unawaited(_finishExerciseStep(feedback));
        return;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Modalidade não suportada: ${item.modalidade}',
              style: GoogleFonts.lexend(color: AppColors.branco),
            ),
            backgroundColor: AppColors.erro,
          ),
        );
    }
  }

  Future<void> _openSummary() async {
    for (var i = 0; i < _total; i++) {
      if (_resultados[i] != null) continue;
      final item = _session.exercicios[i];
      _resultados[i] = ExerciseResultEntry(
        palavrasChave: List<String>.from(item.palavrasChave),
        modalidade: item.modalidade,
        foiCorreto: false,
      );
    }
    final filled = _resultados.map((e) => e!).toList();
    final corretos = filled.where((e) => e.foiCorreto).length;
    final outcome = PracticeSessionOutcome(
      practiceSessionId: _session.practiceSessionId,
      resultados: filled,
      sugestoesPalavras: List<String>.from(_session.sugestoesPalavras),
      totalCorretos: corretos,
      totalExercicios: _total,
    );
    final reviewSnapshot = _buildReviewSnapshot();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            content: Row(
              children: [
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.primaria,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    'Enviando seu desempenho para a nuvem…',
                    style: GoogleFonts.lexend(
                      fontSize: 15,
                      height: 1.35,
                      color: AppColors.textoPreto,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      await context.read<VocabPracticeService>().submeterResultados(outcome);
    } catch (e) {
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Envio do resultado',
                  style: GoogleFonts.lexend(fontWeight: FontWeight.bold)),
              content: Text(
                'Não foi possível registrar o resultado no servidor.\n\n$e',
                style: GoogleFonts.lexend(height: 1.35),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK',
                      style: GoogleFonts.lexend(color: AppColors.primaria)),
                ),
              ],
            );
          },
        );
      }
    } finally {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    if (!mounted) return;
    final sessionForReplay = _session;
    final titleForReplay = widget.practiceTitle;
    final themeIdForReplay = widget.themeId;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => PracticeSessionSummaryScreen(
          outcome: outcome,
          lessonTitle: titleForReplay,
          onLeavePractice: () => Navigator.of(context).pop(),
          onReviewQuestionTap: (exerciseIndex) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => PracticeSessionScreen(
                  session: sessionForReplay,
                  practiceTitle: titleForReplay,
                  themeId: themeIdForReplay,
                  reviewSnapshot: reviewSnapshot,
                  initialExerciseIndex: exerciseIndex,
                ),
              ),
            );
          },
          onStartNewMatch: () {
            if (themeIdForReplay != null) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (context) => PracticeSessionLoadingScreen(
                    themeId: themeIdForReplay,
                    practiceTitle: titleForReplay,
                  ),
                ),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (context) => PracticeSessionScreen(
                    session: sessionForReplay,
                    practiceTitle: titleForReplay,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Color _fillBorderColor(PracticeExerciseItem item) {
    if (item.modalidade != PracticeExerciseModality.fillBlanks) {
      return AppColors.bordaCampo;
    }
    final recorded = _resultados[_currentIndex];
    if (recorded == null) return AppColors.bordaCampo;
    return recorded.foiCorreto ? AppColors.acerto : AppColors.erro;
  }

  List<PracticeAudioTranscriptionEntry> _audioTranscriptionsForItem(
      PracticeExerciseItem item) {
    switch (item.modalidade) {
      case PracticeExerciseModality.listeningComprehension:
        final q = _listeningQuestionForIndex(_currentIndex);
        return PracticeAudioTranscriptionBuilder.forListening(q);
      case PracticeExerciseModality.dialogueCompletion:
        final q = _dialogueQuestionForIndex(_currentIndex);
        return PracticeAudioTranscriptionBuilder.forDialogue(q);
      default:
        return const [];
    }
  }

  Widget _buildFooterBeforeSubmit(PracticeExerciseItem item) {
    final base = Text(
      _isReviewMode
          ? 'Revisão do exercício ${_currentIndex + 1} de $_total'
          : 'Exercício ${_currentIndex + 1} de $_total',
      textAlign: TextAlign.center,
      style: GoogleFonts.lexend(
        fontSize: 14,
        color: AppColors.textoSuave,
        fontWeight: FontWeight.w600,
      ),
    );
    if (!_isReviewMode) return base;
    final transcriptions = _audioTranscriptionsForItem(item);
    if (transcriptions.isEmpty) return base;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        base,
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () {
              PracticeAudioTranscriptionSheet.show(
                context,
                entries: transcriptions,
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
    );
  }

  Widget _buildMiolo(PracticeExerciseItem item) {
    final readOnlyReview = _isReviewMode;
    switch (item.modalidade) {
      case PracticeExerciseModality.vocabMatch:
        final q = _vocabularyQuestionForIndex(_currentIndex);
        final slot = _slots[_currentIndex];
        slot.vocabularyAssociations ??=
            List<int?>.filled(q.definitions.length, null);
        return VocabularyMatchPracticeBody(
          question: q,
          selectedWordIndex: slot.vocabularySelectedWord,
          associations: slot.vocabularyAssociations!,
          isInteractionEnabled: !readOnlyReview,
          onWordTap: (i) {
            if (readOnlyReview) return;
            setState(() {
              slot.vocabularyFeedback = null;
              slot.vocabularySelectedWord =
                  slot.vocabularySelectedWord == i ? null : i;
            });
          },
          onDefinitionTap: (definitionIndex) {
            if (readOnlyReview) return;
            final selected = slot.vocabularySelectedWord;
            if (selected == null) return;
            setState(() {
              slot.vocabularyFeedback = null;
              for (var i = 0; i < slot.vocabularyAssociations!.length; i++) {
                if (slot.vocabularyAssociations![i] == selected) {
                  slot.vocabularyAssociations![i] = null;
                }
              }
              slot.vocabularyAssociations![definitionIndex] = selected;
              slot.vocabularySelectedWord = null;
            });
          },
          feedback: slot.vocabularyFeedback,
        );

      case PracticeExerciseModality.listeningComprehension:
        final q = _listeningQuestionForIndex(_currentIndex);
        final slot = _slots[_currentIndex];
        return ListeningComprehensionPracticeBody(
          onPlayListening: () => _playListening(item),
          isPlayingListening: _listeningSpeaking,
          questionText: q.questionText,
          options: q.options,
          selectedOptionIndex: slot.listeningSelected,
          isInteractionEnabled: !readOnlyReview,
          onOptionSelected: (i) {
            if (readOnlyReview) return;
            setState(() {
              if (slot.listeningShowResult) {
                slot.listeningShowResult = false;
                slot.listeningSubmitted = null;
              }
              slot.listeningSelected = slot.listeningSelected == i ? null : i;
            });
          },
          showResult: slot.listeningShowResult,
          correctOptionIndex: q.correctOptionIndex,
          submittedOptionIndex: slot.listeningSubmitted,
        );

      case PracticeExerciseModality.fillBlanks:
        final q = PracticeSessionExerciseAdapters.fillBlanksFromItem(item);
        return FillInTheBlanksPracticeBody(
          textBeforeBlank: q.textBeforeBlank,
          textAfterBlank: q.textAfterBlank,
          answerController: _fillController,
          placeholder: q.placeholder,
          onAnswerChanged: () {
            setState(() {});
          },
          fieldBorderColor: _fillBorderColor(item),
          readOnly: readOnlyReview,
        );

      case PracticeExerciseModality.dialogueCompletion:
        try {
          final q = _dialogueQuestionForIndex(_currentIndex);
          final slot = _slots[_currentIndex];
          return DialogueCompletionPracticeBody(
            promptLine: q.promptLine,
            lineCount: q.obscuredLineAudios.length,
            onPlayLine: _playDialogueLine,
            userTranscript: _dialogueDisplayTranscript(slot),
            isListening: slot.dialogueListening,
            onMicPointerDown: () => _dialogueMicDown(),
            onMicPointerUpOrCancel: () => _dialogueMicUp(),
            transcriptFeedbackCorrect: slot.dialogueTranscriptFeedback,
            onSkip: readOnlyReview ? null : _skipDialogueExercise,
            microphoneEnabled: !readOnlyReview,
          );
        } on StateError catch (e) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Não foi possível montar este exercício.\n\n$e',
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                    fontSize: 14, color: AppColors.erro, height: 1.35),
              ),
            ),
          );
        }

      default:
        return Center(
          child: Text(
            'Modalidade não suportada neste fluxo: ${item.modalidade}',
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(fontSize: 15, color: AppColors.erro),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _currentItem;
    final isLast = _currentIndex >= _total - 1;
    final submitLabel =
        _isReviewMode ? 'Voltar' : (isLast ? 'Finalizar prática' : 'Próximo');
    final canSubmit =
        _isReviewMode ? true : (_canSubmitCurrent() && !_isBetweenExercises);
    final statusLabel =
        _isReviewMode ? 'Revisão da partida' : 'Prática em andamento';

    return ExercisePracticeShell(
      statusLabel: statusLabel,
      practiceTitle: widget.practiceTitle,
      currentStepIndex: _currentIndex,
      totalSteps: _total,
      modalityLabel: _modalityLabel(item.modalidade),
      onModalityInfoTap: () => _onModalityInfoTap(item.modalidade),
      miolo: _buildMiolo(item),
      canSubmit: canSubmit,
      onSubmit:
          _isReviewMode ? () => Navigator.of(context).pop() : _onPrimarySubmit,
      onAbandonPractice:
          _isReviewMode ? () => Navigator.of(context).pop() : _onAbandon,
      submitLabel: submitLabel,
      showAbandonAction: !_isReviewMode,
      footerBeforeSubmit: _buildFooterBeforeSubmit(item),
    );
  }
}
