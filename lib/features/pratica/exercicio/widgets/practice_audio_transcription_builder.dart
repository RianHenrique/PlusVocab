import 'package:plus_vocab/features/pratica/exercicio/models/dialogue_completion_models.dart';
import 'package:plus_vocab/features/pratica/exercicio/models/listening_comprehension_models.dart';
import 'package:plus_vocab/features/pratica/exercicio/widgets/practice_feedback_models.dart';

abstract final class PracticeAudioTranscriptionBuilder {
  PracticeAudioTranscriptionBuilder._();

  static List<PracticeAudioTranscriptionEntry> forListening(
    ListeningComprehensionQuestion question,
  ) {
    final out = <PracticeAudioTranscriptionEntry>[
      PracticeAudioTranscriptionEntry(
        label: 'Áudio da questão',
        text: question.listeningScript.trim(),
      ),
    ];
    for (var i = 0; i < question.options.length; i++) {
      final t = question.options[i].trim();
      if (t.isEmpty) continue;
      out.add(
        PracticeAudioTranscriptionEntry(
          label: 'Áudio da opção ${i + 1}',
          text: t,
        ),
      );
    }
    return out.where((e) => e.text.trim().isNotEmpty).toList();
  }

  static List<PracticeAudioTranscriptionEntry> forDialogue(
    DialogueCompletionQuestion question,
  ) {
    final out = <PracticeAudioTranscriptionEntry>[];
    final prompt = question.promptLine.trim();
    if (prompt.isNotEmpty) {
      final duplicateOfLine = question.obscuredLineAudios.any((a) => a.trim() == prompt);
      if (!duplicateOfLine) {
        out.add(
          PracticeAudioTranscriptionEntry(
            label: 'Áudio da questão',
            text: prompt,
          ),
        );
      }
    }
    for (var i = 0; i < question.obscuredLineAudios.length; i++) {
      final t = question.obscuredLineAudios[i].trim();
      if (t.isEmpty) continue;
      out.add(
        PracticeAudioTranscriptionEntry(
          label: 'Áudio da opção ${i + 1}',
          text: t,
        ),
      );
    }
    return out.where((e) => e.text.trim().isNotEmpty).toList();
  }
}
