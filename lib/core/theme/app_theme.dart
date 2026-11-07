import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppText {
  /// Überschriften: Bricolage Grotesque. Ohne [color] gilt die Textfarbe des Themes.
  static TextStyle display(double size, {FontWeight weight = FontWeight.w700, Color? color}) =>
      GoogleFonts.bricolageGrotesque(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: 1.05,
        letterSpacing: -0.02 * size,
      );

  /// Abschnittsüberschriften in Versalien.
  static TextStyle overline({Color? color}) =>
      GoogleFonts.figtree(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: color);

  static TextStyle body(double size, {FontWeight weight = FontWeight.w400, Color? color}) =>
      GoogleFonts.figtree(fontSize: size, fontWeight: weight, color: color);
}

abstract final class AppTheme {
  static ThemeData light() => _build(AppPalette.light);

  static ThemeData dark() => _build(AppPalette.dark);

  static ThemeData _build(AppPalette c) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: c.brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: c.primary,
        brightness: c.brightness,
        primary: c.primary,
        onPrimary: Colors.white,
        secondary: AppColors.lime,
        onSecondary: AppColors.onLime,
        surface: c.surface,
        onSurface: c.ink,
        onSurfaceVariant: c.muted,
        outline: c.chipBorder,
        outlineVariant: c.border,
      ),
      scaffoldBackgroundColor: c.background,
      fontFamily: GoogleFonts.figtree().fontFamily,
      extensions: [c],
    );

    // Muted-Farbe wird überall dort verwendet, wo kein Overline-Stil gesetzt ist.
    TextStyle? withMuted(TextStyle? s) => s?.copyWith(color: c.muted);

    return base.copyWith(
      textTheme: base.textTheme.copyWith(labelSmall: withMuted(base.textTheme.labelSmall)),
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: overlayStyle(c),
      ),
      iconTheme: IconThemeData(color: c.ink),
      dividerTheme: DividerThemeData(color: c.border),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: AppText.body(15, color: c.hint),
        labelStyle: AppText.body(15, color: c.muted),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: c.subtle,
          disabledForegroundColor: c.faint,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: AppText.body(16, weight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.ink,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: c.chipBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: AppText.body(15, weight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: c.isDark ? c.onPrimaryTint : c.primary),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: c.chipBorder,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? c.primary : c.chipBorder,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        thumbIcon: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? Icon(Icons.check_rounded, size: 16, color: c.primary) : null,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.strong,
        contentTextStyle: AppText.body(14, weight: FontWeight.w600, color: c.onStrong),
        actionTextColor: c.strongAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.primary),
    );
  }

  /// Statusleiste: dunkle Symbole im hellen Modus, helle im dunklen.
  static SystemUiOverlayStyle overlayStyle(AppPalette c) =>
      (c.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: c.surface,
        systemNavigationBarIconBrightness: c.isDark ? Brightness.light : Brightness.dark,
      );
}
