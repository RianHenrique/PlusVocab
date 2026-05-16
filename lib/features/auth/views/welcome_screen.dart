import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/auth/views/signin_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    (
      title: 'Aprenda o que\nrealmente importa',
      body:
          'Chega de frases prontas. O +Vocab cria exercícios baseados nos seus interesses e nível atual.',
    ),
    (
      title: 'Vocabulário em\ncontexto',
      body:
          'Não decore palavras soltas. Aprenda como usá-las em situações reais e temas que você escolher.',
    ),
    (
      title: 'Veja sua evolução',
      body:
          'Acompanhe seu domínio de palavras crescer a cada dia com estatísticas detalhadas. Vamos começar?',
    ),
  ];

  void _goToSignIn() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _slides.length - 1;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.branco,
      body: Stack(
        children: [
          // ── Background ────────────────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Fox ───────────────────────────────────────────
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      'assets/images/fox_sentada.png',
                      height: 280,
                    ),
                  ),
                ),

                // ── Card flutuante ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                    decoration: BoxDecoration(
                      color: AppColors.branco,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.sombraCard,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo + Pular
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              'assets/images/PlusVocab2.png',
                              height: 34,
                            ),
                            TextButton(
                              onPressed: _goToSignIn,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Pular',
                                style: GoogleFonts.lexend(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.erro,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Slide content (altura fixa para evitar saltos de layout)
                        SizedBox(
                          height: 130,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: _slides.length,
                            onPageChanged: (i) =>
                                setState(() => _currentPage = i),
                            itemBuilder: (_, i) {
                              final slide = _slides[i];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    slide.title,
                                    style: GoogleFonts.lexend(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textoAzul,
                                      height: 1.25,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    slide.body,
                                    style: GoogleFonts.lexend(
                                      fontSize: 14,
                                      color: AppColors.textoSecundario,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Dots centralizados ou botão Começar (altura fixa = botão)
                        SizedBox(
                          height: 44,
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: isLast
                                  ? SizedBox(
                                      key: const ValueKey('btn'),
                                      width: double.infinity,
                                      height: 44,
                                      child: FilledButton(
                                        onPressed: _goToSignIn,
                                        style: FilledButton.styleFrom(
                                          backgroundColor: AppColors.primaria,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: Text(
                                          'Começar',
                                          style: GoogleFonts.lexend(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.branco,
                                          ),
                                        ),
                                      ),
                                    )
                                  : _Dots(
                                      key: const ValueKey('dots'),
                                      count: _slides.length,
                                      current: _currentPage,
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
          ),
        ],
      ),
    ),
    );
  }
}


class _Dots extends StatelessWidget {
  const _Dots({super.key, required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.primaria : AppColors.bordaCampo,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
