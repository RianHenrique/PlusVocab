import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/pratica/exercicio/layout/exercise_practice_shell.dart';
import 'package:plus_vocab/features/pratica/exercicio/logic/practice_session_exercise_adapters.dart';
import 'package:plus_vocab/features/pratica/exercicio/modalidades/fill_in_the_blanks_practice_body.dart';
import 'package:plus_vocab/features/pratica/exercicio/modalidades/listening_comprehension_practice_body.dart';
import 'package:plus_vocab/features/pratica/exercicio/modalidades/vocabulary_match_practice_body.dart';
import 'package:plus_vocab/features/pratica/exercicio/models/fill_in_the_blanks_models.dart';
import 'package:plus_vocab/features/pratica/exercicio/models/listening_comprehension_models.dart';
import 'package:plus_vocab/features/pratica/exercicio/models/practice_session_models.dart';
import 'package:plus_vocab/features/pratica/exercicio/models/vocabulary_match_models.dart';
import 'package:plus_vocab/features/pratica/exercicio/views/practice_session_summary_screen.dart';

// TODO(RF-21): ao integrar o backend, receber [PracticeSessionPayload] da API ao iniciar a prática
// e, ao finalizar, enviar [PracticeSessionOutcome.toRequestBody()] no endpoint de resultado.

class _ExerciseSlotState {
  List<int?>? vocabularyAssociations;
  int? vocabularySelectedWord;
  VocabularyMatchEvaluation? vocabularyFeedback;

  int? listeningSelected;
  bool listeningShowResult = false;
  int? listeningSubmitted;

  String fillDraft = '';
}

/// Orquestra a lista de exercícios da sessão: respostas em memória, correção local e fluxo até o resumo.
class PracticeSessionScreen extends StatefulWidget {
  const PracticeSessionScreen({
    super.key,
    required this.session,
    this.practiceTitle = 'Prática PlusVocab',
  });

  final PracticeSessionPayload session;
  final String practiceTitle;

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

  PracticeSessionPayload get _session => widget.session;

  int get _total => _session.exercicios.length;

  PracticeExerciseItem get _currentItem => _session.exercicios[_currentIndex];

  VocabularyMatchQuestion _vocabularyQuestionForIndex(int index) {
    return _vocabularyQuestionByIndex.putIfAbsent(
      index,
      () => PracticeSessionExerciseAdapters.vocabularyMatchFromItem(_session.exercicios[index]),
    );
  }

  ListeningComprehensionQuestion _listeningQuestionForIndex(int index) {
    return _listeningQuestionByIndex.putIfAbsent(
      index,
      () => PracticeSessionExerciseAdapters.listeningFromItem(_session.exercicios[index]),
    );
  }

