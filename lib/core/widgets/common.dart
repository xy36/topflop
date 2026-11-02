import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Abschnittstitel in Versalien, optional mit Info rechts.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 4, 2, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(child: Text(title.toUpperCase(), style: AppText.overline())),
          if (trailing != null) Text(trailing!, style: AppText.body(13, color: AppColors.muted)),
        ],
      ),
    );
  }
}

/// Quadratischer 44-px-Knopf mit Icon (Einstellungen, Zurück, Favorit …).
class SquareIconButton extends StatelessWidget {
  const SquareIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.background = AppColors.surface,
    this.foreground = AppColors.ink,
    this.bordered = true,
    this.elevated = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color background;
  final Color foreground;
  final bool bordered;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: bordered ? const BorderSide(color: AppColors.border) : BorderSide.none,
        ),
        elevation: elevated ? 2 : 0,
        shadowColor: AppColors.ink.withValues(alpha: 0.2),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: SizedBox.square(dimension: 44, child: Icon(icon, size: 21, color: foreground)),
        ),
      ),
    );
  }
}

/// Weiße Karte mit großem Radius.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.radius = 24});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(radius)),
      child: child,
    );
  }
}

/// Auswahl-Chip im Stil des Entwurfs.
class PillChip extends StatelessWidget {
  const PillChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.trailing,
    this.dark = true,
  });

  final String label;
  final String? trailing;
  final bool selected;
  final VoidCallback onTap;

  /// `true`: dunkler Chip (Filter), `false`: grün getönt (Ladenauswahl).
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final Color trailingColor;
    final BorderSide side;
    if (!selected) {
      bg = AppColors.surface;
      fg = AppColors.ink;
      trailingColor = AppColors.muted;
      side = const BorderSide(color: AppColors.chipBorder);
    } else if (dark) {
      bg = AppColors.ink;
      fg = Colors.white;
      trailingColor = AppColors.lime;
      side = const BorderSide(color: AppColors.ink);
    } else {
      bg = AppColors.primaryTint;
      fg = AppColors.primary;
      trailingColor = const Color(0xFF3E6B53);
      side = const BorderSide(color: AppColors.primary, width: 1.5);
    }
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: bg,
        shape: StadiumBorder(side: side),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          // Kein `alignment` am Container: das würde den Chip in einem Wrap
          // auf volle Breite ziehen. Höhe und Zentrierung kommen vom Row.
          child: Container(
            height: dark ? 36 : 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: label,
                        style: AppText.body(14, weight: selected ? FontWeight.w700 : FontWeight.w600, color: fg),
                      ),
                      if (trailing != null)
                        TextSpan(
                          text: dark ? '  $trailing' : ' · $trailing',
                          style: AppText.body(dark ? 12 : 14, color: trailingColor),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String formatPrice(int cents, String locale) {
  final value = (cents / 100).toStringAsFixed(2);
  return locale.startsWith('de') ? '${value.replaceAll('.', ',')} €' : '€$value';
}

/// Parst „3,49“ oder „3.49“ zu Cent.
int? parsePriceCents(String input) {
  final normalized = input.trim().replaceAll('€', '').replaceAll(',', '.').trim();
  if (normalized.isEmpty) return null;
  final value = double.tryParse(normalized);
  return value == null || value < 0 ? null : (value * 100).round();
}
