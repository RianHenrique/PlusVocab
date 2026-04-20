import 'package:flutter/material.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';

class ExerciseProgressDots extends StatelessWidget {
  const ExerciseProgressDots({
    super.key,
    required this.total,
    required this.currentIndex,
  });

  final int total;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    if (total <= 0) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i == currentIndex.clamp(0, total - 1);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? AppColors.primaria : AppColors.bordaCampo.withValues(alpha: 0.6),
            ),
          ),
        );
      }),
    );
  }
}
