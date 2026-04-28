String formatPtDecimal(double value, {int fractionDigits = 1}) {
  return value.toStringAsFixed(fractionDigits).replaceAll('.', ',');
}

DateTime parseProgressApiDate(String raw) {
  final parts = raw.split('-');
  if (parts.length != 3) {
    return DateTime.now();
  }
  return DateTime(
    int.tryParse(parts[0]) ?? DateTime.now().year,
    int.tryParse(parts[1]) ?? 1,
    int.tryParse(parts[2]) ?? 1,
  );
}

String formatPtWeekRange(DateTime start, DateTime end) {
  const months = [
    'jan.',
    'fev.',
    'mar.',
    'abr.',
    'mai.',
    'jun.',
    'jul.',
    'ago.',
    'set.',
    'out.',
    'nov.',
    'dez.',
  ];
  String piece(DateTime d) => '${d.day} de ${months[d.month - 1]}';
  if (start.year == end.year) {
    if (start.month == end.month) {
      return '${start.day} – ${end.day} de ${months[end.month - 1]} de ${end.year}';
    }
    return '${piece(start)} – ${piece(end)} de ${end.year}';
  }
  return '${piece(start)} de ${start.year} – ${piece(end)} de ${end.year}';
}

String formatPtMonthYear(DateTime month) {
  const names = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];
  return '${names[month.month - 1]} de ${month.year}';
}

String weekdayShortPt(DateTime d) {
  const abbr = ['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'];
  return abbr[d.weekday - DateTime.monday];
}
