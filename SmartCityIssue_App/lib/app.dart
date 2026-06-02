import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';

import 'core/router.dart';
import 'core/theme.dart';
import 'providers/language_provider.dart';

class SmartCityApp extends ConsumerWidget {
  const SmartCityApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final language = ref.watch(languageProvider);

    return MaterialApp.router(
      title: 'SmartCity',
      debugShowCheckedModeBanner: false,

      // ── Localization ───────────────────────────────
      locale: language.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('kn'),
        Locale('hi'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ── Theme ──────────────────────────────────────
      theme: AppTheme.light,
      themeMode: ThemeMode.light,

      // ── Router ─────────────────────────────────────
      routerConfig: router,
    );
  }
}
