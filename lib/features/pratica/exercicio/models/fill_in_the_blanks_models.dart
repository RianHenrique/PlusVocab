/// Lacuna no meio da frase: [textBeforeBlank] + resposta do aluno + [textAfterBlank].
class FillInTheBlanksQuestion {
  const FillInTheBlanksQuestion({
    required this.textBeforeBlank,
    required this.textAfterBlank,
    required this.acceptedAnswers,
    this.placeholder = 'Escreva aqui sua resposta',
  });

  final String textBeforeBlank;
  final String textAfterBlank;
  final List<String> acceptedAnswers;
  final String placeholder;

  void assertValid() {
    assert(textBeforeBlank.isNotEmpty || textAfterBlank.isNotEmpty, 'A frase não pode ser vazia');
    assert(acceptedAnswers.isNotEmpty, 'acceptedAnswers não pode ser vazio');
  }

  factory FillInTheBlanksQuestion.sampleRestaurant() {
    return const FillInTheBlanksQuestion(
      textBeforeBlank: 'The ',
      textAfterBlank: 'brought me my coffee.',
      acceptedAnswers: ['waiter', 'waitress', 'server'],
    );
  }
}

abstract final class FillInTheBlanksEvaluation {
  FillInTheBlanksEvaluation._();

  static String normalize(String input) {
    var s = input.toLowerCase().trim();
    s = s.replaceAll(RegExp(r"[^a-z0-9'\s]"), ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }

  static bool matchesAnswer({
    required String userAnswer,
    required List<String> acceptedAnswers,
  }) {
    final u = normalize(userAnswer);
    if (u.isEmpty) return false;
    for (final raw in acceptedAnswers) {
      final a = normalize(raw);
      if (a.isEmpty) continue;
      if (u == a || u.contains(a) || a.contains(u)) {
        return true;
      }
    }
    return false;
  }
}
