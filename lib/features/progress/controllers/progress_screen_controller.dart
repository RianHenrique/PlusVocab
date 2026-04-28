import 'package:flutter/foundation.dart';
import 'package:plus_vocab/features/progress/data/progress_service.dart';
import 'package:plus_vocab/features/progress/views/progress_formatters.dart';
import 'package:plus_vocab/features/progress/models/progress_modalities_models.dart';
import 'package:plus_vocab/features/progress/models/progress_overview_models.dart';
import 'package:plus_vocab/features/progress/models/progress_themes_models.dart';

class ModalityOption {
  const ModalityOption({required this.id, required this.label});

  final int id;
  final String label;
}

class ThemeOption {
  const ThemeOption({required this.id, required this.label});

  final String id;
  final String label;
}

class ProgressScreenController extends ChangeNotifier {
  ProgressScreenController(this._service);

  final ProgressService _service;

  ProgressOverview? _overview;
  String? _initialError;
  bool _isInitialLoading = false;

  DateTime? _weekStartLocal;
  ProgressWeeklyBundle _weeklyBundle = const ProgressWeeklyBundle(average: 0, data: []);
  bool _isWeeklyLoading = false;
  String? _weeklyError;

  DateTime _modalitiesChartMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _themesChartMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  ModalitiesResponse? _modalities;
  ThemesResponse? _themes;
  bool _isModalitiesLoading = false;
  bool _isThemesLoading = false;
  String? _modalitiesError;
  String? _themesError;

  int? _selectedModalityId;
  String? _selectedThemeId;

  List<ModalityOption> _modalityOptions = const [];
  List<ThemeOption> _themeOptions = const [];

  ProgressOverview? get overview => _overview;
  String? get initialError => _initialError;
  bool get isInitialLoading => _isInitialLoading;

  DateTime? get weekStartLocal => _weekStartLocal;
  ProgressWeeklyBundle get weeklyBundle => _weeklyBundle;
  bool get isWeeklyLoading => _isWeeklyLoading;
  String? get weeklyError => _weeklyError;

  DateTime get modalitiesChartMonth => _modalitiesChartMonth;

  DateTime get themesChartMonth => _themesChartMonth;
  ModalitiesResponse? get modalities => _modalities;
  ThemesResponse? get themes => _themes;
  bool get isModalitiesLoading => _isModalitiesLoading;
  bool get isThemesLoading => _isThemesLoading;
  String? get modalitiesError => _modalitiesError;
  String? get themesError => _themesError;

  int? get selectedModalityId => _selectedModalityId;
  String? get selectedThemeId => _selectedThemeId;

  List<ModalityOption> get modalityOptions => _modalityOptions;
  List<ThemeOption> get themeOptions => _themeOptions;

  int _selectedBoxNumber = 1;

  int get selectedBoxNumber => _selectedBoxNumber;

  ProgressBoxRow? get selectedBoxRow {
    final boxes = _overview?.boxes ?? const <ProgressBoxRow>[];
    for (final b in boxes) {
      if (b.box == _selectedBoxNumber) {
        return b;
      }
    }
    return ProgressBoxRow(box: _selectedBoxNumber, count: 0, words: const []);
  }

  set selectedBoxNumber(int value) {
    if (value < 1 || value > 5) {
      return;
    }
    if (_selectedBoxNumber == value) {
      return;
    }
    _selectedBoxNumber = value;
    notifyListeners();
  }

  static String formatApiDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  static DateTime parseApiDate(String raw) => parseProgressApiDate(raw);

  /// Início da semana civil domingo–sábado (data local, sem horário).
  static DateTime startOfProgressWeekSunday(DateTime localDay) {
    final day = DateTime(localDay.year, localDay.month, localDay.day);
    final daysBack = day.weekday == DateTime.sunday ? 0 : day.weekday;
    return day.subtract(Duration(days: daysBack));
  }

  static ProgressWeeklyBundle weeklyBundleForSundayWeek(
    ProgressWeeklyBundle bundle,
    DateTime weekStartSunday,
  ) {
    final start = startOfProgressWeekSunday(weekStartSunday);
    final byDate = {for (final d in bundle.data) d.date: d};
    final normalized = List.generate(7, (i) {
      final dt = start.add(Duration(days: i));
      final key = formatApiDate(dt);
      return byDate[key] ??
          ProgressWeeklyDay(date: key, count: 0, accuracy: null);
    });
    return ProgressWeeklyBundle(average: bundle.average, data: normalized);
  }

  Future<void> loadInitial() async {
    _isInitialLoading = true;
    _initialError = null;
    notifyListeners();

    try {
      _overview = await _service.fetchOverview();
      _pickDefaultBox();
      final monthAnchor = DateTime(DateTime.now().year, DateTime.now().month, 1);
      _modalitiesChartMonth = monthAnchor;
      _themesChartMonth = monthAnchor;
      _selectedModalityId = null;
      _selectedThemeId = null;
    } catch (e) {
      _initialError = e.toString();
    } finally {
      _isInitialLoading = false;
      notifyListeners();
    }
    if (_overview != null) {
      final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      final sunday = startOfProgressWeekSunday(today);
      await Future.wait([
        _fetchWeeklyForStart(sunday),
        _reloadModalities(),
        _reloadThemes(),
      ]);
    }
  }

