import 'dart:math';

import 'package:plus_vocab/features/pratica/exercicio/models/dialogue_completion_models.dart';
import 'package:plus_vocab/features/pratica/exercicio/models/fill_in_the_blanks_models.dart';
import 'package:plus_vocab/features/pratica/exercicio/models/listening_comprehension_models.dart';
import 'package:plus_vocab/features/pratica/exercicio/models/practice_session_models.dart';
import 'package:plus_vocab/features/pratica/exercicio/models/vocabulary_match_models.dart';

abstract final class PracticeSessionExerciseAdapters {
  PracticeSessionExerciseAdapters._();

  /// Semente estável por sessão + índice do exercício na lista, para que o embaralhamento
  /// de alternativas/palavras seja idêntico em toda abertura da mesma partida (incluindo revisão).
  static int stableShuffleSeed(String practiceSessionId, int exerciseIndex) {
    return Object.hash(practiceSessionId, exerciseIndex) & 0x7fffffff;
  }

  static String _norm(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '').trim();

  /// Monta o vocab match a partir do payload e embaralha palavras e definições na UI,
  /// remapeando [answerKey] para manter a correção alinhada ao gabarito original.
  static VocabularyMatchQuestion vocabularyMatchFromItem(
    PracticeExerciseItem item, {
    required String practiceSessionId,
    required int exerciseIndex,
    Random? random,
  }) {
    final rnd =
        random ?? Random(stableShuffleSeed(practiceSessionId, exerciseIndex));
    final pairs = _wordDefinitionPairs(item.options);
    final words = List<String>.from(item.palavrasChave);
    if (pairs.isEmpty || words.isEmpty) {
      throw StateError(
          'vocab_match inválido: options ou palavras_chave vazios.');
    }

    final definitions = <String>[];
    final answerKey = <int>[];

    for (final pair in pairs) {
      definitions.add(pair.definition);
      final wordIndex = words.indexWhere((w) => _norm(w) == _norm(pair.word));
      if (wordIndex < 0) {
        throw StateError(
            'Palavra "${pair.word}" não encontrada em palavras_chave.');
      }
      answerKey.add(wordIndex);
    }

    final defPerm = List<int>.generate(definitions.length, (i) => i)
      ..shuffle(rnd);
    final shuffledDefinitions = defPerm.map((i) => definitions[i]).toList();
    final answerKeyAfterDefs = defPerm.map((i) => answerKey[i]).toList();

    final wordCount = words.length;
    final wordPerm = List<int>.generate(wordCount, (i) => i)..shuffle(rnd);
    final shuffledWords = wordPerm.map((i) => words[i]).toList();
    final oldIndexToDisplay = List<int>.filled(wordCount, 0);
    for (var display = 0; display < wordCount; display++) {
      oldIndexToDisplay[wordPerm[display]] = display;
    }
    final finalAnswerKey = answerKeyAfterDefs
        .map((oldWordIdx) => oldIndexToDisplay[oldWordIdx])
        .toList();

    return VocabularyMatchQuestion(
      words: shuffledWords,
      definitions: shuffledDefinitions,
      answerKey: finalAnswerKey,
    );
  }

  /// Embaralha a ordem das alternativas na UI e ajusta o índice da resposta correta.
  static ListeningComprehensionQuestion listeningFromItem(
    PracticeExerciseItem item, {
    required String practiceSessionId,
    required int exerciseIndex,
    Random? random,
  }) {
    final script = item.text?.trim() ?? '';
    final questionText = item.questao?.trim() ?? '';
    final options = _stringList(item.options);
    final gabarito = item.gabarito?.trim() ?? '';

    if (script.isEmpty ||
        questionText.isEmpty ||
        options.length < 2 ||
        gabarito.isEmpty) {
      throw StateError(
          'listening_comprehension inválido: campos obrigatórios ausentes.');
    }

    final correctIndex = options.indexWhere((o) => _norm(o) == _norm(gabarito));
    if (correctIndex < 0) {
      throw StateError('Gabarito não corresponde a nenhuma opção.');
    }

    final rnd =
        random ?? Random(stableShuffleSeed(practiceSessionId, exerciseIndex));
    final perm = List<int>.generate(options.length, (i) => i)..shuffle(rnd);
    final shuffledOptions = perm.map((i) => options[i]).toList();
    final correctAfterShuffle = perm.indexOf(correctIndex);

    return ListeningComprehensionQuestion(
      listeningScript: script,
      questionText: questionText,
      options: shuffledOptions,
      correctOptionIndex: correctAfterShuffle,
    );
  }

