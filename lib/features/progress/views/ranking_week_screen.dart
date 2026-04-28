import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/progress/data/progress_service.dart';
import 'package:plus_vocab/features/progress/models/ranking_week_models.dart';
import 'package:provider/provider.dart';

/// Próxima segunda-feira 00:00:00 local (início da nova semana após o domingo).
DateTime _nextRankingWeekResetLocal(DateTime now) {
  final todayStart = DateTime(now.year, now.month, now.day);
  late int daysToAdd;
  switch (now.weekday) {
    case DateTime.monday:
      daysToAdd = now.difference(todayStart) > Duration.zero ? 7 : 0;
      break;
    case DateTime.tuesday:
      daysToAdd = 6;
      break;
    case DateTime.wednesday:
      daysToAdd = 5;
      break;
    case DateTime.thursday:
      daysToAdd = 4;
      break;
    case DateTime.friday:
      daysToAdd = 3;
      break;
    case DateTime.saturday:
      daysToAdd = 2;
      break;
    case DateTime.sunday:
      daysToAdd = 1;
      break;
    default:
      daysToAdd = 1;
  }
  return todayStart.add(Duration(days: daysToAdd));
}

class _RankingPageHeader extends StatelessWidget {
  const _RankingPageHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.emoji_events_outlined, color: AppColors.primaria, size: 36),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ranking da semana',
                style: GoogleFonts.lexend(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textoAzul,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Quem mais praticou nesta semana',
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textoSecundario,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RankingWeekScreen extends StatefulWidget {
  const RankingWeekScreen({super.key});

  @override
  State<RankingWeekScreen> createState() => _RankingWeekScreenState();
}

class _RankingWeekScreenState extends State<RankingWeekScreen> {
  RankingWeekResponse? _data;
  Object? _error;
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
      final service = context.read<ProgressService>();
      final data = await service.fetchRankingWeek();
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  RankingWeekEntry? _entryAt(int position) {
    final list = _data?.ranking ?? [];
    for (final e in list) {
      if (e.position == position) return e;
    }
    return null;
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
                  padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: AppColors.textoAzul,
                    ),
                  ),
                ),
                Expanded(
                  child: _loading
                      ? const Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                              child: _RankingPageHeader(),
                            ),
                            Expanded(
                              child: Center(
                                child: SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.primaria,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : _error != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                  child: _RankingPageHeader(),
                                ),
                                Expanded(
                                  child: _ErrorState(message: _error.toString(), onRetry: _load),
                                ),
                              ],
                            )
                          : RefreshIndicator(
                              color: AppColors.primaria,
                              onRefresh: _load,
                              child: _data == null
                                  ? const SizedBox.shrink()
                                  : SingleChildScrollView(
                                      physics: const AlwaysScrollableScrollPhysics(),
                                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          const _RankingPageHeader(),
                                          const SizedBox(height: 12),
                                          _RankingBody(
                                            data: _data!,
                                            entryAt: _entryAt,
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingResetCountdown extends StatefulWidget {
  const _RankingResetCountdown();

  @override
  State<_RankingResetCountdown> createState() => _RankingResetCountdownState();
}

class _RankingResetCountdownState extends State<_RankingResetCountdown> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final target = _nextRankingWeekResetLocal(now);
    var remaining = target.difference(now);
    if (remaining.isNegative) remaining = Duration.zero;

    final days = remaining.inDays;
    final hours = remaining.inHours.remainder(24);
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.branco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bordaCampo),
        boxShadow: [
          BoxShadow(
            color: AppColors.sombraLeve,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 20, color: AppColors.primaria),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Reinício do ranking',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textoAzul,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'O ranking zera toda segunda-feira à meia-noite (após o domingo).',
            style: GoogleFonts.lexend(
              fontSize: 11,
              height: 1.3,
              color: AppColors.textoSecundario,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _CountdownChip(label: 'dias', value: '$days'),
              const SizedBox(width: 8),
              _CountdownChip(label: 'horas', value: _two(hours)),
              const SizedBox(width: 8),
              _CountdownChip(label: 'min', value: _two(minutes)),
              const SizedBox(width: 8),
              _CountdownChip(label: 'seg', value: _two(seconds)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountdownChip extends StatelessWidget {
  const _CountdownChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.fundoClaro,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.bordaCampo),
            ),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.primaria,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textoSecundario,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 48),
        Icon(Icons.cloud_off_rounded, size: 56, color: AppColors.textoSecundario),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textoSecundario, height: 1.4),
        ),
        const SizedBox(height: 20),
        Center(
          child: FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaria,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('Tentar novamente', style: GoogleFonts.lexend(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}

class _RankingBody extends StatelessWidget {
  const _RankingBody({
    required this.data,
    required this.entryAt,
  });

  final RankingWeekResponse data;
  final RankingWeekEntry? Function(int position) entryAt;

  bool _isCurrentUser(RankingWeekEntry e) {
    final u = data.user;
    if (u.position == 0 && u.name.isEmpty) return false;
    return e.position == u.position && e.name == u.name;
  }

  @override
  Widget build(BuildContext context) {
    final user = data.user;
    final hasUser = user.position > 0 || user.name.isNotEmpty;
    final ranking = data.ranking;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _RankingResetCountdown(),
        const SizedBox(height: 20),
        if (ranking.length >= 3) ...[
          _WeekPodium(
            second: entryAt(2),
            first: entryAt(1),
            third: entryAt(3),
            isCurrentUser: _isCurrentUser,
          ),
        ] else if (ranking.isNotEmpty) ...[
          Text(
            'Top desta semana',
            style: GoogleFonts.lexend(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textoAzul,
            ),
          ),
          const SizedBox(height: 10),
          ...ranking.map((e) => _RankingRowTile(entry: e, highlight: _isCurrentUser(e))),
        ] else ...[
          const SizedBox(height: 8),
          _EmptyRanking(),
        ],
        if (ranking.length > 3) ...[
          const SizedBox(height: 20),
          Text(
            'Demais colocados',
            style: GoogleFonts.lexend(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textoAzul,
            ),
          ),
          const SizedBox(height: 10),
          ...ranking.where((e) => e.position > 3).map(
                (e) => _RankingRowTile(entry: e, highlight: _isCurrentUser(e)),
              ),
        ],
        if (hasUser) ...[
          const SizedBox(height: 24),
          _UserPositionCard(user: user),
        ],
      ],
    );
  }
}

class _UserPositionCard extends StatelessWidget {
  const _UserPositionCard({required this.user});

  final RankingWeekEntry user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.branco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bordaCampo),
        boxShadow: [
          BoxShadow(
            color: AppColors.sombraLeve,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sua posição',
            style: GoogleFonts.lexend(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textoAzul,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.fundoClaro,
                  border: Border.all(color: AppColors.primaria, width: 2),
                ),
                child: Center(
                  child: Text(
                    '${user.position}',
                    style: GoogleFonts.lexend(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaria,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name.isEmpty ? 'Você' : user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lexend(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textoAzul,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${user.totalPracticesWeek} prática${user.totalPracticesWeek == 1 ? '' : 's'} nesta semana',
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textoSecundario,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekPodium extends StatelessWidget {
  const _WeekPodium({
    required this.second,
    required this.first,
    required this.third,
    required this.isCurrentUser,
  });

  final RankingWeekEntry? second;
  final RankingWeekEntry? first;
  final RankingWeekEntry? third;
  final bool Function(RankingWeekEntry e) isCurrentUser;

  static Color _accentForRank(int rank) {
    switch (rank) {
      case 1:
        return AppColors.primaria;
      case 2:
        return AppColors.primaria.withValues(alpha: 0.55);
      default:
        return AppColors.primaria.withValues(alpha: 0.35);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Pódio da semana',
          textAlign: TextAlign.center,
          style: GoogleFonts.lexend(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textoAzul,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _PodiumPlace(
                  entry: second,
                  rank: 2,
                  accent: _accentForRank(2),
                  maxHeight: 120,
                  isCurrentUser: isCurrentUser,
                ),
              ),
              Expanded(
                flex: 11,
                child: _PodiumPlace(
                  entry: first,
                  rank: 1,
                  accent: _accentForRank(1),
                  maxHeight: 150,
                  isCurrentUser: isCurrentUser,
                ),
              ),
              Expanded(
                child: _PodiumPlace(
                  entry: third,
                  rank: 3,
                  accent: _accentForRank(3),
                  maxHeight: 100,
                  isCurrentUser: isCurrentUser,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 12,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            color: AppColors.primaria.withValues(alpha: 0.2),
            border: Border.all(color: AppColors.bordaCampo),
          ),
        ),
      ],
    );
  }
}

class _PodiumPlace extends StatelessWidget {
  const _PodiumPlace({
    required this.entry,
    required this.rank,
    required this.accent,
    required this.maxHeight,
    required this.isCurrentUser,
  });

  final RankingWeekEntry? entry;
  final int rank;
  final Color accent;
  final double maxHeight;
  final bool Function(RankingWeekEntry e) isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final name = entry?.name ?? '—';
    final practices = entry?.totalPracticesWeek ?? 0;
    final e = entry;
    final highlight = e != null && isCurrentUser(e);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(
            rank == 1 ? Icons.emoji_events_outlined : Icons.military_tech_outlined,
            color: AppColors.primaria,
            size: rank == 1 ? 32 : 24,
          ),
          const SizedBox(height: 6),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: rank == 1 ? 13 : 12,
              fontWeight: FontWeight.w700,
              color: highlight ? AppColors.primaria : AppColors.textoAzul,
            ),
          ),
          Text(
            '$practices prát.',
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(fontSize: 10, color: AppColors.textoSecundario),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            height: maxHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  accent.withValues(alpha: 0.25),
                  accent.withValues(alpha: 0.75),
                ],
              ),
              border: Border.all(
                color: highlight ? AppColors.primaria : AppColors.bordaCampo,
                width: highlight ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: GoogleFonts.lexend(
                  fontSize: rank == 1 ? 40 : 30,
                  fontWeight: FontWeight.w900,
                  color: AppColors.branco,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingRowTile extends StatelessWidget {
  const _RankingRowTile({required this.entry, required this.highlight});

  final RankingWeekEntry entry;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: highlight ? AppColors.primaria.withValues(alpha: 0.08) : AppColors.branco,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: highlight ? AppColors.primaria.withValues(alpha: 0.45) : AppColors.bordaCampo,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '${entry.position}',
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: highlight ? AppColors.primaria : AppColors.textoAzul,
                ),
              ),
            ),
            Expanded(
              child: Text(
                entry.name.isEmpty ? '—' : entry.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lexend(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textoAzul,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.fundoClaro,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${entry.totalPracticesWeek}',
                style: GoogleFonts.lexend(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaria,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRanking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.hourglass_empty_rounded, size: 52, color: AppColors.textoSecundario),
        const SizedBox(height: 12),
        Text(
          'Ainda não há dados de ranking esta semana.',
          textAlign: TextAlign.center,
          style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textoSecundario, height: 1.4),
        ),
      ],
    );
  }
}
