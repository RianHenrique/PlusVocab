import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/progress/data/progress_service.dart';
import 'package:plus_vocab/features/progress/models/practice_history_models.dart';
import 'package:provider/provider.dart';

class PracticeHistoryScreen extends StatefulWidget {
  const PracticeHistoryScreen({super.key});

  @override
  State<PracticeHistoryScreen> createState() => _PracticeHistoryScreenState();
}

class _PracticeHistoryScreenState extends State<PracticeHistoryScreen> {
  List<PracticeHistoryEntry>? _entries;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response =
          await context.read<ProgressService>().fetchPracticeHistory();
      if (!mounted) return;
      setState(() {
        _entries = response.practices;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.chevron_left_rounded,
                            color: AppColors.textoAzul, size: 32),
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(minWidth: 40, minHeight: 40),
                      ),
                      Text(
                        'Histórico de práticas',
                        style: GoogleFonts.lexend(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textoAzul,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.primaria),
        ),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                    fontSize: 14, color: AppColors.textoSecundario),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _load,
                style:
                    FilledButton.styleFrom(backgroundColor: AppColors.primaria),
                child: Text('Tentar novamente',
                    style: GoogleFonts.lexend(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      );
    }

    final entries = _entries ?? [];
    if (entries.isEmpty) {
      return Center(
        child: Text(
          'Nenhuma prática registrada ainda.',
          style: GoogleFonts.lexend(
              fontSize: 14, color: AppColors.textoSecundario),
        ),
      );
    }

    final groups = _groupByDate(entries);

    return RefreshIndicator(
      color: AppColors.primaria,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        itemCount: groups.length,
        itemBuilder: (context, i) {
          final group = groups[i];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Text(
                  group.label,
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textoAzul,
                  ),
                ),
              ),
              ...group.entries.map((e) => _PracticeHistoryItem(entry: e)),
            ],
          );
        },
      ),
    );
  }

  List<_DateGroup> _groupByDate(List<PracticeHistoryEntry> entries) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final map = <String, List<PracticeHistoryEntry>>{};
    final keyOrder = <String>[];

    for (final e in entries) {
      final local = e.date.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      final key = day.toIso8601String();
      if (!map.containsKey(key)) {
        map[key] = [];
        keyOrder.add(key);
      }
      map[key]!.add(e);
    }

    return keyOrder.map((k) {
      final dayEntries = map[k]!;
      final local = dayEntries.first.date.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      String label;
      if (day == today) {
        label = 'Hoje';
      } else if (day == yesterday) {
        label = 'Ontem';
      } else {
        label = _formatDayLabel(day);
      }
      return _DateGroup(label: label, entries: dayEntries);
    }).toList();
  }

  String _formatDayLabel(DateTime day) {
    const months = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
    ];
    return 'Dia ${day.day} de ${months[day.month - 1]}';
  }
}

class _DateGroup {
  const _DateGroup({required this.label, required this.entries});

  final String label;
  final List<PracticeHistoryEntry> entries;
}

class _PracticeHistoryItem extends StatelessWidget {
  const _PracticeHistoryItem({required this.entry});

  final PracticeHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final local = entry.date.toLocal();
    final timeStr =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    final accPct = (entry.accuracy * 100).round();
    final accColor = accPct >= 70
        ? AppColors.acerto
        : (accPct >= 40 ? AppColors.secundaria : AppColors.erro);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.theme,
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textoAzul,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeStr,
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    color: AppColors.textoSecundario,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: accColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$accPct%',
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: accColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
