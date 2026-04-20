import 'dart:math';

import 'package:plus_vocab/features/pratica/exercicio/models/fill_in_the_blanks_models.dart';
import 'package:plus_vocab/features/pratica/exercicio/models/listening_comprehension_models.dart';
import 'package:plus_vocab/features/pratica/exercicio/models/practice_session_models.dart';
import 'package:plus_vocab/features/pratica/exercicio/models/vocabulary_match_models.dart';

abstract final class PracticeSessionExerciseAdapters {
  PracticeSessionExerciseAdapters._();

  static String _norm(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '').trim();

  /// Monta o vocab match a partir do payload e embaralha palavras e definições na UI,
  /// remapeando [answerKey] para manter a correção alinhada ao gabarito original.
  static VocabularyMatchQuestion vocabularyMatchFromItem(
    PracticeExerciseItem item, {
    Random? random,
  }) {
    final rnd = random ?? Random();
    final pairs = _wordDefinitionPairs(item.options);
    final words = List<String>.from(item.palavrasChave);
    if (pairs.isEmpty || words.isEmpty) {
      throw StateError('vocab_match inválido: options ou palavras_chave vazios.');
    }

    final definitions = <String>[];
    final answerKey = <int>[];

    for (final pair in pairs) {
      definitions.add(pair.definition);
      final wordIndex = words.indexWhere((w) => _norm(w) == _norm(pair.word));
      if (wordIndex < 0) {
        throw StateError('Palavra "${pair.word}" não encontrada em palavras_chave.');
      }
      answerKey.add(wordIndex);
    }

    final defPerm = List<int>.generate(definitions.length, (i) => i)..shuffle(rnd);
    final shuffledDefinitions = defPerm.map((i) => definitions[i]).toList();
    final answerKeyAfterDefs = defPerm.map((i) => answerKey[i]).toList();

    final wordCount = words.length;
    final wordPerm = List<int>.generate(wordCount, (i) => i)..shuffle(rnd);
    final shuffledWords = wordPerm.map((i) => words[i]).toList();
    final oldIndexToDisplay = List<int>.filled(wordCount, 0);
    for (var display = 0; display < wordCount; display++) {
      oldIndexToDisplay[wordPerm[display]] = display;
    }
    final finalAnswerKey =
        answerKeyAfterDefs.map((oldWordIdx) => oldIndexToDisplay[oldWordIdx]).toList();

    return VocabularyMatchQuestion(
      words: shuffledWords,
      definitions: shuffledDefinitions,
      answerKey: finalAnswerKey,
    );
  }

  /// Embaralha a ordem das alternativas na UI e ajusta o índice da resposta correta.
  static ListeningComprehensionQuestion listeningFromItem(
    PracticeExerciseItem item, {
    Random? random,
  }) {
    final script = item.text?.trim() ?? '';
    final questionText = item.questao?.trim() ?? '';
    final options = _stringList(item.options);
    final gabarito = item.gabarito?.trim() ?? '';

    if (script.isEmpty || questionText.isEmpty || options.length < 2 || gabarito.isEmpty) {
      throw StateError('listening_comprehension inválido: campos obrigatórios ausentes.');
    }

    final correctIndex = options.indexWhere((o) => _norm(o) == _norm(gabarito));
    if (correctIndex < 0) {
      throw StateError('Gabarito não corresponde a nenhuma opção.');
    }

    final rnd = random ?? Random();
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
