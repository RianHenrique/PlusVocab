import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  final Color _blue = const Color(0xFF2563EB);
  final Color _bgLight = const Color(0xFFf3f4f6);

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
                    color: isSelected ? _blue : _bgLight,
                    border: Border.all(color: _blue, width: 1),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  option,
                  style: GoogleFonts.lexend(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}