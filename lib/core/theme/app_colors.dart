import 'package:flutter/material.dart';

/// Farbpalette aus dem Design-Entwurf.
abstract final class AppColors {
  static const background = Color(0xFFF3F4EF);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF15201A);
  static const inkSoft = Color(0xFF2A352E);
  static const muted = Color(0xFF5B665F);
  static const border = Color(0xFFE1E5DC);
  static const borderSoft = Color(0xFFE8EBE3);
  static const chipBorder = Color(0xFFDCE0D6);
  static const subtle = Color(0xFFEEF0EA);

  static const primary = Color(0xFF1E5B3F);
  static const primaryDark = Color(0xFF15402C);
  static const primaryTint = Color(0xFFEAF3EE);
  static const lime = Color(0xFFD9F27A);
  static const limeSoft = Color(0xFFF1F8D6);

  static const scoreHigh = Color(0xFFE4F5A4);
  static const scoreMid = Color(0xFFEEF0EA);
  static const scoreLow = Color(0xFFF6E3DC);

  static const scannerBackground = Color(0xFF0F1512);

  static Color scoreBackground(int score) {
    if (score >= 8) return scoreHigh;
    if (score >= 6) return scoreMid;
    return scoreLow;
  }
}
