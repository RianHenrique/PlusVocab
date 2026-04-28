import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/progress/controllers/progress_screen_controller.dart';
import 'package:plus_vocab/features/progress/progress_chart_palette.dart';
import 'package:plus_vocab/features/progress/models/progress_overview_models.dart';
import 'package:plus_vocab/features/progress/views/progress_formatters.dart';
import 'package:plus_vocab/features/progress/widgets/progress_bar_charts.dart';
import 'package:provider/provider.dart';

const Color _metricLabelBlue = Color(0xFF3B82F6);

TextStyle _progressSectionLabelStyle() => GoogleFonts.lexend(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textoAzul,
    );

class MyProgressScreen extends StatelessWidget {
  const MyProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundoClaro,
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.25),
            ),
          ),
          SafeArea(
            child: Consumer<ProgressScreenController>(
              builder: (context, controller, _) {
                if (controller.isInitialLoading && controller.overview == null) {
                  return const Center(
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaria,
                      ),
                    ),
                  );
                }
                if (controller.initialError != null && controller.overview == null) {
                  return _InitialError(
                    message: controller.initialError!,
                    onRetry: () => controller.loadInitial(),
                  );
                }
                final overview = controller.overview;
                if (overview == null) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _ProgressBackBar(),
                    Expanded(
                      child: RefreshIndicator(
                        color: AppColors.primaria,
                        onRefresh: () => controller.loadInitial(),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Seu Progresso',
                                style: GoogleFonts.lexend(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textoAzul,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _GeneralMetricsCard(summary: overview.summary),
                              const SizedBox(height: 18),
                              _WeeklyCard(controller: controller),
                              const SizedBox(height: 18),
                              _ModalitiesCard(controller: controller),
                              const SizedBox(height: 18),
                              _ThemesCard(controller: controller),
                              const SizedBox(height: 18),
                              _BoxesCard(controller: controller),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBackBar extends StatelessWidget {
  const _ProgressBackBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.chevron_left_rounded, color: AppColors.textoAzul, size: 32),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
      ),
    );
  }
}

class _InitialError extends StatelessWidget {
  const _InitialError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textoSecundario),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(backgroundColor: AppColors.primaria),
              child: Text('Tentar novamente', style: GoogleFonts.lexend(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({
    required this.title,
    required this.child,
    this.titleTrailing,
    this.contentPadding = const EdgeInsets.all(16),
  });

  final String title;
  final Widget child;
  final Widget? titleTrailing;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textoAzul,
              ),
            ),
            if (titleTrailing != null) titleTrailing!,
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: contentPadding,
          decoration: BoxDecoration(
            color: AppColors.branco,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.bordaCampo),
            boxShadow: [
              BoxShadow(
                color: AppColors.sombraCard,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }
}

class _GeneralMetricsCard extends StatelessWidget {
  const _GeneralMetricsCard({required this.summary});