  /// Monta Dialogue Completion a partir do item da sessão.
  ///
  /// Espera típico: [questao] = fala em destaque; [options] = lista de textos para TTS (opções
  /// “ocultas”); [gabarito] e/ou [palavras_chave] = respostas aceitas na fala (várias frases
  /// separadas por `|`, `;` ou quebra de linha em [gabarito]).
  static DialogueCompletionQuestion dialogueCompletionFromItem(
      PracticeExerciseItem item) {
    var promptLine = item.questao?.trim() ?? '';
    if (promptLine.isEmpty) {
      promptLine = item.text?.trim() ?? '';
    }
    var obscuredLineAudios = _dialogueAudioLines(item.options);
    if (obscuredLineAudios.isEmpty) {
      final script = item.text?.trim() ?? '';
      if (script.isNotEmpty) {
        obscuredLineAudios = [script];
      }
    }
    if (obscuredLineAudios.isEmpty) {
      throw StateError(
        'dialogue_completion inválido: informe "options" (lista de falas) ou "text" com conteúdo.',
      );
    }

    final acceptedAnswers = <String>[];
    final gabarito = item.gabarito?.trim() ?? '';
    if (gabarito.isNotEmpty) {
      acceptedAnswers.addAll(_splitAcceptedPhrases(gabarito));
    }
    for (final p in item.palavrasChave) {
      final t = p.trim();
      if (t.isEmpty) continue;
      final dup = acceptedAnswers.any((a) => _norm(a) == _norm(t));
      if (!dup) acceptedAnswers.add(t);
    }
    if (acceptedAnswers.isEmpty) {
      throw StateError(
        'dialogue_completion inválido: informe "gabarito" e/ou "palavras_chave" para validar a fala.',
      );
    }

    if (promptLine.isEmpty) {
      promptLine = 'Ouça as opções e responda em voz alta em inglês.';
    }

    return DialogueCompletionQuestion(
      promptLine: promptLine,
      obscuredLineAudios: obscuredLineAudios,
      acceptedAnswers: acceptedAnswers,
      ttsLanguage: 'en-US',
    );
  }

  static List<String> _splitAcceptedPhrases(String gabarito) {
    final parts = gabarito.split(RegExp(r'[|;\n]+'));
    return parts.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  static List<String> _dialogueAudioLines(Object? raw) {
    if (raw is! List) return const [];
    final out = <String>[];
    for (final e in raw) {
      if (e is String) {
        final t = e.trim();
        if (t.isNotEmpty) out.add(t);
      } else if (e is Map) {
        final t = (e['text'] ?? e['audio'] ?? e['line'] ?? e['utterance'])
                ?.toString()
                .trim() ??
            '';
        if (t.isNotEmpty) out.add(t);
      } else if (e is List && e.isNotEmpty) {
        final t = e.first.toString().trim();
        if (t.isNotEmpty) out.add(t);
      }
    }
    return out;
  }

  static FillInTheBlanksQuestion fillBlanksFromItem(PracticeExerciseItem item) {
    final full = item.questao?.trim() ?? '';
    final gabarito = item.gabarito?.trim() ?? '';
    if (full.isEmpty || gabarito.isEmpty) {
      throw StateError('fill_blanks inválido: questao ou gabarito ausente.');
    }

    const markers = ['___', '…', '...'];
    var splitAt = -1;
    var markerLen = 0;
    for (final m in markers) {
      final idx = full.indexOf(m);
      if (idx >= 0) {
        splitAt = idx;
        markerLen = m.length;
        break;
      }
    }

    if (splitAt < 0) {
      throw StateError('fill_blanks: questão sem marcador de lacuna (___).');
    }

    final before = full.substring(0, splitAt);
    final after = full.substring(splitAt + markerLen);

    return FillInTheBlanksQuestion(
      textBeforeBlank: before,
      textAfterBlank: after,
      acceptedAnswers: [gabarito],
    );
  }

  static List<_WordDefinitionPair> _wordDefinitionPairs(Object? raw) {
    if (raw is! List) return const [];
    final out = <_WordDefinitionPair>[];
    for (final row in raw) {
      if (row is List && row.length >= 2) {
        out.add(_WordDefinitionPair(row[0].toString(), row[1].toString()));
      }
    }
    return out;
  }

  static List<String> _stringList(Object? raw) {
    if (raw is! List) return const [];
    return raw.map((e) => e.toString()).toList();
  }
}

class _WordDefinitionPair {
  const _WordDefinitionPair(this.word, this.definition);

  final String word;
  final String definition;
}
