import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/progress/controllers/progress_screen_controller.dart';
import 'package:plus_vocab/features/progress/progress_chart_palette.dart';
import 'package:plus_vocab/features/progress/models/progress_overview_models.dart';
import 'package:plus_vocab/features/progress/models/progress_themes_models.dart';
import 'package:plus_vocab/features/progress/views/practice_history_screen.dart';
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
      resizeToAvoidBottomInset: false,
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
                              _MetricsCarousel(summary: overview.summary),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          const PracticeHistoryScreen(),
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Visualizar histórico →',
                                    style: GoogleFonts.lexend(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaria,
                                    ),
                                  ),
                                ),
                              ),
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

class _MetricsCarousel extends StatefulWidget {
  const _MetricsCarousel({required this.summary});

  final ProgressSummary summary;

  @override
  State<_MetricsCarousel> createState() => _MetricsCarouselState();
}

class _MetricsCarouselState extends State<_MetricsCarousel> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.summary;
    final accPct = (s.accuracy * 100).round();

    final pages = [
      _MetricPairCard(
        leftValue: '${s.activeDays}',
        leftLabel: 'dias ativos',
        rightValue: '${s.userStreak}',
        rightLabel: 'dias seguidos',
      ),
      _MetricPairCard(
        leftValue: '${s.totalPractices}',
        leftLabel: 'práticas',
        rightValue: '$accPct%',
        rightLabel: 'acerto médio geral',
      ),
      _MetricPairCard(
        leftValue: '${s.wordsMastered}',
        leftLabel: 'palavras dominadas',
        rightValue: '${s.wordsSeen}',
        rightLabel: 'palavras vistas',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Métricas gerais',
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textoAzul,
              ),
            ),
            Row(
              children: List.generate(
                pages.length,
                (i) => _DotIndicator(active: i == _currentPage),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: PageView.builder(
            controller: _pageController,
            itemCount: pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: pages[i],
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricPairCard extends StatelessWidget {
  const _MetricPairCard({
    required this.leftValue,
    required this.leftLabel,
    required this.rightValue,
    required this.rightLabel,
  });

  final String leftValue;
  final String leftLabel;
  final String rightValue;
  final String rightLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
      child: Row(
        children: [
          Expanded(child: _MetricCell(value: leftValue, label: leftLabel)),
          VerticalDivider(
            width: 21,
            thickness: 1,
            color: AppColors.linhaDivisoria,
            indent: 4,
            endIndent: 4,
          ),
          Expanded(child: _MetricCell(value: rightValue, label: rightLabel)),
        ],
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: GoogleFonts.lexend(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: AppColors.primaria,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _metricLabelBlue,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(left: 4),
      width: active ? 12 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active ? AppColors.primaria : AppColors.bordaCampo,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _BoxesCard extends StatelessWidget {
  const _BoxesCard({required this.controller});

  final ProgressScreenController controller;

  static const String _caixasHelpBody =
      'O PlusVocab usa caixas de 1 a 5 para acompanhar o domínio de cada palavra ao longo das práticas. '
      'Conforme você acerta e revisita o vocabulário, a palavra avança de caixa. '
      'Clique em uma caixa para ver as palavras que estão nela.';

  void _showCaixasHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'O que são as caixas?',
          style: GoogleFonts.lexend(fontWeight: FontWeight.w700, color: AppColors.textoAzul),
        ),
        content: Text(
          _caixasHelpBody,
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
    return _CardShell(
      title: 'Caixas',
      titleTrailing: IconButton(
        onPressed: () => _showCaixasHelp(context),
        icon: const Icon(Icons.help_outline_rounded, color: AppColors.textoAzul, size: 20),
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.only(left: 2),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        tooltip: 'Sobre as caixas',
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildBoxTiles(boxes),
          const SizedBox(height: 16),
          Text(
            '${controller.selectedBoxRow?.count ?? 0} palavra(s) na Caixa ${controller.selectedBoxNumber}',
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

  Widget _buildBoxTiles(List<ProgressBoxRow> boxes) {
    return Row(
      children: List.generate(5, (i) {
        final n = i + 1;
        ProgressBoxRow? row;
        for (final b in boxes) {
          if (b.box == n) {
            row = b;
            break;
          }
        }
        final count = row?.count ?? 0;
        final color = ProgressChartPalette.at(i);
        final isSelected = controller.selectedBoxNumber == n;
        return Expanded(
          child: GestureDetector(
            onTap: () => controller.selectedBoxNumber = n,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: i < 4 ? const EdgeInsets.only(right: 6) : EdgeInsets.zero,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
              decoration: BoxDecoration(
                color: isSelected ? color.withValues(alpha: 0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? color : AppColors.bordaCampo,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Caixa $n',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : AppColors.textoSecundario,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$count',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? color : AppColors.textoAzul,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _WordsByLevelColumns extends StatelessWidget {
  const _WordsByLevelColumns({required this.words});

  final List<String> words;

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return Text(
        'Nenhuma palavra nesta caixa.',
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

ThemesResponse _filterThemesResponse(ThemesResponse response, Set<String> visibleIds) {
  if (!response.isGeneral || visibleIds.isEmpty) return response;
  final filtered = response.generalRows.map((row) {
    return ThemesGeneralRow(
      period: row.period,
      themes: row.themes.where((t) => visibleIds.contains(t.themeId)).toList(),
    );
  }).toList();
  return ThemesResponse(
    accuracy: response.accuracy,
    isGeneral: true,
    generalRows: filtered,
    simpleRows: const [],
  );
}

class _ThemesCard extends StatelessWidget {
  const _ThemesCard({required this.controller});

  final ProgressScreenController controller;

  @override
  Widget build(BuildContext context) {
    final monthLabel = formatPtMonthYear(controller.themesChartMonth);
    final themes = controller.themes;
    final acc = themes == null ? 0 : (themes.accuracy * 100).round();
    final visibleIds = controller.visibleThemeIds;

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
          if (controller.themeOptions.isNotEmpty) ...[
            const SizedBox(height: 4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: controller.themeOptions.map((o) {
                  final selected = visibleIds.contains(o.id);
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text(o.label),
                      selected: selected,
                      onSelected: (_) => controller.toggleThemeVisibility(o.id),
                      selectedColor: AppColors.primaria.withValues(alpha: 0.12),
                      checkmarkColor: AppColors.primaria,
                      labelStyle: GoogleFonts.lexend(
                        fontSize: 12,
                        color: selected ? AppColors.primaria : AppColors.textoPreto,
                      ),
                      side: BorderSide(
                        color: selected ? AppColors.primaria : AppColors.bordaCampo,
                      ),
                      backgroundColor: AppColors.branco,
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          const SizedBox(height: 12),
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
            ProgressBarCharts.themesChart(
              response: _filterThemesResponse(themes, visibleIds),
              height: 220,
            ),
        ],
      ),
    );
  }
}