  final ProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    final accPct = (summary.accuracy * 100).round();
    return _CardShell(
      title: 'Métricas gerais',
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${summary.activeDays}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaria,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'dias ativos',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _metricLabelBlue,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${summary.totalPractices}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaria,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'práticas',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _metricLabelBlue,
                    ),
                  ),
                ],
              ),
            ),
            VerticalDivider(
              width: 21,
              thickness: 1,
              color: AppColors.linhaDivisoria,
              indent: 4,
              endIndent: 4,
            ),
            Expanded(
              flex: 13,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        '$accPct%',
                        style: GoogleFonts.lexend(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaria,
                        ),
                      ),
                      Text(
                        'acerto médio geral',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _metricLabelBlue,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${summary.wordsMastered}',
                        style: GoogleFonts.lexend(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaria,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'palavras dominadas',
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _metricLabelBlue,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${summary.wordsSeen}',
                        style: GoogleFonts.lexend(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaria,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'palavras vistas',
                          style: GoogleFonts.lexend(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _metricLabelBlue,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoxesCard extends StatelessWidget {
  const _BoxesCard({required this.controller});

  final ProgressScreenController controller;

  static const String _niveisHelpBody =
      'O PlusVocab usa níveis de 1 a 5 para acompanhar o domínio de cada palavra ao longo das práticas. '
      'Conforme você acerta e revisita o vocabulário, a palavra avança de nível. '
      'Este gráfico mostra quantas palavras estão em cada nível; use o menu para listar as palavras de um nível específico.';

  void _showNiveisHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'O que são os níveis?',
          style: GoogleFonts.lexend(fontWeight: FontWeight.w700, color: AppColors.textoAzul),
        ),
        content: Text(
          _niveisHelpBody,
          style: GoogleFonts.lexend(fontSize: 14, height: 1.35, color: AppColors.textoPreto),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Entendi', style: GoogleFonts.lexend(fontWeight: FontWeight.w600, color: AppColors.primaria)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final boxes = controller.overview?.boxes ?? const <ProgressBoxRow>[];
    final totalWords = boxes.fold<int>(0, (a, b) => a + b.count);
    return _CardShell(
      title: 'Níveis',
      titleTrailing: IconButton(
        onPressed: () => _showNiveisHelp(context),
        icon: const Icon(Icons.help_outline_rounded, color: AppColors.textoAzul, size: 20),
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.only(left: 2),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        tooltip: 'Sobre os níveis',
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10,),
          Center(
            child: SizedBox(
              width: 160,
              height: 160,
              child: totalWords == 0
                  ? Center(
                      child: Text(
                        'Sem dados',
                        style: GoogleFonts.lexend(fontSize: 13, color: AppColors.textoSecundario),
                      ),
                    )
                  : PieChart(
                      PieChartData(
                        sectionsSpace: 1,
                        centerSpaceRadius: 38,
                        sections: _pieSections(boxes),
                      ),
                    ),
            ),
          ),
          if (totalWords > 0) ...[
            const SizedBox(height: 20),
            ProgressBarCharts.coloredLegendStrip(items: _pieLegendEntries(boxes)),
          ],
          const SizedBox(height: 18),
          DropdownButtonFormField<int>(
            value: controller.selectedBoxNumber,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.bordaCampo),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.bordaCampo),
              ),
            ),
            items: List.generate(5, (i) {
              final n = i + 1;
              return DropdownMenuItem(
                value: n,
                child: Text(
                  'Nível $n',
                  style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textoPreto),
                ),
              );
            }),
            onChanged: (v) {
              if (v != null) {
                controller.selectedBoxNumber = v;
              }
            },
          ),
          const SizedBox(height: 10),
          Text(
            '${controller.selectedBoxRow?.count ?? 0} palavra(s)',
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaria,
            ),
          ),
          const SizedBox(height: 8),
          _WordsByLevelColumns(words: controller.selectedBoxRow?.words ?? const []),
        ],
      ),
    );
  }

  List<({String label, Color color})> _pieLegendEntries(List<ProgressBoxRow> boxes) {
    final withData = boxes.where((b) => b.count > 0).toList()
      ..sort((a, b) => a.box.compareTo(b.box));
    return withData
        .map((b) {
          final idx = (b.box - 1).clamp(0, 4).toInt();
          return (
            label: 'Nível ${b.box} (${b.count})',
            color: ProgressChartPalette.at(idx),
          );
        })
        .toList();
  }

  List<PieChartSectionData> _pieSections(List<ProgressBoxRow> boxes) {
    final withData = boxes.where((b) => b.count > 0).toList();
    if (withData.isEmpty) {
      return const [];
    }
    return withData.map((b) {
      final idx = (b.box - 1).clamp(0, 4).toInt();
      final color = ProgressChartPalette.at(idx);
      return PieChartSectionData(
        color: color,
        value: b.count.toDouble(),
        showTitle: false,
        radius: 52,
      );
    }).toList();
  }

}

class _WordsByLevelColumns extends StatelessWidget {
  const _WordsByLevelColumns({required this.words});

  final List<String> words;

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return Text(
        'Nenhuma palavra neste nível.',
        style: GoogleFonts.lexend(fontSize: 13, color: AppColors.textoSecundario),
      );
    }
    final mid = (words.length + 1) ~/ 2;
    final left = words.sublist(0, mid);
    final right = words.sublist(mid);

    Widget columnFor(List<String> slice) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: slice.map((w) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  w,
                  style: GoogleFonts.lexend(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textoAzul,
                  ),
                ),
              ),
              Divider(height: 1, thickness: 1, color: AppColors.linhaDivisoria.withValues(alpha: 0.35)),
            ],
          );
        }).toList(),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: columnFor(left)),
        const SizedBox(width: 16),
        Expanded(child: columnFor(right)),
      ],
    );
  }
}

class _WeeklyCard extends StatelessWidget {
  const _WeeklyCard({required this.controller});

  final ProgressScreenController controller;

  @override
  Widget build(BuildContext context) {
    final start = controller.weekStartLocal;
    final rangeText = start == null
        ? ''
        : formatPtWeekRange(start, start.add(const Duration(days: 6)));
    final accWeekly = controller.weeklyBundle.average;
    final accPct = accWeekly <= 1.0 ? (accWeekly * 100).round() : accWeekly.round();

    final days = controller.weeklyBundle.data;
    double meanPracticesPerDay = 0;
    if (days.isNotEmpty) {
      final sum = days.fold<int>(0, (a, d) => a + d.count);
      meanPracticesPerDay = sum / days.length;
    }
    final practicesAvgText = formatPtDecimal(meanPracticesPerDay, fractionDigits: 1);

    return _CardShell(
      title: 'Semanal',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Acertos na semana: $accPct%',
                style: _progressSectionLabelStyle(),
              ),
              const SizedBox(height: 6),
              Text(
                'Média de práticas por dia: $practicesAvgText',
                style: _progressSectionLabelStyle(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                onPressed: controller.isWeeklyLoading ? null : () => controller.shiftWeek(-1),
                icon: const Icon(Icons.chevron_left_rounded, color: AppColors.primaria),
              ),
              Expanded(
                child: Text(
                  rangeText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textoPreto,
                  ),
                ),
              ),
              IconButton(
                onPressed: controller.isWeeklyLoading ? null : () => controller.shiftWeek(1),
                icon: const Icon(Icons.chevron_right_rounded, color: AppColors.primaria),
              ),
            ],
          ),
          if (controller.weeklyError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                controller.weeklyError!,
                style: GoogleFonts.lexend(fontSize: 12, color: AppColors.erro),
              ),
            ),
          if (controller.isWeeklyLoading)
            const SizedBox(
              height: 180,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaria),
                ),
              ),
            )
          else
            ProgressBarCharts.weeklyPracticesChart(
              days: controller.weeklyBundle.data,
              height: 200,
            ),
        ],
      ),
    );
  }
}

