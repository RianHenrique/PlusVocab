class ThemeSlice {
  const ThemeSlice({
    required this.themeId,
    required this.name,
    required this.count,
    required this.accuracy,
  });

  final String themeId;
  final String name;
  final int count;
  final double accuracy;

  factory ThemeSlice.fromJson(Map<String, dynamic> json) {
    return ThemeSlice(
      themeId: json['themeId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ThemesGeneralRow {
  const ThemesGeneralRow({
    required this.period,
    required this.themes,
  });

  final String period;
  final List<ThemeSlice> themes;

  factory ThemesGeneralRow.fromJson(Map<String, dynamic> json) {
    final raw = json['themes'];
    final list = raw is List
        ? raw.map((e) => ThemeSlice.fromJson(e as Map<String, dynamic>)).toList()
        : const <ThemeSlice>[];
    return ThemesGeneralRow(
      period: json['period']?.toString() ?? '',
      themes: list,
    );
  }
}

class ThemesSimpleRow {
  const ThemesSimpleRow({
    required this.period,
    required this.count,
    required this.accuracy,
  });

  final String period;
  final int count;
  final double? accuracy;

  factory ThemesSimpleRow.fromJson(Map<String, dynamic> json) {
    return ThemesSimpleRow(
      period: json['period']?.toString() ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble(),
    );
  }
}

class ThemesResponse {
  const ThemesResponse({
    required this.accuracy,
    required this.isGeneral,
    required this.generalRows,
    required this.simpleRows,
  });

  final double accuracy;
  final bool isGeneral;
  final List<ThemesGeneralRow> generalRows;
  final List<ThemesSimpleRow> simpleRows;

  factory ThemesResponse.fromJson(Map<String, dynamic> json) {
    final acc = (json['accuracy'] as num?)?.toDouble() ?? 0;
    final raw = json['data'];
    final list = raw is List ? raw : const [];
    if (list.isEmpty) {
      return ThemesResponse(
        accuracy: acc,
        isGeneral: true,
        generalRows: const [],
        simpleRows: const [],
      );
    }
    final first = list.first;
    if (first is! Map<String, dynamic>) {
      return ThemesResponse(
        accuracy: acc,
        isGeneral: true,
        generalRows: const [],
        simpleRows: const [],
      );
    }
    if (first.containsKey('themes')) {
      return ThemesResponse(
        accuracy: acc,
        isGeneral: true,
        generalRows:
            list.map((e) => ThemesGeneralRow.fromJson(e as Map<String, dynamic>)).toList(),
        simpleRows: const [],
      );
    }
    return ThemesResponse(
      accuracy: acc,
      isGeneral: false,
      generalRows: const [],
      simpleRows:
          list.map((e) => ThemesSimpleRow.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
