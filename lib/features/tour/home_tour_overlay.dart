import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';

class TourStep {
  final GlobalKey? targetKey;
  final String title;
  final String body;
  final String? ctaLabel;

  const TourStep({
    this.targetKey,
    required this.title,
    required this.body,
    this.ctaLabel,
  });
}

class HomeTourOverlay extends StatelessWidget {
  const HomeTourOverlay({
    super.key,
    required this.step,
    required this.spotlightRect,
    required this.stepIndex,
    required this.totalSteps,
    required this.onNext,
    required this.onSkip,
    this.onBack,
    this.onCta,
  });

  final TourStep step;
  final Rect? spotlightRect;
  final int stepIndex;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback? onBack;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;
    final cardAtTop = spotlightRect != null &&
        spotlightRect!.center.dy > screenHeight * 0.52;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Overlay escuro com furo no destaque
        CustomPaint(
          painter: _SpotlightPainter(targetRect: spotlightRect),
          child: const SizedBox.expand(),
        ),
        // Toque em qualquer lugar avança
        GestureDetector(
          onTap: onNext,
          behavior: HitTestBehavior.translucent,
          child: const SizedBox.expand(),
        ),
        // Botão Pular
        Positioned(
          top: topPadding + 12,
          right: 16,
          child: TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Pular',
              style: GoogleFonts.lexend(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        // Card informativo
        Positioned(
          left: 16,
          right: 16,
          top: cardAtTop ? topPadding + 64 : null,
          bottom: cardAtTop ? null : 36,
          child: Material(
            color: Colors.transparent,
            child: _TourCard(
              step: step,
              stepIndex: stepIndex,
              totalSteps: totalSteps,
              onNext: onNext,
              onBack: onBack,
              onCta: onCta,
            ),
          ),
        ),
      ],
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  const _SpotlightPainter({this.targetRect});

  final Rect? targetRect;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.72);
    if (targetRect == null) {
      canvas.drawRect(Offset.zero & size, paint);
      return;
    }
    final expanded = targetRect!.inflate(8);
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path()
          ..addRRect(
            RRect.fromRectAndRadius(expanded, const Radius.circular(12)),
          ),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter old) =>
      old.targetRect != targetRect;
}

class _TourCard extends StatelessWidget {
  const _TourCard({
    required this.step,
    required this.stepIndex,
    required this.totalSteps,
    required this.onNext,
    this.onBack,
    this.onCta,
  });

  final TourStep step;
  final int stepIndex;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    final isLast = stepIndex == totalSteps - 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicador de passos
          Row(
            children: List.generate(
              totalSteps,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(right: 4),
                width: i == stepIndex ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == stepIndex
                      ? AppColors.primaria
                      : AppColors.primaria.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            step.title,
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textoAzul,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            step.body,
            style: GoogleFonts.lexend(
              fontSize: 13,
              height: 1.4,
              color: AppColors.textoSecundario,
            ),
          ),
          const SizedBox(height: 16),
          if (isLast && onCta != null) ...[
            SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton(
                onPressed: onCta,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaria,
                  foregroundColor: AppColors.branco,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  step.ctaLabel ?? 'Criar tema',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                if (onBack != null)
                  TextButton.icon(
                    onPressed: onBack,
                    icon: const Icon(Icons.chevron_left, size: 18),
                    label: Text(
                      'Voltar',
                      style: GoogleFonts.lexend(fontSize: 13),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textoSecundario,
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: onNext,
                  child: Text(
                    'Agora não',
                    style: GoogleFonts.lexend(
                      fontSize: 13,
                      color: AppColors.textoSecundario,
                    ),
                  ),
                ),
              ],
            ),
          ] else
            Row(
              children: [
                if (onBack != null)
                  TextButton.icon(
                    onPressed: onBack,
                    icon: const Icon(Icons.chevron_left, size: 18),
                    label: Text(
                      'Voltar',
                      style: GoogleFonts.lexend(fontSize: 13),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textoSecundario,
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: onNext,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaria,
                    foregroundColor: AppColors.branco,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Próximo',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
