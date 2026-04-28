import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/components/profile_circle.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/auth/controllers/auth_controller.dart';
import 'package:plus_vocab/features/dicionario/controllers/dicionario_controller.dart';
import 'package:plus_vocab/features/dicionario/models/palavra_model.dart';
import 'package:plus_vocab/features/dicionario/views/dicionario_screen.dart';
import 'package:plus_vocab/features/home/components/calendario_horizontal.dart';
import 'package:plus_vocab/features/home/controllers/progress_home_controller.dart';
import 'package:plus_vocab/features/home/models/progress_home.dart';
import 'package:plus_vocab/features/progress/controllers/progress_screen_controller.dart';
import 'package:plus_vocab/features/progress/data/progress_service.dart';
import 'package:plus_vocab/features/progress/views/my_progress_screen.dart';
import 'package:plus_vocab/features/progress/views/ranking_week_screen.dart';
import 'package:plus_vocab/features/pratica/exercicio/views/practice_session_loading_screen.dart';
import 'package:plus_vocab/features/temas/controllers/temas_controller.dart';
import 'package:plus_vocab/features/temas/models/tema_resumo.dart';
import 'package:plus_vocab/features/temas/views/criar_tema_screen.dart';
import 'package:plus_vocab/features/temas/views/temas_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _contextoPraticaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProgressHomeController>().carregar();
      context.read<DicionarioController>().forcarAtualizacao();
      context.read<TemasController>().forcarAtualizacaoListaTemas();
    });
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      context.read<ProgressHomeController>().atualizar(),
      context.read<DicionarioController>().forcarAtualizacao(),
      context.read<TemasController>().forcarAtualizacaoListaTemas(),
    ]);
  }

  void _abrirCriarTemaComContexto() {
    final value = _contextoPraticaController.text.trim();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => CriarTemaScreen(contexto: value),
      ),
    );
  }

  @override
  void dispose() {
    _contextoPraticaController.dispose();
    super.dispose();
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
            child: RefreshIndicator(
              color: AppColors.primaria,
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          'assets/images/PlusVocab2.png',
                          height: 35,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Tooltip(
                              message: 'Ranking da semana',
                              child: IconButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const RankingWeekScreen(),
                                    ),
                                  );
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                                style: IconButton.styleFrom(
                                  foregroundColor: AppColors.primaria,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                icon: const Icon(Icons.emoji_events_outlined, size: 28),
                              ),
                            ),
                            const SizedBox(width: 2),
                            const ProfileCircle(),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Consumer<ProgressHomeController>(
                      builder: (context, progressCtrl, _) {
                        final active = progressCtrl.data?.activeDaysWeek.toSet() ?? {};
                        final showCalendarLoader = progressCtrl.isLoading &&
                            progressCtrl.data == null &&
                            progressCtrl.errorMessage == null;
                        if (showCalendarLoader) {
                          return const SizedBox(
                            height: 84,
                            child: Center(
                              child: SizedBox(
                                width: 26,
                                height: 26,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaria,
                                ),
                              ),
                            ),
                          );
                        }
                        return HorizontalCalendar(activeDaysWeek: active);
                      },
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'O que vamos aprender hoje?',
                        style: GoogleFonts.lexend(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textoAzul,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.branco,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.bordaCampo),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.sombraLeve,
                            blurRadius: 4,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _contextoPraticaController,
                        onSubmitted: (_) => _abrirCriarTemaComContexto(),
                        textInputAction: TextInputAction.done,
                        textAlignVertical: TextAlignVertical.center,
                        maxLines: null,
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          color: AppColors.textoPreto,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Contexto da nova prática',
                          hintStyle: GoogleFonts.lexend(
                            fontSize: 13,
                            color: AppColors.textoSecundario,
                          ),
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                            onPressed: _abrirCriarTemaComContexto,
                            icon: const Icon(Icons.send, color: AppColors.primaria),
                            tooltip: 'Continuar',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Consumer<ProgressHomeController>(
                      builder: (context, progressCtrl, _) {
                        return _LearningSummaryCard(
                          controller: progressCtrl,
                          onVerProgresso: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (c) => ChangeNotifierProvider(
                                  create: (_) =>
                                      ProgressScreenController(c.read<ProgressService>())..loadInitial(),
                                  child: const MyProgressScreen(),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    _SectionHeader(
                      title: 'Temas em destaque',
                      actionLabel: 'Ver todos',
                      onAction: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => const TemasScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    const _FeaturedTemasStrip(),
                    const SizedBox(height: 28),
                    _SectionHeader(
                      title: 'Palavras em destaque',
                      actionLabel: 'Ver todos',
                      onAction: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => const DicionarioScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    const _FeaturedWordsStrip(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.lexend(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textoAzul,
            ),
          ),
        ),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            actionLabel,
            style: GoogleFonts.lexend(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primaria,
            ),
          ),
        ),
      ],
    );
  }
}

