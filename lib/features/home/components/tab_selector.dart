import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';

class TabSelector extends StatelessWidget {

  final String selectedTab;
  final Function(String) onTabChanged;

  const TabSelector({super.key, required this.selectedTab, required this.onTabChanged});

  Widget _buildTab(String label) {
    bool isSelected = selectedTab == label;
    return GestureDetector(
      onTap: () => onTabChanged(label), // Avisa o pai que mudou
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Text(
          label,
          style: GoogleFonts.lexend( // Usando Lexend conforme seu perfil
            color: isSelected ? AppColors.primaria : AppColors.textoSecundario,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [_buildTab('Temas'), _buildTab('Palavras'), _buildTab('Progresso')]);
  }
}