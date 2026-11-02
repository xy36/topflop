import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Kopfzeile der Haupt-Tabs: App-Name mit Zahnrad (Einstellungen) darüber,
/// darunter der Seitentitel mit einer seitenspezifischen Aktion.
class TabHeader extends StatelessWidget {
  const TabHeader({super.key, required this.title, required this.action});

  final String title;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 40,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.appName.toUpperCase(),
                  style: AppText.overline().copyWith(fontSize: 12, letterSpacing: 1.4),
                ),
              ),
              // Gleiche Breite wie die Aktion darunter, damit beide Icons übereinander stehen.
              SizedBox(
                width: 44,
                child: IconButton(
                  onPressed: () => context.push('/settings'),
                  tooltip: l10n.settings,
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.settings_outlined, size: 22, color: AppColors.muted),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(child: Text(title, style: AppText.display(32))),
            action,
          ],
        ),
      ],
    );
  }
}