  @override
  void initState() {
    super.initState();
    _slots = List<_ExerciseSlotState>.generate(_total, (_) => _ExerciseSlotState());
    _resultados = List<ExerciseResultEntry?>.filled(_total, null);
    _fillController = TextEditingController();
    _tts = FlutterTts();
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _listeningSpeaking = false);
    });
    _syncFillControllerFromSlot();
  }

  @override
  void dispose() {
    _fillController.dispose();
    _tts.stop();
    super.dispose();
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
    setState(() {
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
      default:
        return false;
    }
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
    if (leave == true && mounted) Navigator.of(context).pop();
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
                style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textoPreto, height: 1.4),
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

  String _vocabIncorrectDetail(VocabularyMatchQuestion question, List<int?> associations) {
    final correctWords = List<String>.generate(
      question.definitions.length,
      (i) => question.words[question.answerKey[i]],
    );
    final userWords = associations
        .map((idx) => idx == null ? '?' : question.words[idx])
        .toList();
    return 'Resposta certa: ${correctWords.map((w) => '"$w"').join(' / ')}\n'
        'Sua resposta: ${userWords.map((w) => '"$w"').join(' / ')}';
  }

  String _listeningIncorrectDetail(
    List<String> options,
    int correctOptionIndex,
    int? selectedOptionIndex,
  ) {
    final cor = options[correctOptionIndex];
    final usr = selectedOptionIndex != null &&
            selectedOptionIndex >= 0 &&
            selectedOptionIndex < options.length
        ? options[selectedOptionIndex]
        : '(nenhuma alternativa selecionada)';
    return 'Resposta certa: "$cor"\nSua resposta: "$usr"';
  }

  String _fillIncorrectDetail(FillInTheBlanksQuestion question, String userAnswer) {
    final accepted = question.acceptedAnswers
        .map((a) => '"${a.trim()}"')
        .join(' ou ');
    return 'Resposta certa: $accepted\nSua resposta: "${userAnswer.trim()}"';
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

        final evaluation = VocabularyMatchEvaluation.evaluate(question: q, associations: assoc);
        final ok = evaluation.isFullyCorrect;
        setState(() => slot.vocabularyFeedback = evaluation);
        _resultados[_currentIndex] = ExerciseResultEntry(
          palavrasChave: List<String>.from(item.palavrasChave),
          modalidade: item.modalidade,
          foiCorreto: ok,
        );
        final detail = ok ? null : _vocabIncorrectDetail(q, assoc);
        _snack(ok, incorrectDetail: detail);
        _afterRecorded(ok, longIncorrectMessage: detail != null);
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
        final detail = ok ? null : _listeningIncorrectDetail(q.options, q.correctOptionIndex, selected);
        _snack(ok, incorrectDetail: detail);
        _afterRecorded(ok, longIncorrectMessage: detail != null);
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
        final detail = ok ? null : _fillIncorrectDetail(q, slot.fillDraft);
        _snack(ok, incorrectDetail: detail);
        _afterRecorded(ok, longIncorrectMessage: detail != null);
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

  void _snack(bool ok, {String? incorrectDetail}) {
    if (!mounted) return;
    final hasDetail = incorrectDetail != null && incorrectDetail.trim().isNotEmpty;
    final snackMs = ok ? 1500 : (hasDetail ? 5200 : 2000);
    final message = ok
        ? 'Resposta correta!'
        : (hasDetail
            ? 'Resposta incorreta.\n$incorrectDetail'
            : 'Resposta incorreta.');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(milliseconds: snackMs),
        content: Text(
          message,
          style: GoogleFonts.lexend(color: AppColors.branco, height: 1.35),
        ),
        backgroundColor: ok ? AppColors.acerto : AppColors.erro,
      ),
    );
  }

  void _afterRecorded(bool ok, {bool longIncorrectMessage = false}) {
    setState(() => _isBetweenExercises = true);
    final delayMs = ok ? 1500 : (longIncorrectMessage ? 5600 : 2000);
    Future<void>.delayed(Duration(milliseconds: delayMs), () async {
      if (!mounted) return;
      if (_currentIndex >= _total - 1) {
        await _openSummary();
        return;
      }
      _goToIndex(_currentIndex + 1, clearTransitionLock: true);
    });
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

    // TODO(RF-21): enviar respostas ao backend antes de exibir o resumo.
    // final client = ApiClient();
    // await client.post(
    //   '/practice/sessions/${outcome.practiceSessionId}/answers',
    //   data: outcome.toRequestBody(),
    // );

    if (!mounted) return;
    final sessionForReplay = _session;
    final titleForReplay = widget.practiceTitle;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => PracticeSessionSummaryScreen(
          outcome: outcome,
          lessonTitle: titleForReplay,
          onLeavePractice: () => Navigator.of(context).pop(),
          onStartNewMatch: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (context) => PracticeSessionScreen(
                  session: sessionForReplay,
                  practiceTitle: titleForReplay,
                ),
              ),
            );
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

  Widget _buildMiolo(PracticeExerciseItem item) {
    switch (item.modalidade) {
      case PracticeExerciseModality.vocabMatch:
        final q = _vocabularyQuestionForIndex(_currentIndex);
        final slot = _slots[_currentIndex];
        slot.vocabularyAssociations ??= List<int?>.filled(q.definitions.length, null);
        return VocabularyMatchPracticeBody(
          question: q,
          selectedWordIndex: slot.vocabularySelectedWord,
          associations: slot.vocabularyAssociations!,
          onWordTap: (i) {
            setState(() {
              slot.vocabularyFeedback = null;
              slot.vocabularySelectedWord = slot.vocabularySelectedWord == i ? null : i;
            });
          },
          onDefinitionTap: (definitionIndex) {
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
          onOptionSelected: (i) {
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
        );

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
    final submitLabel = isLast ? 'Finalizar prática' : 'Próximo';

    return ExercisePracticeShell(
      practiceTitle: widget.practiceTitle,
      currentStepIndex: _currentIndex,
      totalSteps: _total,
      modalityLabel: _modalityLabel(item.modalidade),
      onModalityInfoTap: () => _onModalityInfoTap(item.modalidade),
      miolo: _buildMiolo(item),
      canSubmit: _canSubmitCurrent() && !_isBetweenExercises,
      onSubmit: _onPrimarySubmit,
      onAbandonPractice: _onAbandon,
      submitLabel: submitLabel,
      footerBeforeSubmit: Text(
        'Exercício ${_currentIndex + 1} de $_total',
        textAlign: TextAlign.center,
        style: GoogleFonts.lexend(
          fontSize: 14,
          color: AppColors.textoSuave,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
