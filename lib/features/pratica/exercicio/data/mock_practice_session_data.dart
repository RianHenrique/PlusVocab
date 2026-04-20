import 'package:plus_vocab/features/pratica/exercicio/models/practice_session_models.dart';

/// Mock local até integrar o GET/POST de prática no backend.
abstract final class MockPracticeSessionData {
  MockPracticeSessionData._();

  static const Map<String, dynamic> rawJson = {
    'practiceSessionId': 'ec7c6f3e-07a5-4bdb-a9be-aa653586cbe6',
    'exercicios': [
      {
        'numero': 1,
        'modalidade': 'vocab_match',
        'questao': null,
        'gabarito': null,
        'text': null,
        'options': [
          [
            'provisioning',
            'the process of setting up services, accounts, or equipment so they are ready to use',
          ],
          [
            'bandwidth',
            'the amount of data that can be transferred over an internet connection in a given time',
          ],
          [
            'passport',
            'an official document that certifies identity and nationality for international travel',
          ],
        ],
        'palavras_chave': ['provisioning', 'bandwidth', 'passport'],
      },
      {
        'numero': 2,
        'modalidade': 'listening_comprehension',
        'questao':
            'What is the speaker describing about the work they will do after arrival?',
        'gabarito': 'provisioning',
        'text':
            "At the hotel I will prepare the company's systems before the workshop. I will create accounts, install necessary software on the team's devices, and configure network access so everyone can start immediately.",
        'options': ['Provisioning', 'Boarding', 'Currency exchange'],
        'palavras_chave': ['provisioning'],
      },
      {
        'numero': 3,
        'modalidade': 'listening_comprehension',
        'questao': 'What does the speaker need for smooth video calls and large uploads?',
        'gabarito': 'bandwidth',
        'text':
            'I need a fast and stable connection for live demos and to upload large files. If the line is slow, the meeting will lag and file transfers will take too long.',
        'options': ['Bandwidth', 'Visa', 'Hotel reservation'],
        'palavras_chave': ['bandwidth'],
      },
      {
        'numero': 4,
        'modalidade': 'fill_blanks',
        'questao':
            'Officer: "Why are you attending the conference?" You: "I want to ___ my experience with cloud deployments to support our European clients."',
        'gabarito': 'leverage',
        'text': null,
        'options': null,
        'palavras_chave': ['leverage'],
      },
      {
        'numero': 5,
        'modalidade': 'fill_blanks',
        'questao':
            'At passport control the agent asks: "Please place your ___ on the scanner and hand me the arrival form."',
        'gabarito': 'passport',
        'text': null,
        'options': null,
        'palavras_chave': ['passport'],
      },
    ],
    'sugestoes_palavras': ['passport', 'itinerary'],
  };

  static PracticeSessionPayload get sample {
    const root = rawJson;
    final id = root['practiceSessionId']?.toString() ?? '';
    final exRaw = root['exercicios'];
    final exercicios = exRaw is List
        ? exRaw
            .whereType<Map<String, dynamic>>()
            .map(PracticeExerciseItem.fromJson)
            .toList()
        : <PracticeExerciseItem>[];
    final sugRaw = root['sugestoes_palavras'];
    final sugestoes = sugRaw is List ? sugRaw.map((e) => e.toString()).toList() : <String>[];
    return PracticeSessionPayload(
      practiceSessionId: id,
      exercicios: exercicios,
      sugestoesPalavras: sugestoes,
    );
  }
}