class _ModalitiesCard extends StatelessWidget {
  const _ModalitiesCard({required this.controller});

  final ProgressScreenController controller;

  @override
  Widget build(BuildContext context) {
    final monthLabel = formatPtMonthYear(controller.modalitiesChartMonth);
    final modalities = controller.modalities;
    final acc = modalities == null ? 0 : (modalities.accuracy * 100).round();

    return _CardShell(
      title: 'Modalidades',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: controller.isModalitiesLoading ? null : () => controller.shiftModalitiesMonth(-1),
                icon: const Icon(Icons.chevron_left_rounded, color: AppColors.primaria),
              ),
              Expanded(
                child: Text(
                  monthLabel,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textoAzul,
                  ),
                ),
              ),
              IconButton(
                onPressed: controller.isModalitiesLoading ? null : () => controller.shiftModalitiesMonth(1),
                icon: const Icon(Icons.chevron_right_rounded, color: AppColors.primaria),
              ),
            ],
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<int?>(
            value: controller.selectedModalityId,
            decoration: InputDecoration(
              labelText: 'Filtro',
              labelStyle: GoogleFonts.lexend(fontSize: 12, color: AppColors.textoSecundario),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            items: [
              DropdownMenuItem<int?>(
                value: null,
                child: Text('geral', style: GoogleFonts.lexend(fontSize: 14)),
              ),
              ...controller.modalityOptions.map(
                (o) => DropdownMenuItem<int?>(
                  value: o.id,
                  child: Text(o.label, style: GoogleFonts.lexend(fontSize: 14)),
                ),
              ),
            ],
            onChanged: controller.isModalitiesLoading
                ? null
                : (v) {
                    controller.setModalityFilter(v);
                  },
          ),
          const SizedBox(height: 16),
          if (modalities != null)
            Text(
              'Porcentagem de acertos: $acc%',
              style: _progressSectionLabelStyle(),
            ),
          if (modalities != null) const SizedBox(height: 20),
          if (controller.modalitiesError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                controller.modalitiesError!,
                style: GoogleFonts.lexend(fontSize: 12, color: AppColors.erro),
              ),
            ),
          if (controller.isModalitiesLoading || modalities == null)
            const SizedBox(
              height: 200,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaria),
                ),
              ),
            )
          else
            ProgressBarCharts.modalitiesChart(response: modalities, height: 220),
        ],
      ),
    );
  }
}

class _ThemesCard extends StatelessWidget {
  const _ThemesCard({required this.controller});

  final ProgressScreenController controller;

  @override
  Widget build(BuildContext context) {
    final monthLabel = formatPtMonthYear(controller.themesChartMonth);
    final themes = controller.themes;
    final acc = themes == null ? 0 : (themes.accuracy * 100).round();

    return _CardShell(
      title: 'Temas',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: controller.isThemesLoading ? null : () => controller.shiftThemesMonth(-1),
                icon: const Icon(Icons.chevron_left_rounded, color: AppColors.primaria),
              ),
              Expanded(
                child: Text(
                  monthLabel,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textoAzul,
                  ),
                ),
              ),
              IconButton(
                onPressed: controller.isThemesLoading ? null : () => controller.shiftThemesMonth(1),
                icon: const Icon(Icons.chevron_right_rounded, color: AppColors.primaria),
              ),
            ],
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String?>(
            value: controller.selectedThemeId,
            decoration: InputDecoration(
              labelText: 'Filtro',
              labelStyle: GoogleFonts.lexend(fontSize: 12, color: AppColors.textoSecundario),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text('geral', style: GoogleFonts.lexend(fontSize: 14)),
              ),
              ...controller.themeOptions.map(
                (o) => DropdownMenuItem<String?>(
                  value: o.id,
                  child: Text(
                    o.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lexend(fontSize: 14),
                  ),
                ),
              ),
            ],
            onChanged: controller.isThemesLoading
                ? null
                : (v) {
                    controller.setThemeFilter(v);
                  },
          ),
          const SizedBox(height: 16),
          if (themes != null)
            Text(
              'Porcentagem de acertos: $acc%',
              style: _progressSectionLabelStyle(),
            ),
          if (themes != null) const SizedBox(height: 20),
          if (controller.themesError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                controller.themesError!,
                style: GoogleFonts.lexend(fontSize: 12, color: AppColors.erro),
              ),
            ),
          if (controller.isThemesLoading || themes == null)
            const SizedBox(
              height: 200,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaria),
                ),
              ),
            )
          else
            ProgressBarCharts.themesChart(response: themes, height: 220),
        ],
      ),
    );
  }
}
