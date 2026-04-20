/// Textos da UI desta modalidade (instruções, etc.).
abstract final class DialogueCompletionPracticeCopy {
  DialogueCompletionPracticeCopy._();

  /// Texto exibido no sheet de informações da tela de prática.
  static const String infoSheetInstructions =
      'Toque no ícone de som para ouvir cada opção de resposta do diálogo na tela. '
      'Escute com atenção e repita no microfone em inglês a opção que considerar mais correta. '
      'Segure o microfone para gravar e envie para correção.';
}

/// Escolhe um [localeId] instalado no dispositivo compatível com o idioma do exercício.
abstract final class DialogueCompletionSpeechLocales {
  DialogueCompletionSpeechLocales._();

  /// [preferredBcp47] no formato BCP-47 (ex.: en-US). Se nada casar, devolve o equivalente com underscore.
  static String pickInstalledOrFallback(Iterable<String> installedLocaleIds, String preferredBcp47) {
    String normalize(String s) => s.toLowerCase().replaceAll('-', '_');
    final ids = installedLocaleIds.toList();
    final want = normalize(preferredBcp47);

    for (final id in ids) {
      if (normalize(id) == want) return id;
    }

    final lang = want.contains('_') ? want.split('_').first : want;
    for (final id in ids) {
      if (normalize(id).startsWith('${lang}_')) return id;
    }

    return preferredBcp47.replaceAll('-', '_');
  }
}

/// Dados de um exercício Dialogue Completion (prompt, falas em áudio e gabarito textual).
class DialogueCompletionQuestion {
  const DialogueCompletionQuestion({
    required this.promptLine,
    required this.obscuredLineAudios,
    required this.acceptedAnswers,
    this.ttsLanguage = 'en-US',
  });

  /// Frase em destaque (ex.: fala do garçom).
  final String promptLine;

  /// Texto falado pelo TTS ao tocar no alto-falante de cada linha (conteúdo “oculto” atrás dos pontos).
  final List<String> obscuredLineAudios;

  /// Respostas aceitas após normalização (vindas do backend).
  final List<String> acceptedAnswers;

  /// Idioma do TTS / reconhecimento (ex.: en-US, pt-BR).
  final String ttsLanguage;

  void assertValid() {
    assert(promptLine.isNotEmpty, 'promptLine não pode ser vazio');
    assert(obscuredLineAudios.isNotEmpty, 'obscuredLineAudios não pode ser vazio');
    assert(acceptedAnswers.isNotEmpty, 'acceptedAnswers não pode ser vazio');
  }

  factory DialogueCompletionQuestion.sampleRestaurant() {
    return const DialogueCompletionQuestion(
      promptLine: 'Can I take your order?',
      obscuredLineAudios: [
        "I'll have the soup of the day, please.",
        'Could we get some bread for the table?',
        "We're still deciding, one more minute please.",
      ],
      acceptedAnswers: [
        "i'd like the grilled salmon please",
        'i would like the grilled salmon please',
        "i'll have the grilled salmon",
        'grilled salmon please',
        'i want the grilled salmon',
      ],
      ttsLanguage: 'en-US',
    );
  }
}

abstract final class DialogueCompletionEvaluation {
  DialogueCompletionEvaluation._();

  static String normalize(String input) {
    var s = input.toLowerCase().trim();
    s = s.replaceAll(RegExp(r"[^a-z0-9'\s]"), ' ');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }

  /// Retorna true se a transcrição bate com alguma entrada do gabarito após normalização.
  static bool matchesTranscript({
    required String userTranscript,
    required List<String> acceptedAnswers,
  }) {
    final u = normalize(userTranscript);
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
