class TemaModalidade {
  const TemaModalidade({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory TemaModalidade.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is int ? rawId : (rawId as num).toInt();
    return TemaModalidade(
      id: id,
      name: json['name'] as String,
    );
  }
}

class TemaResumo {
  const TemaResumo({
    required this.id,
    required this.name,
    required this.description,
    required this.modalities,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final List<TemaModalidade> modalities;
  final String createdAt;
  final String updatedAt;

  factory TemaResumo.fromJson(Map<String, dynamic> json) {
    final modalitiesJson = json['modalities'] as List<dynamic>? ?? [];
    return TemaResumo(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      modalities: modalitiesJson
          .map((e) => TemaModalidade.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }
}
