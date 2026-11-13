import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Section title in capitals, optionally with info on the right.
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
          Expanded(
            child: Text(title.toUpperCase(), style: AppText.overline(color: context.colors.muted)),
          ),
          if (trailing != null) Text(trailing!, style: AppText.body(13, color: context.colors.muted)),
        ],
      ),
    );
  }
}

/// Square 44 px button with icon (settings, back, favourite …).
class SquareIconButton extends StatelessWidget {
  const SquareIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.background,
    this.foreground,
    this.bordered = true,
    this.elevated = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? background;
  final Color? foreground;
  final bool bordered;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background ?? context.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: bordered ? BorderSide(color: context.colors.border) : BorderSide.none,
        ),
        elevation: elevated ? 2 : 0,
        shadowColor: context.colors.shadow.withValues(alpha: 0.2),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: SizedBox.square(dimension: 44, child: Icon(icon, size: 21, color: foreground ?? context.colors.ink)),
        ),
      ),
    );
  }
}

/// White card with a large radius.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.radius = 24});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(color: context.colors.surface, borderRadius: BorderRadius.circular(radius)),
      child: child,
    );
  }
}

/// Selection chip in the style of the design.
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

  /// `true`: dark chip (filters), `false`: green tinted (store selection).
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final Color trailingColor;
    final BorderSide side;
    if (!selected) {
      bg = context.colors.surface;
      fg = context.colors.ink;
      trailingColor = context.colors.muted;
      side = BorderSide(color: context.colors.chipBorder);
    } else if (dark) {
      bg = context.colors.strong;
      fg = context.colors.onStrong;
      trailingColor = context.colors.strongAccent;
      side = BorderSide(color: context.colors.strong);
    } else {
      bg = context.colors.primaryTint;
      fg = context.colors.primary;
      trailingColor = context.colors.onPrimaryTint.withValues(alpha: 0.8);
      side = BorderSide(color: context.colors.primary, width: 1.5);
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
          // No `alignment` on the Container: inside a Wrap that would stretch the
          // chip to full width. Height and centring come from the Row.
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

/// Price in euros formatted for the current locale, e.g. "2,29 €" or "€2.29".
String formatPrice(int cents, String locale) =>
    NumberFormat.simpleCurrency(locale: locale, name: 'EUR').format(cents / 100);

/// Parses "3,49" or "3.49" into cents.
int? parsePriceCents(String input) {
  final normalized = input.trim().replaceAll('€', '').replaceAll(',', '.').trim();
  if (normalized.isEmpty) return null;
  final value = double.tryParse(normalized);
  return value == null || value < 0 ? null : (value * 100).round();
}
