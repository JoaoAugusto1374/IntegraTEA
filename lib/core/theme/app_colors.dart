import 'package:flutter/material.dart';

/// Paleta de cores do Cuidar+.
/// Tons suaves e acolhedores — evitar cores saturadas/frias em telas clínicas.
class AppColors {
  AppColors._();

  static const Color primaryText = Color(0xFF344054); // Azul Ardósia
  static const Color background = Color(0xFFFDFBF7); // Off-white
  static const Color surface = Color(0xFFF5F6F8);

  static const Color peach = Color(0xFFF6B978);
  static const Color mint = Color(0xFF91DCC1);
  static const Color lavender = Color(0xFFB99BCB);
  static const Color pastelYellow = Color(0xFFF6D76F);

  static const Color success = mint;
  static const Color warning = pastelYellow;
  static const Color info = lavender;
  static const Color accent = peach;

  static const List<Color> journeyPalette = [peach, lavender, mint, pastelYellow];
}