  void _pickDefaultBox() {
    final boxes = _overview?.boxes ?? const <ProgressBoxRow>[];
    for (var n = 1; n <= 5; n++) {
      ProgressBoxRow? row;
      for (final b in boxes) {
        if (b.box == n) {
          row = b;
          break;
        }
      }
      if (row != null && row.count > 0) {
        _selectedBoxNumber = n;
        return;
      }
    }
    _selectedBoxNumber = 1;
  }

  Future<void> shiftWeek(int deltaWeeks) async {
    if (_weekStartLocal == null) {
      return;
    }
    final anchor = DateTime(
      _weekStartLocal!.year,
      _weekStartLocal!.month,
      _weekStartLocal!.day,
    ).add(Duration(days: deltaWeeks * 7));
    await _fetchWeeklyForStart(anchor);
  }

  Future<void> _fetchWeeklyForStart(DateTime start) async {
    final sunday = startOfProgressWeekSunday(start);
    final end = sunday.add(const Duration(days: 6));
    _isWeeklyLoading = true;
    _weeklyError = null;
    _weekStartLocal = sunday;
    notifyListeners();
    try {
      final raw = await _service.fetchWeekly(
        startDate: formatApiDate(sunday),
        endDate: formatApiDate(end),
      );
      _weeklyBundle = weeklyBundleForSundayWeek(raw, sunday);
    } catch (e) {
      _weeklyError = e.toString();
    } finally {
      _isWeeklyLoading = false;
      notifyListeners();
    }
  }

  Future<void> shiftModalitiesMonth(int monthDelta) async {
    final next = DateTime(
      _modalitiesChartMonth.year,
      _modalitiesChartMonth.month + monthDelta,
      1,
    );
    _modalitiesChartMonth = next;
    _selectedModalityId = null;
    await _reloadModalities();
  }

  Future<void> shiftThemesMonth(int monthDelta) async {
    final next = DateTime(
      _themesChartMonth.year,
      _themesChartMonth.month + monthDelta,
      1,
    );
    _themesChartMonth = next;
    _selectedThemeId = null;
    await _reloadThemes();
  }

  Future<void> setModalityFilter(int? modalityId) async {
    if (_selectedModalityId == modalityId) {
      return;
    }
    _selectedModalityId = modalityId;
    await _reloadModalities();
    notifyListeners();
  }

  Future<void> setThemeFilter(String? themeId) async {
    if (_selectedThemeId == themeId) {
      return;
    }
    _selectedThemeId = themeId;
    await _reloadThemes();
    notifyListeners();
  }

  DateTime _firstDayOfModalitiesMonth() =>
      DateTime(_modalitiesChartMonth.year, _modalitiesChartMonth.month, 1);

  DateTime _lastDayOfModalitiesMonth() =>
      DateTime(_modalitiesChartMonth.year, _modalitiesChartMonth.month + 1, 0);

  DateTime _firstDayOfThemesMonth() =>
      DateTime(_themesChartMonth.year, _themesChartMonth.month, 1);

  DateTime _lastDayOfThemesMonth() =>
      DateTime(_themesChartMonth.year, _themesChartMonth.month + 1, 0);

  Future<void> _reloadModalities() async {
    _isModalitiesLoading = true;
    _modalitiesError = null;
    notifyListeners();
    try {
      final response = await _service.fetchModalities(
        startDate: formatApiDate(_firstDayOfModalitiesMonth()),
        endDate: formatApiDate(_lastDayOfModalitiesMonth()),
        modalityId: _selectedModalityId,
      );
      _modalities = response;
      if (response.isGeneral) {
        _rebuildModalityOptions(response);
      }
    } catch (e) {
      _modalitiesError = e.toString();
    } finally {
      _isModalitiesLoading = false;
      notifyListeners();
    }
  }

  Future<void> _reloadThemes() async {
    _isThemesLoading = true;
    _themesError = null;
    notifyListeners();
    try {
      final response = await _service.fetchThemes(
        startDate: formatApiDate(_firstDayOfThemesMonth()),
        endDate: formatApiDate(_lastDayOfThemesMonth()),
        themeId: _selectedThemeId,
      );
      _themes = response;
      if (response.isGeneral) {
        _rebuildThemeOptions(response);
      }
    } catch (e) {
      _themesError = e.toString();
    } finally {
      _isThemesLoading = false;
      notifyListeners();
    }
  }

  void _rebuildModalityOptions(ModalitiesResponse response) {
    final map = <int, String>{};
    for (final row in response.generalRows) {
      for (final m in row.modalities) {
        map[m.modalityId] = m.name;
      }
    }
    final sortedKeys = map.keys.toList()..sort();
    _modalityOptions = sortedKeys
        .map(
          (id) => ModalityOption(
            id: id,
            label: _humanizeModalityName(map[id] ?? ''),
          ),
        )
        .toList();
  }

  void _rebuildThemeOptions(ThemesResponse response) {
    final map = <String, String>{};
    for (final row in response.generalRows) {
      for (final t in row.themes) {
        map[t.themeId] = t.name;
      }
    }
    final sortedKeys = map.keys.toList()..sort();
    _themeOptions = sortedKeys
        .map(
          (id) => ThemeOption(
            id: id,
            label: map[id] ?? '',
          ),
        )
        .toList();
  }

  String _humanizeModalityName(String raw) {
    if (raw.isEmpty) {
      return raw;
    }
    return raw.replaceAll('_', ' ');
  }
}
