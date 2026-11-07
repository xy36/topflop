import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../data/providers.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';

class TopFlopApp extends ConsumerWidget {
  const TopFlopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(themeModeProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: appRouter,
      // Statusleiste passend zum Modus (die Seiten haben keine AppBar).
      builder: (context, child) =>
          AnnotatedRegion<SystemUiOverlayStyle>(value: AppTheme.overlayStyle(context.colors), child: child!),
    );
  }
}
