import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/progress/models/progress_modalities_models.dart';
import 'package:plus_vocab/features/progress/models/progress_overview_models.dart';
import 'package:plus_vocab/features/progress/models/progress_themes_models.dart';
import 'package:plus_vocab/features/progress/progress_chart_palette.dart';
import 'package:plus_vocab/features/progress/views/progress_formatters.dart';

class ProgressBarCharts {
  static Widget coloredLegendStrip({
    required List<({String label, Color color})> items,
  }) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    final labelStyle = GoogleFonts.lexend(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: AppColors.textoPreto,
    );
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: items.map((e) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: e.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(
                e.label,
                style: labelStyle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  static Widget weeklyPracticesChart({
    required List<ProgressWeeklyDay> days,
    double height = 200,
  }) {
    final sorted = [...days]..sort((a, b) => a.date.compareTo(b.date));
    if (sorted.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'Sem dados nesta semana.',
            style: GoogleFonts.lexend(fontSize: 13, color: AppColors.textoSecundario),
          ),
        ),
      );
    }
    final totalCount = sorted.fold<int>(0, (a, d) => a + d.count);
    final isFullSundayWeek = sorted.length == 7;
    if (totalCount == 0 && !isFullSundayWeek) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'Sem dados nesta semana.',
            style: GoogleFonts.lexend(fontSize: 13, color: AppColors.textoSecundario),
          ),
        ),
      );
    }

    var maxY = 4.0;
    for (final d in sorted) {
      if (d.count.toDouble() > maxY) {
        maxY = d.count.toDouble();
      }
    }
    if (maxY < 4) {
      maxY = 4;
    }

    final groups = <BarChartGroupData>[];
    for (var i = 0; i < sorted.length; i++) {
      final day = sorted[i];
      final y = day.count.toDouble();
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: y,
              color: ProgressChartPalette.blue,
              width: 14,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
    }

    final labelStyle = GoogleFonts.lexend(fontSize: 10, color: AppColors.textoSecundario);

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          minY: 0,
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => ProgressChartPalette.navy,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                if (groupIndex < 0 || groupIndex >= sorted.length) {
                  return null;
                }
                final day = sorted[groupIndex];
                final pct = day.accuracy != null
                    ? ' · ${(day.accuracy! * 100).round()}% acerto'
                    : '';
                return BarTooltipItem(
                  '${day.count} prática(s)$pct',
                  GoogleFonts.lexend(
                    color: AppColors.branco,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: maxY <= 5 ? 1 : (maxY / 4).ceilToDouble(),
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      value.toInt().toString(),
                      style: labelStyle,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 26,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= sorted.length) {
                    return const SizedBox.shrink();
                  }
                  final dt = parseProgressApiDate(sorted[i].date);
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(weekdayShortPt(dt), style: labelStyle),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY <= 5 ? 1 : (maxY / 4).ceilToDouble(),
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.linhaDivisoria.withValues(alpha: 0.35),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: groups,
        ),
        duration: Duration.zero,
      ),
    );
  }

  static Widget modalitiesChart({
    required ModalitiesResponse response,
    required double height,
  }) {
    if (response.isGeneral) {
      return _stackedModalityChart(response, height);
    }
    return _simplePeriodChart(
      rows: response.simpleRows
          .map((e) => (period: e.period, count: e.count))
          .toList(),
      height: height,
    );
  }

  static Widget themesChart({
    required ThemesResponse response,
    required double height,
  }) {
    if (response.isGeneral) {
      return _stackedThemeChart(response, height);
    }
    return _simplePeriodChart(
      rows: response.simpleRows
          .map((e) => (period: e.period, count: e.count))
          .toList(),
      height: height,
    );
  }

  static Widget _stackedModalityChart(ModalitiesResponse response, double height) {
    final rows = [...response.generalRows]..sort((a, b) => a.period.compareTo(b.period));
    if (rows.isEmpty) {
      return _emptyChart(height, 'Sem dados neste mês.');
    }

    final ids = <int>{};
    for (final r in rows) {
      for (final m in r.modalities) {
        ids.add(m.modalityId);
      }
    }
    final orderedIds = ids.toList()..sort();

    var maxY = 1.0;
    final groups = <BarChartGroupData>[];
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final byId = {for (final m in row.modalities) m.modalityId: m.count};
      var acc = 0.0;
      final stacks = <BarChartRodStackItem>[];
      for (var j = 0; j < orderedIds.length; j++) {
        final id = orderedIds[j];
        final c = (byId[id] ?? 0).toDouble();
        if (c <= 0) {
          continue;
        }
        final from = acc;
        acc += c;
        stacks.add(
          BarChartRodStackItem(
            from,
            acc,
            ProgressChartPalette.at(j),
          ),
        );
      }
      if (acc > maxY) {
        maxY = acc;
      }
      final total = acc;
      if (stacks.isEmpty) {
        groups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: 0,
                color: Colors.transparent,
                width: 16,
              ),
            ],
          ),
        );
      } else {
        groups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: total,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                rodStackItems: stacks,
              ),
            ],
          ),
        );
      }
    }

    final idToName = <int, String>{};
    for (final r in rows) {
      for (final m in r.modalities) {
        idToName[m.modalityId] = m.name.replaceAll('_', ' ');
      }
    }
    final legendItems = <({String label, Color color})>[
      for (var j = 0; j < orderedIds.length; j++)
        (
          label: idToName[orderedIds[j]] ?? 'Modalidade',
          color: ProgressChartPalette.at(j),
        ),
    ];

    return _barChartShell(
      height: height,
      maxY: maxY < 4 ? 4.0 : maxY,
      groups: groups,
      bottomLabel: (i) {
        if (i < 0 || i >= rows.length) {
          return '';
        }
        final p = rows[i].period;
        final parts = p.split('-');
        if (parts.length == 3) {
          return '${parts[2]}/${parts[1]}';
        }
        return p;
      },
      tooltipForIndex: (i) {
        if (i < 0 || i >= rows.length) {
          return '';
        }
        final r = rows[i];
        final lines = r.modalities.map((m) {
          final label = m.name.replaceAll('_', ' ');
          return '$label: ${m.count}';
        }).join('\n');
        return '${r.period}\n$lines';
      },
      legendItems: legendItems,
    );
  }

  static Widget _stackedThemeChart(ThemesResponse response, double height) {
    final rows = [...response.generalRows]..sort((a, b) => a.period.compareTo(b.period));
    if (rows.isEmpty) {
      return _emptyChart(height, 'Sem dados neste mês.');
    }

    final ids = <String>{};
    for (final r in rows) {
      for (final t in r.themes) {
        ids.add(t.themeId);
      }
    }
    final orderedIds = ids.toList()..sort();

    var maxY = 1.0;
    final groups = <BarChartGroupData>[];
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final byId = {for (final t in row.themes) t.themeId: t.count};
      var acc = 0.0;
      final stacks = <BarChartRodStackItem>[];
      for (var j = 0; j < orderedIds.length; j++) {
        final id = orderedIds[j];
        final c = (byId[id] ?? 0).toDouble();
        if (c <= 0) {
          continue;
        }
        final from = acc;
        acc += c;
        stacks.add(BarChartRodStackItem(from, acc, ProgressChartPalette.at(j)));
      }
      if (acc > maxY) {
        maxY = acc;
      }
      final total = acc;
      if (stacks.isEmpty) {
        groups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: 0,
                color: Colors.transparent,
                width: 16,
              ),
            ],
          ),
        );
      } else {
        groups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: total,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                rodStackItems: stacks,
              ),
            ],
          ),
        );
      }
    }

    final idToName = <String, String>{};
    for (final r in rows) {
      for (final t in r.themes) {
        idToName[t.themeId] = t.name;
      }
    }
    final legendItems = <({String label, Color color})>[
      for (var j = 0; j < orderedIds.length; j++)
        (
          label: idToName[orderedIds[j]] ?? 'Tema',
          color: ProgressChartPalette.at(j),
        ),
    ];

    return _barChartShell(
      height: height,
      maxY: maxY < 4 ? 4.0 : maxY,
      groups: groups,
      bottomLabel: (i) {
        if (i < 0 || i >= rows.length) {
          return '';
        }
        final p = rows[i].period;
        final parts = p.split('-');
        if (parts.length == 3) {
          return '${parts[2]}/${parts[1]}';
        }
        return p;
      },
      tooltipForIndex: (i) {
        if (i < 0 || i >= rows.length) {
          return '';
        }
        final r = rows[i];
        final lines = r.themes.map((t) => '${t.name}: ${t.count}').join('\n');
        return '${r.period}\n$lines';
      },
      legendItems: legendItems,
    );
  }

  static Widget _simplePeriodChart({
    required List<({String period, int count})> rows,
    required double height,
  }) {
    if (rows.isEmpty) {
      return _emptyChart(height, 'Sem dados neste mês.');
    }
    var maxY = 4.0;
    for (final r in rows) {
      if (r.count.toDouble() > maxY) {
        maxY = r.count.toDouble();
      }
    }
    final groups = <BarChartGroupData>[];
    for (var i = 0; i < rows.length; i++) {
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: rows[i].count.toDouble(),
              color: ProgressChartPalette.blue,
              width: 14,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
    }

    return _barChartShell(
      height: height,
      maxY: maxY,
      groups: groups,
      bottomLabel: (i) {
        if (i < 0 || i >= rows.length) {
          return '';
        }
        final p = rows[i].period;
        final parts = p.split('-');
        if (parts.length == 3) {
          return '${parts[2]}/${parts[1]}';
        }
        return p;
      },
      tooltipForIndex: (i) {
        if (i < 0 || i >= rows.length) {
          return '';
        }
        return '${rows[i].period}\n${rows[i].count} prática(s)';
      },
    );
  }

  static Widget _barChartShell({
    required double height,
    required double maxY,
    required List<BarChartGroupData> groups,
    required String Function(int index) bottomLabel,
    required String Function(int index) tooltipForIndex,
    List<({String label, Color color})>? legendItems,
  }) {
    final labelStyle = GoogleFonts.lexend(fontSize: 10, color: AppColors.textoSecundario);
    final legend = legendItems;
    final hasLegend = legend != null && legend.isNotEmpty;
    const legendReserve = 52.0;
    final chartHeight = hasLegend ? (height - legendReserve).clamp(72.0, height) : height;

    final chart = BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            maxContentWidth: 220,
            getTooltipColor: (_) => ProgressChartPalette.navy,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final text = tooltipForIndex(groupIndex);
              return BarTooltipItem(
                text,
                GoogleFonts.lexend(
                  color: AppColors.branco,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: maxY <= 5 ? 1 : (maxY / 4).ceilToDouble(),
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    value.toInt().toString(),
                    style: labelStyle,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final t = bottomLabel(value.toInt());
                if (t.isEmpty) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(t, style: labelStyle),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY <= 5 ? 1 : (maxY / 4).ceilToDouble(),
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.linhaDivisoria.withValues(alpha: 0.35),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: groups,
      ),
      duration: Duration.zero,
    );

    if (!hasLegend) {
      return SizedBox(
        height: height,
        child: chart,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: chartHeight, child: chart),
        const SizedBox(height: 6),
        coloredLegendStrip(items: legend),
      ],
    );
  }

  static Widget _emptyChart(double height, String message) {
    return SizedBox(
      height: height,
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.lexend(fontSize: 13, color: AppColors.textoSecundario),
        ),
      ),
    );
  }
}
