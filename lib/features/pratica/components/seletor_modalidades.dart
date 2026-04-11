import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';

class SelectionListGroup extends StatelessWidget {
  final List<String> options;
  final List<String> selectedOptions;
  final Function(String) onOptionToggled;

  const SelectionListGroup({
    super.key,
    required this.options,
    required this.selectedOptions,
    required this.onOptionToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((option) {
        final isSelected = selectedOptions.contains(option);
        return GestureDetector(
          onTap: () => onOptionToggled(option),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Container(
                  width: 16, height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primaria : AppColors.fundoClaro,
                    border: Border.all(color: AppColors.primaria, width: 1),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  option,
                  style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textoPreto),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}