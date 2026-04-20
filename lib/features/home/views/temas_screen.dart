import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';

class TemasHomeTab extends StatefulWidget {
  const TemasHomeTab({super.key});

  @override
  State<TemasHomeTab> createState() => _TemasHomeTabState();
}

class _TemasHomeTabState extends State<TemasHomeTab> {
  final TextEditingController _searchController = TextEditingController();

  static const List<Map<String, dynamic>> allThemes = [
    {'tema': 'Ida a um restaurante', 'matches': 5, 'successRate': 75},
    {'tema': 'Conversa em um bar', 'matches': 4, 'successRate': 100},
    {'tema': 'Compras no shopping', 'matches': 2, 'successRate': 90},
    {
      'tema': 'Entrevista de emprego na Amazon',
      'matches': 7,
      'successRate': 50
    },
  ];

  List<Map<String, dynamic>> filteredThemes = [];

  @override
  void initState() {
    super.initState();
    filteredThemes = List.from(allThemes);
  }

  void _filterThemes(String query) {
    setState(() {
      filteredThemes = allThemes
          .where((theme) =>
              theme['tema'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
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
        onChanged: _filterThemes,
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
          ), // Usando Lexend
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

  Widget _buildThemeCard(String title, int matches, int successRate) {
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
                title,
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textoAzul,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Número de partidas: $matches | Taxa de acerto: $successRate%',
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
                      // Lógica para iniciar o jogo com esse tema
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
    return Column(children: [
      _buildSearchField(),
      const SizedBox(height: 20),
      filteredThemes.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Nenhum tema encontrado',
                  style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textoSecundario),
                ),
              ),
            )
          : ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: filteredThemes.length,
              itemBuilder: (context, index) {
                final themeInfo = filteredThemes[index];
                return _buildThemeCard(themeInfo['tema'], themeInfo['matches'],
                    themeInfo['successRate']);
              },
            ),
    ]);
  }
}
