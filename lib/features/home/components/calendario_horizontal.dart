import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';

class HorizontalCalendar extends StatelessWidget {
  const HorizontalCalendar({
    super.key,
    required this.activeDaysWeek,
  });

  /// Chaves em minúsculas como retornadas pela API (`seg`, `ter`, …, `dom`).
  final Set<String> activeDaysWeek;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Semana exibida de domingo a sábado (alinhada ao calendário comum no Brasil).
  static DateTime _startOfWeekSunday(DateTime now) {
    final today = _dateOnly(now);
    final daysFromSunday = today.weekday % 7;
    return today.subtract(Duration(days: daysFromSunday));
  }

  static String _apiWeekdayKey(DateTime d) {
    switch (d.weekday) {
      case DateTime.monday:
        return 'seg';
      case DateTime.tuesday:
        return 'ter';
      case DateTime.wednesday:
        return 'qua';
      case DateTime.thursday:
        return 'qui';
      case DateTime.friday:
        return 'sex';
      case DateTime.saturday:
        return 'sab';
      case DateTime.sunday:
        return 'dom';
      default:
        return '';
    }
  }

  static String _labelPt(DateTime d) {
    switch (d.weekday) {
      case DateTime.monday:
        return 'seg';
      case DateTime.tuesday:
        return 'ter';
      case DateTime.wednesday:
        return 'qua';
      case DateTime.thursday:
        return 'qui';
      case DateTime.friday:
        return 'sex';
      case DateTime.saturday:
        return 'sáb';
      case DateTime.sunday:
        return 'dom';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = _dateOnly(now);
    final start = _startOfWeekSunday(now);
    final normalizedActive = activeDaysWeek.map((e) {
      final s = e.toLowerCase().trim();
      if (s == 'sáb') return 'sab';
      return s;
    }).toSet();

    final days = List.generate(7, (index) => start.add(Duration(days: index)));

    return SizedBox(
      height: 86,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: days.map((day) {
          final key = _apiWeekdayKey(day);
          final isToday = _dateOnly(day) == today;
          final isActive = normalizedActive.contains(key);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _labelPt(day),
                  style: GoogleFonts.lexend(
                    color: isToday ? AppColors.primaria : AppColors.textoPreto,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? AppColors.primaria : AppColors.bordaCampo,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.w600,
                      color: isActive ? AppColors.branco : AppColors.textoPreto,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
