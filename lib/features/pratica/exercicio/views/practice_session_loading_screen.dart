import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/pratica/exercicio/data/vocab_practice_service.dart';
import 'package:plus_vocab/features/pratica/exercicio/views/practice_session_screen.dart';
import 'package:provider/provider.dart';

/// Tela exibida ao iniciar uma prática: chama `POST /vocab/practice/start` e abre a sessão.
class PracticeSessionLoadingScreen extends StatefulWidget {
  const PracticeSessionLoadingScreen({
    super.key,
    required this.themeId,
    required this.practiceTitle,
  });

  final String themeId;
  final String practiceTitle;

  @override
  State<PracticeSessionLoadingScreen> createState() => _PracticeSessionLoadingScreenState();
}

class _PracticeSessionLoadingScreenState extends State<PracticeSessionLoadingScreen> {
  static const Duration _phraseInterval = Duration(seconds: 5);

  int _phraseIndex = 0;
  Timer? _phraseTimer;

  static final List<String> _phrases = [
    'Você sabia que revisar vocabulário em contexto ajuda a fixar melhor o significado das palavras?',
    'Você atualmente tem dificuldade nas palavras: itinerário, provisioning, embarque. '
        '(Em breve virá do seu progresso no app.)',
    'Você recentemente acertou as palavras: "reserva", "cardápio" e "gorjeta". '
        '(Dados de exemplo até integrarmos o endpoint de progresso.)',
    'Enquanto isso, respire fundo: uma partida curta e focada vale mais que uma sessão longa e cansada.',
  ];

  @override
  void initState() {
    super.initState();
    _phraseTimer = Timer.periodic(_phraseInterval, (_) {
      if (!mounted) return;
      setState(() {
        _phraseIndex = (_phraseIndex + 1) % _phrases.length;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregarSessao());
  }

  Future<void> _carregarSessao() async {
    try {
      final service = context.read<VocabPracticeService>();
      final session = await service.iniciarSessao(themeId: widget.themeId);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => PracticeSessionScreen(
            session: session,
            practiceTitle: widget.practiceTitle,
            themeId: widget.themeId,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: GoogleFonts.lexend(color: AppColors.branco),
          ),
          backgroundColor: AppColors.erro,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _phraseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = GoogleFonts.lexend();

    return Scaffold(
      backgroundColor: AppColors.branco,
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Column(
                children: [
                  Text(
                    'Preparando sua prática',
                    textAlign: TextAlign.center,
                    style: theme.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textoAzul,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.practiceTitle,
                    textAlign: TextAlign.center,
                    style: theme.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaria,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Nossa inteligência artificial está elaborando exercícios personalizados '
                    'com base no seu tema. Isso pode levar alguns instantes — aguarde, por favor.',
                    textAlign: TextAlign.center,
                    style: theme.copyWith(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.textoSecundario,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const SizedBox(
                    width: 96,
                    height: 96,
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                      color: AppColors.primaria,
                      backgroundColor: AppColors.bordaCampo,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 450),
                        child: Text(
                          _phrases[_phraseIndex],
                          key: ValueKey<int>(_phraseIndex),
                          textAlign: TextAlign.center,
                          style: theme.copyWith(
                            fontSize: 15,
                            height: 1.45,
                            color: AppColors.textoPreto,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
