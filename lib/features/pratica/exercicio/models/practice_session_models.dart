/// Contratos alinhados ao payload de prática enviado pelo backend.
class PracticeSessionPayload {
  const PracticeSessionPayload({
    required this.practiceSessionId,
    required this.exercicios,
    required this.sugestoesPalavras,
  });

  final String practiceSessionId;
  final List<PracticeExerciseItem> exercicios;
  final List<String> sugestoesPalavras;

  int get totalExercicios => exercicios.length;

  /// Aceita o JSON raiz da sessão ou um envelope `{ "success": true, "data": { ... } }`.
  factory PracticeSessionPayload.fromApi(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('Resposta de prática inválida.');
    }
    Map<String, dynamic> root = raw;
    final data = raw['data'];
    if (data is Map<String, dynamic> &&
        (data['practiceSessionId'] != null || data['exercicios'] != null)) {
      root = data;
    }
    final id = root['practiceSessionId']?.toString() ?? '';
    if (id.isEmpty) {
      throw const FormatException('Sessão de prática sem practiceSessionId.');
    }
    final exRaw = root['exercicios'];
    final exercicios = exRaw is List
        ? exRaw
            .whereType<Map<String, dynamic>>()
            .map(PracticeExerciseItem.fromJson)
            .toList()
        : <PracticeExerciseItem>[];
    final sugRaw = root['sugestoes_palavras'];
    final sugestoes =
        sugRaw is List ? sugRaw.map((e) => e.toString()).toList() : <String>[];
    return PracticeSessionPayload(
      practiceSessionId: id,
      exercicios: exercicios,
      sugestoesPalavras: sugestoes,
    );
  }
}

class PracticeExerciseItem {
  const PracticeExerciseItem({
    required this.numero,
    required this.modalidade,
    required this.questao,
    required this.gabarito,
    required this.text,
    required this.options,
    required this.palavrasChave,
  });

  final int numero;
  final String modalidade;
  final String? questao;
  final String? gabarito;
  final String? text;
  final Object? options;
  final List<String> palavrasChave;

  factory PracticeExerciseItem.fromJson(Map<String, dynamic> json) {
    final palavrasRaw = json['palavras_chave'];
    final palavrasChave = palavrasRaw is List
        ? palavrasRaw.map((e) => e.toString()).toList()
        : <String>[];

    return PracticeExerciseItem(
      numero: (json['numero'] as num?)?.toInt() ?? 0,
      modalidade: json['modalidade']?.toString() ?? '',
      questao: json['questao']?.toString(),
      gabarito: json['gabarito']?.toString(),
      text: json['text']?.toString(),
      options: json['options'],
      palavrasChave: palavrasChave,
    );
  }
}

class ExerciseResultEntry {
  const ExerciseResultEntry({
    required this.palavrasChave,
    required this.modalidade,
    required this.foiCorreto,
  });

  final List<String> palavrasChave;
  final String modalidade;
  final bool foiCorreto;

  Map<String, dynamic> toJson() => {
        'palavras_chave': palavrasChave,
        'modalidade': modalidade,
        'foiCorreto': foiCorreto,
      };
}

class PracticeSessionOutcome {
  const PracticeSessionOutcome({
    required this.practiceSessionId,
    required this.resultados,
    required this.sugestoesPalavras,
    required this.totalCorretos,
    required this.totalExercicios,
  });

  final String practiceSessionId;
  final List<ExerciseResultEntry> resultados;
  final List<String> sugestoesPalavras;
  final int totalCorretos;
  final int totalExercicios;

  /// Corpo esperado por `POST /vocab/practice/{practiceSessionId}/submit`.
  Map<String, dynamic> toSubmitBody() => {
        'resultados': resultados.map((e) => e.toJson()).toList(),
      };
}

abstract final class PracticeExerciseModality {
  PracticeExerciseModality._();

  static const String vocabMatch = 'vocab_match';
  static const String listeningComprehension = 'listening_comprehension';
  static const String fillBlanks = 'fill_blanks';
  static const String dialogueCompletion = 'dialogue_completion';
}
