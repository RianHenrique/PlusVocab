import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/pratica/exercicio/models/practice_session_models.dart';
import 'package:plus_vocab/features/pratica/exercicio/views/practice_session_screen.dart';

/// Tela exibida ao iniciar uma prática. Por enquanto usa um atraso fixo; no futuro,
/// substituir por espera ao endpoint de iniciar sessão.
class PracticeSessionLoadingScreen extends StatefulWidget {
  const PracticeSessionLoadingScreen({
    super.key,
    required this.session,
    required this.practiceTitle,
  });

  final PracticeSessionPayload session;
  final String practiceTitle;

  @override
  State<PracticeSessionLoadingScreen> createState() => _PracticeSessionLoadingScreenState();
}

class _PracticeSessionLoadingScreenState extends State<PracticeSessionLoadingScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _mockWait = Duration(seconds: 30);
  static const Duration _phraseInterval = Duration(seconds: 5);

  late final AnimationController _progressController;
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
    _progressController = AnimationController(vsync: this, duration: _mockWait)..forward();

    _phraseTimer = Timer.periodic(_phraseInterval, (_) {
      if (!mounted) return;
      setState(() {
        _phraseIndex = (_phraseIndex + 1) % _phrases.length;
      });
    });

    // TODO(RF-21): substituir o delay por `await` ao endpoint de iniciar prática; manter esta tela até a resposta.
    Future<void>.delayed(_mockWait, () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => PracticeSessionScreen(
            session: widget.session,
            practiceTitle: widget.practiceTitle,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _phraseTimer?.cancel();
    _progressController.dispose();
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
                  const SizedBox(height: 40),
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return SizedBox(
                        width: 96,
                        height: 96,
                        child: CircularProgressIndicator(
                          value: _progressController.value,
                          strokeWidth: 6,
                          color: AppColors.primaria,
                          backgroundColor: AppColors.bordaCampo,
                        ),
                      );
                    },
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
                  Text(
                    'Aguarde… em breve isso refletirá o carregamento real da partida.',
                    textAlign: TextAlign.center,
                    style: theme.copyWith(
                      fontSize: 12,
                      color: AppColors.textoSuave,
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