/// Azul mais claro para rótulos ao lado dos números (referência do layout).
const Color _summaryLabelBlue = Color(0xFF3B82F6);

class _LearningSummaryCard extends StatelessWidget {
  const _LearningSummaryCard({
    required this.controller,
    this.onVerProgresso,
  });

  final ProgressHomeController controller;
  final VoidCallback? onVerProgresso;

  @override
  Widget build(BuildContext context) {
    final err = controller.errorMessage;
    final data = controller.data;

    if (err != null && data == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SummaryHeaderRow(onVerProgresso: onVerProgresso),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.branco,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.bordaCampo),
            ),
            child: Column(
              children: [
                Text(
                  err,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(fontSize: 13, color: AppColors.textoSecundario),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.read<ProgressHomeController>().carregar(),
                  child: Text('Tentar novamente', style: GoogleFonts.lexend(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (data == null) {
      if (controller.isLoading) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SummaryHeaderRow(onVerProgresso: onVerProgresso),
            const SizedBox(height: 10),
            Container(
              height: 120,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.branco,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.bordaCampo),
              ),
              child: const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaria),
              ),
            ),
          ],
        );
      }
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SummaryHeaderRow(onVerProgresso: onVerProgresso),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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
          child: data.hasSummaryData ? _SummaryPopulated(data: data) : const _SummaryEmpty(),
        ),
      ],
    );
  }
}

class _SummaryHeaderRow extends StatelessWidget {
  const _SummaryHeaderRow({this.onVerProgresso});

