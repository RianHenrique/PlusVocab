import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';

class HorizontalCalendar extends StatelessWidget {
  const HorizontalCalendar({super.key});

  static const List<Map<String, dynamic>> _daysList = [
    {'label': 'ter', 'day': '27', 'selected': false, 'isCurrent': false},
    {'label': 'qua', 'day': '28', 'selected': true, 'isCurrent': false},
    {'label': 'qui', 'day': '29', 'selected': true, 'isCurrent': true},
    {'label': 'sex', 'day': '30', 'selected': false, 'isCurrent': false},
    {'label': 'sab', 'day': '31', 'selected': false, 'isCurrent': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: _daysList.length,
          itemBuilder: (context, index) {
            final dayInfo = _daysList[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayInfo['label']!,
                    style: GoogleFonts.lexend(
                      color: dayInfo['isCurrent'] ? AppColors.primaria : AppColors.textoPreto,
                      fontWeight: dayInfo['isCurrent'] ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dayInfo['selected'] ? AppColors.primaria : AppColors.bordaCampo,
                    ),
                    alignment: Alignment.center,
                    child: Text(dayInfo['day'], 
                      style: TextStyle(color: dayInfo['selected'] ? AppColors.fundoClaro : AppColors.textoPreto)
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}