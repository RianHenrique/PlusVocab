import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/pratica/exercicio/views/practice_session_loading_screen.dart';
import 'package:plus_vocab/features/temas/controllers/temas_controller.dart';
import 'package:plus_vocab/features/temas/models/tema_resumo.dart';
import 'package:provider/provider.dart';

class TemasScreen extends StatefulWidget {
  const TemasScreen({super.key});

  @override
  State<TemasScreen> createState() => _TemasScreenState();
}

class _TemasScreenState extends State<TemasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TemasController>().carregarListaTemasSeNecessario();
    });
  }

  @override
  Widget build(BuildContext context) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                Expanded(
                  child: Consumer<TemasController>(
                    builder: (context, controller, _) {
                      if (controller.isLoadingListaTemas &&
                          !controller.temasListaJaCarregada) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaria,
                          ),
                        );
                      }

                      if (controller.errorListaTemas != null &&
                          !controller.temasListaJaCarregada) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                controller.errorListaTemas!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  color: AppColors.textoSecundario,
                                ),
                              ),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: () =>
                                    controller.forcarAtualizacaoListaTemas(),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primaria,
                                ),
                                child: Text(
                                  'Tentar novamente',
                                  style: GoogleFonts.lexend(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final temas = controller.temasEmMemoria;
                      if (temas.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'Nenhum tema cadastrado.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lexend(
                                fontSize: 14,
                                color: AppColors.textoSecundario,
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        itemCount: temas.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _TemaListaCard(
                            tema: temas[index],
                            onPraticar: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (context) => PracticeSessionLoadingScreen(
                                    themeId: temas[index].id,
                                    practiceTitle: temas[index].name,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Transform.translate(
            offset: const Offset(-10, 0),
            child: IconButton(
              icon: const Icon(Icons.chevron_left, size: 28),
              color: AppColors.textoPreto,
              onPressed: () => Navigator.of(context).maybePop(),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 40),
            ),
          ),
          Expanded(
            child: Text(
              'Temas',
              textAlign: TextAlign.center,
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textoPreto,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _TemaListaCard extends StatelessWidget {
  const _TemaListaCard({
    required this.tema,
    required this.onPraticar,
  });

  final TemaResumo tema;
  final VoidCallback onPraticar;

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
            color: AppColors.sombraCard,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tema.name,
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textoAzul,
            ),
          ),
          if (tema.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              tema.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.lexend(
                fontSize: 13,
                color: AppColors.textoSecundario,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: onPraticar,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaria,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Praticar',
                style: GoogleFonts.lexend(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
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
