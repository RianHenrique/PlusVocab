class PalavraInfo {
  const PalavraInfo({
    required this.word,
    required this.partOfSpeech,
    required this.traducao,
    required this.definicao,
    required this.exemplos,
  });

  final String word;
  final String partOfSpeech;
  final String traducao;
  final String definicao;
  final List<String> exemplos;
}
