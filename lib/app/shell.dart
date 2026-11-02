import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';

/// Grundgerüst mit unterer Navigation: Übersicht · Scannen · Läden.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: navigationShell,
      // Der Scan-Knopf ragt über die Leiste hinaus. Damit er vollständig
      // antippbar bleibt, liegt er innerhalb der (höheren) Navigationsfläche
      // und nur die weiße Leiste darunter ist niedriger.
      bottomNavigationBar: SizedBox(
        height: _barHeight + _scanRaise + bottomInset,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: _barHeight + bottomInset,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.borderSoft)),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(28, 0, 28, bottomInset + 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _NavItem(
                        icon: Icons.format_list_bulleted_rounded,
                        label: l10n.navOverview,
                        selected: navigationShell.currentIndex == 0,
                        onTap: () => navigationShell.goBranch(0, initialLocation: navigationShell.currentIndex == 0),
                      ),
                    ),
                    Expanded(
                      child: _ScanButton(label: l10n.navScan, onTap: () => context.push('/scan')),
                    ),
                    Expanded(
                      child: _NavItem(
                        icon: Icons.storefront_outlined,
                        label: l10n.navStores,
                        selected: navigationShell.currentIndex == 1,
                        onTap: () => navigationShell.goBranch(1, initialLocation: navigationShell.currentIndex == 1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Höhe der weißen Leiste (ohne System-Inset).
  static const _barHeight = 84.0;

  /// So weit ragt der Bereich für den Scan-Knopf über die Leiste.
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
    final color = selected ? AppColors.primary : AppColors.muted;
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
        // Schrumpft bei sehr großer Systemschrift, statt überzulaufen.
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
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.background, width: 5, strokeAlign: BorderSide.strokeAlignOutside),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.32),
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
