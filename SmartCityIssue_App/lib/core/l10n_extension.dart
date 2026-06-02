import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Clean extension so you can use context.l10n.keyName in any widget
/// instead of AppLocalizations.of(context)!.keyName
extension L10nExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
