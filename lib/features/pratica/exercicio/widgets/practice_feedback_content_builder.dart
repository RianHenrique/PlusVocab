import 'package:plus_vocab/features/pratica/exercicio/models/dialogue_completion_models.dart';
import 'package:plus_vocab/features/pratica/exercicio/models/fill_in_the_blanks_models.dart';
import 'package:plus_vocab/features/pratica/exercicio/models/listening_comprehension_models.dart';
import 'package:plus_vocab/features/pratica/exercicio/widgets/practice_audio_transcription_builder.dart';
import 'package:plus_vocab/features/pratica/exercicio/widgets/practice_feedback_models.dart';

abstract final class PracticeFeedbackContentBuilder {
  PracticeFeedbackContentBuilder._();

  static PracticeFeedbackContent vocabularyMatch({required bool isCorrect}) {
    return PracticeFeedbackContent(
      isCorrect: isCorrect,
      hideAnswerDetails: true,
    );
  }

  static PracticeFeedbackContent listening({
    required bool isCorrect,
    required ListeningComprehensionQuestion question,
    int? selectedOptionIndex,
  }) {
    final correct = question.options[question.correctOptionIndex].trim();
    final transcriptions = PracticeAudioTranscriptionBuilder.forListening(question);
    if (isCorrect) {
      return PracticeFeedbackContent(
        isCorrect: true,
        correctAnswerText: correct.isEmpty ? '—' : correct,
        audioTranscriptions: transcriptions,
      );
    }
    final user = selectedOptionIndex != null &&
            selectedOptionIndex >= 0 &&
            selectedOptionIndex < question.options.length
        ? question.options[selectedOptionIndex].trim()
        : '—';
    return PracticeFeedbackContent(
      isCorrect: false,
      userAnswerText: user.isEmpty ? '—' : user,
      correctAnswerText: correct.isEmpty ? '—' : correct,
      audioTranscriptions: transcriptions,
    );
  }

  static PracticeFeedbackContent fillBlanks({
    required bool isCorrect,
    required FillInTheBlanksQuestion question,
    required String userAnswer,
  }) {
    final accepted = question.acceptedAnswers
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final correctStr = accepted.isEmpty ? '—' : accepted.join(' · ');
    if (isCorrect) {
      return PracticeFeedbackContent(
        isCorrect: true,
        correctAnswerText: correctStr,
      );
    }
    final u = userAnswer.trim();
    return PracticeFeedbackContent(
      isCorrect: false,
      userAnswerText: u.isEmpty ? '—' : u,
      correctAnswerText: correctStr,
    );
  }

  static PracticeFeedbackContent dialogueCompletion({
    required bool isCorrect,
    required DialogueCompletionQuestion question,
    required String userTranscript,
  }) {
    final accepted = question.acceptedAnswers
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    String correctStr;
    if (accepted.isEmpty) {
      correctStr = '—';
    } else if (accepted.length <= 4) {
      correctStr = accepted.join('\n');
    } else {
      correctStr = '${accepted.take(4).join('\n')}\n…';
    }
    final transcriptions = PracticeAudioTranscriptionBuilder.forDialogue(question);
    if (isCorrect) {
      return PracticeFeedbackContent(
        isCorrect: true,
        correctAnswerText: correctStr,
        audioTranscriptions: transcriptions,
      );
    }
    final u = userTranscript.trim();
    return PracticeFeedbackContent(
      isCorrect: false,
      userAnswerText: u.isEmpty || u == '-' ? '—' : u,
      correctAnswerText: correctStr,
      audioTranscriptions: transcriptions,
    );
  }
}
