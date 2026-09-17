import 'package:flutter/material.dart';

/// Paleta de cores do Cuidar+.
/// Tons suaves e acolhedores — evitar cores saturadas/frias em telas clínicas.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF6B4EFF); // Roxo Cuidar+
  static const Color primaryText = Color(0xFF1D2939); // Cinza Escuro / Texto
  static const Color secondaryText = Color(0xFF667085); // Cinza Médio
  static const Color background = Color(0xFFF9FAFB); // Fundo ultra claro
  static const Color surface = Colors.white;

  static const Color purpleLight = Color(0xFFF4F3FF);
  static const Color peachLight = Color(0xFFFFF4ED);
  static const Color mintLight = Color(0xFFECFDF3);
  static const Color yellowLight = Color(0xFFFEFBE8);
  static const Color blueLight = Color(0xFFF0F9FF);

  static const Color purple = Color(0xFF7F56D9);
  static const Color peach = Color(0xFFF79009);
  static const Color mint = Color(0xFF12B76A);
  static const Color yellow = Color(0xFFFAC515);
  static const Color blue = Color(0xFF2E90FA);

  static const Color success = mint;
  static const Color warning = yellow;
  static const Color info = blue;
  static const Color error = Color(0xFFF04438);

  // Aliases para compatibilidade legada
  static const Color lavender = purpleLight;
  static const Color pastelYellow = yellowLight;


}
