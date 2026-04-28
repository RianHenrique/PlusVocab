class ProgressSummary {
  const ProgressSummary({
    required this.activeDays,
    required this.totalPractices,
    required this.accuracy,
    required this.wordsMastered,
    required this.wordsSeen,
    required this.userStreak,
  });

  final int activeDays;
  final int totalPractices;
  final double accuracy;
  final int wordsMastered;
  final int wordsSeen;
  final int userStreak;

  factory ProgressSummary.fromJson(Map<String, dynamic> json) {
    return ProgressSummary(
      activeDays: (json['activeDays'] as num?)?.toInt() ?? 0,
      totalPractices: (json['totalPractices'] as num?)?.toInt() ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0,
      wordsMastered: (json['wordsMastered'] as num?)?.toInt() ?? 0,
      wordsSeen: (json['wordsSeen'] as num?)?.toInt() ?? 0,
      userStreak: (json['userStreak'] as num?)?.toInt() ?? 0,
    );
  }
}

class ProgressBoxRow {
  const ProgressBoxRow({
    required this.box,
    required this.count,
    required this.words,
  });

  final int box;
  final int count;
  final List<String> words;

  factory ProgressBoxRow.fromJson(Map<String, dynamic> json) {
    final rawWords = json['words'];
    final words = rawWords is List
        ? rawWords.map((e) => e.toString()).toList()
        : const <String>[];
    return ProgressBoxRow(
      box: (json['box'] as num?)?.toInt() ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 0,
      words: words,
    );
  }
}

class ProgressWeeklyDay {
  const ProgressWeeklyDay({
    required this.date,
    required this.count,
    required this.accuracy,
  });

  final String date;
  final int count;
  final double? accuracy;

  factory ProgressWeeklyDay.fromJson(Map<String, dynamic> json) {
    return ProgressWeeklyDay(
      date: json['date']?.toString() ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble(),
    );
  }
}

class ProgressWeeklyBundle {
  const ProgressWeeklyBundle({
    required this.average,
    required this.data,
  });

  final double average;
  final List<ProgressWeeklyDay> data;

  factory ProgressWeeklyBundle.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final list = raw is List
        ? raw
            .map((e) => ProgressWeeklyDay.fromJson(e as Map<String, dynamic>))
            .toList()
        : const <ProgressWeeklyDay>[];
    return ProgressWeeklyBundle(
      average: (json['average'] as num?)?.toDouble() ?? 0,
      data: list,
    );
  }
}

class ProgressOverview {
  const ProgressOverview({
    required this.summary,
    required this.boxes,
    required this.weekly,
  });

  final ProgressSummary summary;
  final List<ProgressBoxRow> boxes;
  final ProgressWeeklyBundle weekly;

  factory ProgressOverview.fromJson(Map<String, dynamic> json) {
    final rawBoxes = json['boxes'];
    final boxes = rawBoxes is List
        ? rawBoxes
            .map((e) => ProgressBoxRow.fromJson(e as Map<String, dynamic>))
            .toList()
        : const <ProgressBoxRow>[];
    boxes.sort((a, b) => a.box.compareTo(b.box));

    final weeklyRaw = json['weekly'];
    final weekly = weeklyRaw is Map<String, dynamic>
        ? ProgressWeeklyBundle.fromJson(weeklyRaw)
        : const ProgressWeeklyBundle(average: 0, data: []);

    final summaryRaw = json['summary'];
    final summary = summaryRaw is Map<String, dynamic>
        ? ProgressSummary.fromJson(summaryRaw)
        : const ProgressSummary(
            activeDays: 0,
            totalPractices: 0,
            accuracy: 0,
            wordsMastered: 0,
            wordsSeen: 0,
            userStreak: 0,
          );

    return ProgressOverview(
      summary: summary,
      boxes: boxes,
      weekly: weekly,
    );
  }
}
