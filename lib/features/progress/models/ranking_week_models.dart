class RankingWeekEntry {
  const RankingWeekEntry({
    required this.position,
    required this.name,
    required this.totalPracticesWeek,
  });

  final int position;
  final String name;
  final int totalPracticesWeek;

  factory RankingWeekEntry.fromJson(Map<String, dynamic> json) {
    return RankingWeekEntry(
      position: (json['position'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?)?.trim() ?? '',
      totalPracticesWeek: (json['totalPracticesWeek'] as num?)?.toInt() ?? 0,
    );
  }
}

class RankingWeekResponse {
  const RankingWeekResponse({
    required this.ranking,
    required this.user,
  });

  final List<RankingWeekEntry> ranking;
  final RankingWeekEntry user;

  factory RankingWeekResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['ranking'];
    final list = <RankingWeekEntry>[];
    if (rawList is List) {
      for (final item in rawList) {
        if (item is Map<String, dynamic>) {
          list.add(RankingWeekEntry.fromJson(item));
        }
      }
    }
    final userMap = json['user'];
    final user = userMap is Map<String, dynamic>
        ? RankingWeekEntry.fromJson(userMap)
        : const RankingWeekEntry(position: 0, name: '', totalPracticesWeek: 0);

    return RankingWeekResponse(ranking: list, user: user);
  }
}
