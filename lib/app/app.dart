import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';

class TopFlopApp extends StatelessWidget {
  const TopFlopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: appRouter,
    );
  }
}
