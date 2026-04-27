/// Rótulo e texto exibidos na folha de transcrições (áudio / trecho falado).
class PracticeAudioTranscriptionEntry {
  const PracticeAudioTranscriptionEntry({
    required this.label,
    required this.text,
  });

  final String label;
  final String text;
}

/// Conteúdo do painel de certo/errado após enviar uma resposta na prática.
class PracticeFeedbackContent {
  const PracticeFeedbackContent({
    required this.isCorrect,
    this.correctAnswerText = '',
    this.userAnswerText,
    this.audioTranscriptions = const [],
    this.hideAnswerDetails = false,
  });

  final bool isCorrect;

  /// Texto da resposta do aluno (erro). Ignorado se [isCorrect] ou [hideAnswerDetails].
  final String? userAnswerText;

  /// Gabarito na área “Resposta correta”. Ignorado se [hideAnswerDetails].
  final String correctAnswerText;

  /// Se não vazio, exibe o link “Ver transcrição do áudio”.
  final List<PracticeAudioTranscriptionEntry> audioTranscriptions;

  /// Ex.: vocabulary match: só título + Continuar; o gabarito fica só no destaque das definições.
  final bool hideAnswerDetails;
}
