class ProgressHome {
  const ProgressHome({
    required this.activeDaysWeek,
    required this.userStreak,
    required this.totalPracticesWeek,
    required this.differenceLastWeek,
    required this.accuracyWeek,
    required this.wordsSeen,
  });

  final List<String> activeDaysWeek;
  final int userStreak;
  final int totalPracticesWeek;
  final int differenceLastWeek;
  final double accuracyWeek;
  final int wordsSeen;

  factory ProgressHome.fromJson(Map<String, dynamic> json) {
    final rawDays = json['activeDaysWeek'];
    final days = rawDays is List
        ? rawDays.map((e) {
            final s = (e as String).toLowerCase().trim();
            if (s == 'sáb') return 'sab';
            return s;
          }).toList()
        : const <String>[];

    return ProgressHome(
      activeDaysWeek: days,
      userStreak: (json['userStreak'] as num?)?.toInt() ?? 0,
      totalPracticesWeek: (json['totalPracticesWeek'] as num?)?.toInt() ?? 0,
      differenceLastWeek: (json['differenceLastWeek'] as num?)?.toInt() ?? 0,
      accuracyWeek: (json['accuracyWeek'] as num?)?.toDouble() ?? 0,
      wordsSeen: (json['wordsSeen'] as num?)?.toInt() ?? 0,
    );
  }

  bool get hasSummaryData => totalPracticesWeek > 0 || wordsSeen > 0;
}
