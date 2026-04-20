import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';

class ExerciseModalityLabel extends StatelessWidget {
  const ExerciseModalityLabel({
    super.key,
    required this.label,
    required this.onInfoTap,
  });

  final String label;
  final VoidCallback onInfoTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textoSuave,
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onInfoTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.info_outline,
                size: 20,
                color: AppColors.textoSuave,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
