import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primaria = Color(0xFF2563EB);
  static const Color secundaria = Color(0xFFD4AF17);
  static const Color acerto = Color(0xFF2CAF00);
  static const Color erro = Color(0xFFEB2525);
  static const Color textoPreto = Color(0xFF1E1E1E);
  static const Color textoAzul = Color(0xFF001C58);

  static const Color fundoClaro = Color(0xFFF3F4F6);
  static const Color bordaCampo = Color(0xFFD9D9D9);
  static const Color branco = Color(0xFFFFFFFF);

  static Color get textoSecundario =>
      textoPreto.withValues(alpha: 0.54);

  static Color get textoHint => textoPreto.withValues(alpha: 0.38);

  static Color get sombraLeve => textoPreto.withValues(alpha: 0.1);

  static Color get sombraElevacao => textoPreto.withValues(alpha: 0.25);

  static Color get sombraCard => textoPreto.withValues(alpha: 0.12);

  static Color get linhaDivisoria => textoPreto.withValues(alpha: 0.24);

  static Color get textoSuave => textoPreto.withValues(alpha: 0.45);
}
