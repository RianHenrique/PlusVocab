class PalavraWord {
  const PalavraWord({required this.id, required this.text, required this.lang});

  final String id;
  final String text;
  final String lang;

  factory PalavraWord.fromJson(Map<String, dynamic> json) => PalavraWord(
        id: json['id'] as String,
        text: json['text'] as String,
        lang: json['lang'] as String? ?? 'en',
      );
}

class PalavraModel {
  const PalavraModel({
    required this.id,
    required this.boxLevel,
    required this.correctCount,
    required this.incorrectCount,
    required this.lastSeenAt,
    required this.word,
  });

  final String id;
  final int boxLevel;
  final int correctCount;
  final int incorrectCount;
  final String? lastSeenAt;
  final PalavraWord word;

  factory PalavraModel.fromJson(Map<String, dynamic> json) => PalavraModel(
        id: json['id'] as String,
        boxLevel: (json['boxLevel'] as num).toInt(),
        correctCount: (json['correctCount'] as num? ?? 0).toInt(),
        incorrectCount: (json['incorrectCount'] as num? ?? 0).toInt(),
        lastSeenAt: json['lastSeenAt'] as String?,
        word: PalavraWord.fromJson(json['word'] as Map<String, dynamic>),
      );
}
