class ModalitySlice {
  const ModalitySlice({
    required this.modalityId,
    required this.name,
    required this.count,
    required this.accuracy,
  });

  final int modalityId;
  final String name;
  final int count;
  final double accuracy;

  factory ModalitySlice.fromJson(Map<String, dynamic> json) {
    return ModalitySlice(
      modalityId: (json['modalityId'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ModalitiesGeneralRow {
  const ModalitiesGeneralRow({
    required this.period,
    required this.modalities,
  });

  final String period;
  final List<ModalitySlice> modalities;

  factory ModalitiesGeneralRow.fromJson(Map<String, dynamic> json) {
    final raw = json['modalities'];
    final list = raw is List
        ? raw
            .map((e) => ModalitySlice.fromJson(e as Map<String, dynamic>))
            .toList()
        : const <ModalitySlice>[];
    return ModalitiesGeneralRow(
      period: json['period']?.toString() ?? '',
      modalities: list,
    );
  }
}

class ModalitiesSimpleRow {
  const ModalitiesSimpleRow({
    required this.period,
    required this.count,
    required this.accuracy,
  });

  final String period;
  final int count;
  final double? accuracy;

  factory ModalitiesSimpleRow.fromJson(Map<String, dynamic> json) {
    return ModalitiesSimpleRow(
      period: json['period']?.toString() ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble(),
    );
  }
}

class ModalitiesResponse {
  const ModalitiesResponse({
    required this.accuracy,
    required this.isGeneral,
    required this.generalRows,
    required this.simpleRows,
  });

  final double accuracy;
  final bool isGeneral;
  final List<ModalitiesGeneralRow> generalRows;
  final List<ModalitiesSimpleRow> simpleRows;

  factory ModalitiesResponse.fromJson(Map<String, dynamic> json) {
    final acc = (json['accuracy'] as num?)?.toDouble() ?? 0;
    final raw = json['data'];
    final list = raw is List ? raw : const [];
    if (list.isEmpty) {
      return ModalitiesResponse(
        accuracy: acc,
        isGeneral: true,
        generalRows: const [],
        simpleRows: const [],
      );
    }
    final first = list.first;
    if (first is! Map<String, dynamic>) {
      return ModalitiesResponse(
        accuracy: acc,
        isGeneral: true,
        generalRows: const [],
        simpleRows: const [],
      );
    }
    if (first.containsKey('modalities')) {
      return ModalitiesResponse(
        accuracy: acc,
        isGeneral: true,
        generalRows: list
            .map((e) => ModalitiesGeneralRow.fromJson(e as Map<String, dynamic>))
            .toList(),
        simpleRows: const [],
      );
    }
    return ModalitiesResponse(
      accuracy: acc,
      isGeneral: false,
      generalRows: const [],
      simpleRows: list
          .map((e) => ModalitiesSimpleRow.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
