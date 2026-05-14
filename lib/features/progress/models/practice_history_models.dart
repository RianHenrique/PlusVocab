class PracticeHistoryEntry {
  const PracticeHistoryEntry({
    required this.id,
    required this.themeId,
    required this.theme,
    required this.accuracy,
    required this.date,
  });

  final String id;
  final String themeId;
  final String theme;
  final double accuracy;
  final DateTime date;

  factory PracticeHistoryEntry.fromJson(Map<String, dynamic> json) {
    return PracticeHistoryEntry(
      id: json['id']?.toString() ?? '',
      themeId: json['themeId']?.toString() ?? '',
      theme: json['theme']?.toString() ?? '',
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0,
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class PracticeHistoryResponse {
  const PracticeHistoryResponse({
    required this.practices,
    required this.total,
  });

  final List<PracticeHistoryEntry> practices;
  final int total;

  factory PracticeHistoryResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['practices'];
    final practices = raw is List
        ? raw
            .map((e) => PracticeHistoryEntry.fromJson(e as Map<String, dynamic>))
            .toList()
        : const <PracticeHistoryEntry>[];
    return PracticeHistoryResponse(
      practices: practices,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}
