/// Questão de Listening Comprehension: áudio (texto para TTS), pergunta e alternativas.
class ListeningComprehensionQuestion {
  const ListeningComprehensionQuestion({
    required this.listeningScript,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    this.ttsLanguage = 'en-US',
  });

  /// Texto lido pelo TTS ao tocar no botão de escuta (trecho ou diálogo).
  final String listeningScript;

  final String questionText;
  final List<String> options;

  /// Gabarito: índice da alternativa correta em [options].
  final int correctOptionIndex;

  final String ttsLanguage;

  void assertValid() {
    assert(listeningScript.isNotEmpty, 'listeningScript não pode ser vazio');
    assert(questionText.isNotEmpty, 'questionText não pode ser vazio');
    assert(options.length >= 2, 'options precisa de pelo menos 2 itens');
    assert(
      correctOptionIndex >= 0 && correctOptionIndex < options.length,
      'correctOptionIndex fora do intervalo',
    );
  }

  factory ListeningComprehensionQuestion.sampleRestaurant() {
    return const ListeningComprehensionQuestion(
      listeningScript:
          'Customer: Hi, could I get a large green tea, please? '
          'Waiter: Of course. Anything else? Customer: No, that will be all, thanks.',
      questionText: 'What did the customer order?',
      options: ['Coffee', 'Tea', 'Water'],
      correctOptionIndex: 1,
      ttsLanguage: 'en-US',
    );
  }
}

abstract final class ListeningComprehensionEvaluation {
  ListeningComprehensionEvaluation._();

  static bool isCorrect({
    required int? selectedOptionIndex,
    required int correctOptionIndex,
  }) {
    return selectedOptionIndex != null && selectedOptionIndex == correctOptionIndex;
  }
}
