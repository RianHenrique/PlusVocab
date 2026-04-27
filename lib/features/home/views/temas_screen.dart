import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/auth/controllers/auth_controller.dart';
import 'package:plus_vocab/features/pratica/exercicio/views/practice_session_loading_screen.dart';
import 'package:plus_vocab/features/temas/models/tema_resumo.dart';
import 'package:provider/provider.dart';

class TemasHomeTab extends StatefulWidget {
  const TemasHomeTab({super.key});

  @override
  State<TemasHomeTab> createState() => _TemasHomeTabState();
}

class _TemasHomeTabState extends State<TemasHomeTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TemaResumo> _filtrar(List<TemaResumo> temas) {
    if (_searchQuery.isEmpty) return temas;
    final q = _searchQuery.toLowerCase();
    return temas.where((t) => t.name.toLowerCase().contains(q)).toList();
  }

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: AppColors.fundoClaro,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.bordaCampo,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
              color: AppColors.sombraLeve,
              blurRadius: 4,
              offset: const Offset(0, 4))
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        textAlignVertical: TextAlignVertical.center,
        maxLines: null,
        style: GoogleFonts.lexend(
          fontSize: 14,
          color: AppColors.textoPreto,
        ),
        decoration: InputDecoration(
          hintText: 'Pesquise aqui por um tema',
          hintStyle: GoogleFonts.lexend(
            fontSize: 14,
            color: AppColors.textoSecundario
          ),
          border: InputBorder.none,
          suffixIcon: const Icon(Icons.search, color: AppColors.primaria),
        ),
      ),
    );
  }

  Widget _builderIconButton(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildThemeCard(BuildContext context, TemaResumo tema) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15.0),
          margin: const EdgeInsets.only(bottom: 15.0),
          decoration: BoxDecoration(
            color: AppColors.fundoClaro,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.sombraLeve,
                blurRadius: 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tema.name,
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textoAzul,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Resumo carregado após abrir a tela de temas.',
                style: GoogleFonts.lexend(
                  color: AppColors.textoSecundario,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  _builderIconButton(Icons.delete_outline, AppColors.erro),
                  const SizedBox(width: 5),
                  _builderIconButton(Icons.edit_outlined, AppColors.primaria),
                  const SizedBox(width: 10),
                  ElevatedButton(
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaria,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: Text('Iniciar nova prática',
                        style: GoogleFonts.lexend(color: AppColors.branco, fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, _) {
        final filtrados = _filtrar(auth.themesFromLogin);
        return Column(children: [
          _buildSearchField(),
          const SizedBox(height: 20),
          if (auth.themesFromLogin.isEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Os temas da sua conta aparecem aqui após o login.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textoSecundario),
              ),
            )
          else if (filtrados.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Nenhum tema encontrado',
                  style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textoSecundario),
                ),
              ),
            )
          else
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: filtrados.length,
              itemBuilder: (context, index) {
                return _buildThemeCard(context, filtrados[index]);
              },
            ),
        ]);
      },
    );
  }
}