  final VoidCallback? onVerProgresso;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            'Resumo de aprendizado',
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textoAzul,
              height: 1.2,
            ),
          ),
        ),
        TextButton(
          onPressed: onVerProgresso ??
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Tela de progresso completo em breve.',
                      style: GoogleFonts.lexend(),
                    ),
                  ),
                );
              },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(left: 8, bottom: 0),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            alignment: Alignment.bottomCenter,
          ),
          child: Text(
            'Visualizar progresso',
            style: GoogleFonts.lexend(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primaria,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryEmpty extends StatelessWidget {
  const _SummaryEmpty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(Icons.eco_rounded, size: 56, color: AppColors.primaria.withValues(alpha: 0.85)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nada por aqui ainda',
                  style: GoogleFonts.lexend(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textoAzul,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Que tal quebrar o gelo com sua primeira lição?',
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.textoSecundario,
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

class _SummaryPopulated extends StatelessWidget {
  const _SummaryPopulated({required this.data});

  final ProgressHome data;

  @override
  Widget build(BuildContext context) {
    final pct = (data.accuracyWeek * 100).round();
    final d = data.differenceLastWeek;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 11,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${data.totalPracticesWeek}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(
                        fontSize: 38,
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
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _summaryLabelBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (d > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '$d práticas a mais',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.acerto,
                          height: 1.25,
                        ),
                      ),
                      Text(
                        'que a semana anterior',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lexend(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textoSuave,
                          height: 1.25,
                        ),
                      ),
                    ],
                  )
                else if (d < 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${d.abs()} práticas a menos',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.erro,
                          height: 1.25,
                        ),
                      ),
                      Text(
                        'que a semana anterior',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lexend(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textoSuave,
                          height: 1.25,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    'Igual à semana anterior',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textoSuave,
                      height: 1.3,
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
            flex: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$pct%',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaria,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'acerto médio',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _summaryLabelBlue,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${data.wordsSeen}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaria,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'palavras praticadas',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _summaryLabelBlue,
                    height: 1.2,
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

class _FeaturedTemasStrip extends StatelessWidget {
  const _FeaturedTemasStrip();

  bool _isNovo(TemaResumo t) {
    if (t.createdAt.isEmpty) return false;
    try {
      final c = DateTime.parse(t.createdAt).toLocal();
      return DateTime.now().difference(c).inDays < 3;
    } catch (_) {
      return false;
    }
  }

  ({Color bg, Color fg, String text})? _badgeFor(TemaResumo t) {
    if (!_isNovo(t)) {
      return null;
    }
    return (
      bg: const Color(0xFFDBEAFE),
      fg: AppColors.primaria,
      text: 'novo',
    );
  }

  List<TemaResumo> _ordered(List<TemaResumo> list) {
    final copy = list.toList();
    copy.sort((a, b) {
      if (a.createdAt.isEmpty || b.createdAt.isEmpty) {
        return a.name.compareTo(b.name);
      }
      try {
        return DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt));
      } catch (_) {
        return a.name.compareTo(b.name);
      }
    });
    return copy.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TemasController, AuthController>(
      builder: (context, temasCtrl, auth, _) {
        if (temasCtrl.isLoadingListaTemas && !temasCtrl.temasListaJaCarregada) {
          return SizedBox(
            height: 128,
            child: Center(
              child: Text(
                'Carregando temas…',
                style: GoogleFonts.lexend(fontSize: 13, color: AppColors.textoSecundario),
              ),
            ),
          );
        }

        List<TemaResumo> temas = temasCtrl.temasEmMemoria;
        if (temas.isEmpty) {
          temas = auth.themesFromLogin;
        }

        if (temas.isEmpty) {
          return Text(
            'Crie um tema para ver sugestões aqui.',
            style: GoogleFonts.lexend(fontSize: 13, color: AppColors.textoSecundario),
          );
        }

        final featured = _ordered(temas);

        return SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: featured.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final tema = featured[index];
              final badge = _badgeFor(tema);
              return _FeaturedTemaCard(
                tema: tema,
                badge: badge,
              );
            },
          ),
        );
      },
    );
  }
}

class _FeaturedTemaCard extends StatelessWidget {
  const _FeaturedTemaCard({
    required this.tema,
    this.badge,
  });

  final TemaResumo tema;
  final ({Color bg, Color fg, String text})? badge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 140,
      child: DecoratedBox(
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: badge == null
                    ? const SizedBox(height: 18)
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: badge!.bg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badge!.text,
                          style: GoogleFonts.lexend(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: badge!.fg,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Text(
                  tema.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textoAzul,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                height: 34,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => PracticeSessionLoadingScreen(
                          themeId: tema.id,
                          practiceTitle: tema.name,
                        ),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaria,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Iniciar',
                    style: GoogleFonts.lexend(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.branco,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedWordsStrip extends StatelessWidget {
  const _FeaturedWordsStrip();

  List<PalavraModel> _pick(List<PalavraModel> all) {
    final active = all.where((p) => p.active).toList();
    int seenKey(PalavraModel p) {
      if (p.lastSeenAt == null || p.lastSeenAt!.isEmpty) return 0;
      try {
        return DateTime.parse(p.lastSeenAt!).millisecondsSinceEpoch;
      } catch (_) {
        return 0;
      }
    }

    active.sort((a, b) {
      final byLevel = b.boxLevel.compareTo(a.boxLevel);
      if (byLevel != 0) {
        return byLevel;
      }
      return seenKey(b).compareTo(seenKey(a));
    });
    return active.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DicionarioController>(
      builder: (context, dicCtrl, _) {
        if (dicCtrl.isLoadingLista && !dicCtrl.listaJaCarregada) {
          return SizedBox(
            height: 70,
            child: Center(
              child: Text(
                'Carregando palavras…',
                style: GoogleFonts.lexend(fontSize: 13, color: AppColors.textoSecundario),
              ),
            ),
          );
        }

        if (dicCtrl.errorLista != null && !dicCtrl.listaJaCarregada) {
          return Text(
            dicCtrl.errorLista!,
            style: GoogleFonts.lexend(fontSize: 13, color: AppColors.erro),
          );
        }

        final words = _pick(dicCtrl.palavras);
        if (words.isEmpty) {
          return Text(
            'Adicione palavras ao dicionário para acompanhá-las aqui.',
            style: GoogleFonts.lexend(fontSize: 13, color: AppColors.textoSecundario),
          );
        }

        return SizedBox(
          height: 70,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: words.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final p = words[index];
              return Container(
                width: 136,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Nível ${p.boxLevel}',
                      style: GoogleFonts.lexend(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaria,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.word.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lexend(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textoAzul,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
