import 'package:flutter/material.dart';

class ProfileCircle extends StatelessWidget {
  const ProfileCircle({super.key});

  final Color _blue = const Color(0xFF2563EB);
  final Color _bgLight = const Color(0xFFf3f4f6);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => debugPrint("Clicou no perfil!"),
      customBorder: const CircleBorder(),
      child: Center(
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _bgLight,
            border: Border.all(
              color: _blue,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.25),
                blurRadius: 4,
                offset: const Offset(0, 4),
              )
            ], // Cor de fundo do círculo
          ),
          child:  Icon(
            Icons.person, // Ícone de perfil
            color: _blue, // Cor do ícone
            size: 30, // Tamanho do ícone
          ),
        ),
      ),
    );
  }
}