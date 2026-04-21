import 'package:dio/dio.dart';
import 'palavra_info_model.dart';

class PalavraInfoService {
  final Dio _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 8)));

  Future<PalavraInfo> buscarInfo(String word) async {
    final dictResult = await _buscarDictionary(word);
    final definicaoEn = dictResult['definicao'] as String;

    final wordCapitalized = word.isEmpty ? word : word[0].toUpperCase() + word.substring(1);
    final results = await Future.wait([
      _traduzir(wordCapitalized),
      if (definicaoEn.isNotEmpty) _traduzir(definicaoEn) else Future.value(definicaoEn),
    ]);

    return PalavraInfo(
      word: word,
      partOfSpeech: dictResult['partOfSpeech'] as String? ?? '',
      traducao: results[0],
      definicao: results[1],
      exemplos: List<String>.from(dictResult['exemplos'] as List),
    );
  }

  Future<Map<String, dynamic>> _buscarDictionary(String word) async {
    try {
      final response = await _dio.get(
        'https://api.dictionaryapi.dev/api/v2/entries/en/$word',
      );
      final data = (response.data as List).first as Map<String, dynamic>;
      final meanings = data['meanings'] as List? ?? [];

      String partOfSpeech = '';
      String definicao = '';
      final exemplos = <String>[];

      // Prioriza o meaning com mais exemplos
      Map<String, dynamic>? melhorMeaning;
      int maxExemplos = -1;

      for (final meaning in meanings) {
        final definitions = meaning['definitions'] as List? ?? [];
        int count = 0;
        for (final def in definitions) {
          if ((def['example'] as String?)?.isNotEmpty == true) count++;
        }
        if (count > maxExemplos) {
          maxExemplos = count;
          melhorMeaning = meaning as Map<String, dynamic>;
        }
      }

      final alvo = melhorMeaning ?? (meanings.isNotEmpty ? meanings.first as Map<String, dynamic> : null);
      if (alvo != null) {
        partOfSpeech = alvo['partOfSpeech'] as String? ?? '';
        final definitions = alvo['definitions'] as List? ?? [];
        for (final def in definitions) {
          if (definicao.isEmpty) definicao = def['definition'] as String? ?? '';
          final example = def['example'] as String?;
          if (example != null && example.isNotEmpty && exemplos.length < 3) {
            exemplos.add(example);
          }
        }
      }

      return {'partOfSpeech': partOfSpeech, 'definicao': definicao, 'exemplos': exemplos};
    } catch (_) {
      return {'partOfSpeech': '', 'definicao': '', 'exemplos': <String>[]};
    }
  }

  Future<String> _traduzir(String text) async {
    try {
      final response = await _dio.get(
        'https://translate.googleapis.com/translate_a/single',
        queryParameters: {
          'client': 'gtx',
          'sl': 'en',
          'tl': 'pt-BR',
          'dt': 't',
          'q': text,
        },
      );
      final data = response.data as List;
      final translations = data[0] as List;
      return translations.map((part) => part[0] as String? ?? '').join();
    } catch (_) {
      return text;
    }
  }
}
