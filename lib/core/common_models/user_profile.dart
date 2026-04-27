class UserProfile {
  const UserProfile({
    required this.name,
    required this.age,
    required this.fluency,
    required this.occupationArea,
    required this.locale,
  });

  final String name;
  final int age;
  final String fluency;
  final String occupationArea;
  final String locale;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final rawAge = json['age'];
    final age = rawAge is int ? rawAge : (rawAge as num?)?.toInt() ?? 0;
    return UserProfile(
      name: json['name'] as String? ?? '',
      age: age,
      fluency: json['fluency'] as String? ?? '',
      occupationArea: json['occupationArea'] as String? ?? '',
      locale: json['locale'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'fluency': fluency,
        'occupationArea': occupationArea,
        'locale': locale,
      };
}
