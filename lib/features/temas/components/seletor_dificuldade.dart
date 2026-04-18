import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';

class SeletorDificuldade extends StatelessWidget {
  final List<String> options;
  final String? selectedOption;
  final Function(String) onOptionChange;

  const SeletorDificuldade({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onOptionChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.fundoClaro,
        borderRadius: BorderRadius.circular(10), // Formato de pílula
        border: Border.all(
          color: AppColors.bordaCampo,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.sombraLeve,
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textoPreto),
        style: GoogleFonts.lexend(
          color: AppColors.textoPreto,
          fontSize: 14,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none, // Remove a linha de baixo
          contentPadding: EdgeInsets.zero,
        ),
        value: selectedOption,
        hint: Text("Selecione o nível", style: GoogleFonts.lexend(color: AppColors.textoSecundario)),
        items: options
            .map((nivel) => DropdownMenuItem(
              value: nivel,
              child: Text(
                nivel, 
                style: GoogleFonts.lexend(
                  color: AppColors.textoPreto,
                  fontSize: 14,
                ),
              )
            )
          ).toList(),
        onChanged: (value) => onOptionChange(value!),
      ),
    );
  }
}