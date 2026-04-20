/// Dados de uma questão Vocabulary Match vindos do backend.
class VocabularyMatchQuestion {
  const VocabularyMatchQuestion({
    required this.words,
    required this.definitions,
    required this.answerKey,
  });

  /// Rótulos exibidos nos chips (ordem exibida = ordem desta lista).
  final List<String> words;

  /// Definições exibidas nos cards (cada índice alinha com [answerKey]).
  final List<String> definitions;

  /// Gabarito: para cada índice de definição, o índice da palavra correta em [words].
  final List<int> answerKey;

  void assertValid() {
    assert(words.isNotEmpty, 'words não pode ser vazio');
    assert(definitions.length == answerKey.length, 'definitions e answerKey devem ter o mesmo tamanho');
    for (final w in answerKey) {
      assert(w >= 0 && w < words.length, 'answerKey contém índice de palavra inválido');
    }
  }

  /// Conteúdo de exemplo alinhado ao layout da modalidade (substituir por payload da API).
  factory VocabularyMatchQuestion.sampleRestaurant() {
    return const VocabularyMatchQuestion(
      words: ['Waitress', 'Dessert', 'Tea'],
      definitions: [
        'A woman who serves food and drinks to customers in a restaurant or cafe',
        'A hot or cold beverage made by infusing the dried leaves of the Camellia sinensis plant in boiling water',
        'Sweet food eaten at the end of a meal',
      ],
      answerKey: [0, 2, 1],
    );
  }
}

/// Resposta do usuário: para cada slot de definição, qual índice de [words] foi associado (ou null).
typedef VocabularyMatchUserAssociations = List<int?>;

class VocabularyMatchEvaluation {
  const VocabularyMatchEvaluation({
    required this.isFullyCorrect,
    required this.perDefinitionCorrect,
  });

  final bool isFullyCorrect;

  /// Mesmo comprimento que definições; indica se a associação naquele slot está correta.
  final List<bool> perDefinitionCorrect;

  static VocabularyMatchEvaluation evaluate({
    required VocabularyMatchQuestion question,
    required VocabularyMatchUserAssociations associations,
  }) {
    question.assertValid();
    final n = question.definitions.length;
    if (associations.length != n) {
      return VocabularyMatchEvaluation(
        isFullyCorrect: false,
        perDefinitionCorrect: List<bool>.filled(n, false),
      );
    }

    final per = <bool>[];
    var allOk = true;
    for (var i = 0; i < n; i++) {
      final chosen = associations[i];
      final expected = question.answerKey[i];
      final ok = chosen != null && chosen == expected;
      per.add(ok);
      if (!ok) allOk = false;
    }
    return VocabularyMatchEvaluation(isFullyCorrect: allOk, perDefinitionCorrect: per);
  }
}
