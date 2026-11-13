import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';

/// Scaffold with bottom navigation: Overview · Scan · Stores.
/// Settings are reached via the gear icon in the header ([CollapsingTabPage]).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      // The lists run underneath the bar; content is visible to the left and
      // right of the scan button, which sits on top.
      extendBody: true,
      body: navigationShell,
      // The scan button sticks out above the bar. To keep it fully tappable it
      // lies inside the (taller) navigation area, and only the white bar below
      // it is lower.
      bottomNavigationBar: SizedBox(
        height: _barHeight + _scanRaise + bottomInset,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: _barHeight + bottomInset,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  border: Border(top: BorderSide(color: context.colors.borderSoft)),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(28, 0, 28, bottomInset + 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: _tab(0, Icons.format_list_bulleted_rounded, l10n.navOverview)),
                    Expanded(
                      child: _ScanButton(label: l10n.navScan, onTap: () => context.push('/scan')),
                    ),
                    Expanded(child: _tab(1, Icons.storefront_outlined, l10n.navStores)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tab(int index, IconData icon, String label) {
    final selected = navigationShell.currentIndex == index;
    return _NavItem(
      icon: icon,
      label: label,
      selected: selected,
      // Tapping the active tab again scrolls back to its top.
      onTap: () => navigationShell.goBranch(index, initialLocation: selected),
    );
  }

  /// Height of the white bar (without system inset).
  static const _barHeight = 84.0;

  /// How far the scan button area extends above the bar.
  static const _scanRaise = 22.0;
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? context.colors.primary : context.colors.muted;
    return Semantics(
      selected: selected,
      button: true,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: SizedBox(
          height: 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppText.body(12, weight: selected ? FontWeight.w700 : FontWeight.w600, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  const _ScanButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        // Shrinks with very large system font sizes instead of overflowing.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: context.colors.surface,
                    width: 5,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.primary.withValues(alpha: 0.32),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 6),
              Text(label, style: AppText.body(12, weight: FontWeight.w600)),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}
