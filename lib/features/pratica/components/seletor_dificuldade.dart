import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  final Color _bgLight = const Color(0xFFf3f4f6);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: _bgLight,
        borderRadius: BorderRadius.circular(10), // Formato de pílula
        border: Border.all(
          color: const Color(0xFFD9D9D9),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1), // Sombra sutil
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
        style: GoogleFonts.lexend(
          color: Colors.black,
          fontSize: 14,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none, // Remove a linha de baixo
          contentPadding: EdgeInsets.zero,
        ),
        value: selectedOption,
        hint: Text("Selecione o nível", style: GoogleFonts.lexend()),
        items: options
            .map((nivel) => DropdownMenuItem(
              value: nivel,
              child: Text(
                nivel, 
                style: GoogleFonts.lexend(
                  color: Colors.black,
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