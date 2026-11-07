import 'package:flutter/material.dart';

/// Markenfarben, die in hellem und dunklem Modus gleich bleiben.
abstract final class AppColors {
  static const lime = Color(0xFFD9F27A);

  /// Text und Symbole auf [lime].
  static const onLime = Color(0xFF15201A);

  /// Der Scanner ist immer dunkel.
  static const scannerBackground = Color(0xFF0F1512);
}

/// Farbpalette für hellen und dunklen Modus; in Widgets über `context.colors`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.ink,
    required this.inkSoft,
    required this.textSecondary,
    required this.muted,
    required this.faint,
    required this.hint,
    required this.border,
    required this.borderSoft,
    required this.chipBorder,
    required this.dashed,
    required this.subtle,
    required this.primary,
    required this.primaryTint,
    required this.onPrimaryTint,
    required this.limeSoft,
    required this.strong,
    required this.onStrong,
    required this.strongAccent,
    required this.scoreHigh,
    required this.scoreMid,
    required this.scoreLow,
    required this.onScoreHigh,
    required this.shadow,
  });

  final Brightness brightness;

  /// Seitenhintergrund.
  final Color background;

  /// Karten, Leisten, Eingabefelder.
  final Color surface;

  /// Haupttext.
  final Color ink;
  final Color inkSoft;

  /// Zweitrangiger Text, kräftiger als [muted].
  final Color textSecondary;
  final Color muted;

  /// Deaktivierte Zahlen, Pfeile.
  final Color faint;
  final Color hint;

  final Color border;
  final Color borderSoft;
  final Color chipBorder;

  /// Gestrichelte Rahmen und leere Zustände.
  final Color dashed;
  final Color subtle;

  /// Grün für Flächen (Knöpfe) und Akzente.
  final Color primary;

  /// Hellgrün hinterlegte Flächen (z. B. ausgewählter Laden) …
  final Color primaryTint;

  /// … und Text/Symbole darauf.
  final Color onPrimaryTint;

  final Color limeSoft;

  /// Kräftige Fläche für Ausgewähltes (hell: fast schwarz, dunkel: Lime) …
  final Color strong;

  /// … Text darauf …
  final Color onStrong;

  /// … und ein Akzent darauf (Zähler, Symbole).
  final Color strongAccent;

  final Color scoreHigh;
  final Color scoreMid;
  final Color scoreLow;

  /// Text auf [scoreHigh] und Lime-Flächen.
  final Color onScoreHigh;

  /// Grundfarbe für Schatten.
  final Color shadow;

  bool get isDark => brightness == Brightness.dark;

  Color scoreBackground(int score) {
    if (score >= 8) return scoreHigh;
    if (score >= 6) return scoreMid;
    return scoreLow;
  }

  static const light = AppPalette(
    brightness: Brightness.light,
    background: Color(0xFFF3F4EF),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF15201A),
    inkSoft: Color(0xFF2A352E),
    textSecondary: Color(0xFF3E4A42),
    muted: Color(0xFF5B665F),
    faint: Color(0xFF8A948C),
    hint: Color(0xFF69736C),
    border: Color(0xFFE1E5DC),
    borderSoft: Color(0xFFE8EBE3),
    chipBorder: Color(0xFFDCE0D6),
    dashed: Color(0xFFCBD1C4),
    subtle: Color(0xFFEEF0EA),
    primary: Color(0xFF1E5B3F),
    primaryTint: Color(0xFFEAF3EE),
    onPrimaryTint: Color(0xFF1E5B3F),
    limeSoft: Color(0xFFF1F8D6),
    strong: Color(0xFF15201A),
    onStrong: Color(0xFFFFFFFF),
    strongAccent: AppColors.lime,
    scoreHigh: Color(0xFFE4F5A4),
    scoreMid: Color(0xFFEEF0EA),
    scoreLow: Color(0xFFF6E3DC),
    onScoreHigh: Color(0xFF15201A),
    shadow: Color(0xFF15201A),
  );

  static const dark = AppPalette(
    brightness: Brightness.dark,
    background: Color(0xFF0F1411),
    surface: Color(0xFF19201B),
    ink: Color(0xFFE9EDE6),
    inkSoft: Color(0xFFD2D8D0),
    textSecondary: Color(0xFFB8C1B9),
    muted: Color(0xFF94A097),
    faint: Color(0xFF66726A),
    hint: Color(0xFF7D897F),
    border: Color(0xFF2A332D),
    borderSoft: Color(0xFF232B25),
    chipBorder: Color(0xFF333D36),
    dashed: Color(0xFF3B463F),
    subtle: Color(0xFF212922),
    primary: Color(0xFF3A8862),
    primaryTint: Color(0xFF1C3127),
    onPrimaryTint: Color(0xFF9AD6B4),
    limeSoft: Color(0xFF2A3214),
    strong: AppColors.lime,
    onStrong: Color(0xFF15201A),
    strongAccent: Color(0xFF1E5B3F),
    scoreHigh: Color(0xFF3B4A14),
    scoreMid: Color(0xFF262E28),
    scoreLow: Color(0xFF41291F),
    onScoreHigh: Color(0xFFE9EDE6),
    shadow: Color(0xFF000000),
  );

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(covariant AppPalette? other, double t) => t < 0.5 || other == null ? this : other;
}

extension AppPaletteContext on BuildContext {
  /// Aktuelle Farbpalette (hell oder dunkel).
  AppPalette get colors => Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}
