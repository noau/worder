import 'package:flutter/widgets.dart';
import 'package:worder/l10n/app_localizations.dart';

/// Sugar for `AppLocalizations.of(context)!`.
///
/// Use as `context.l10n.someKey` inside a `build` method instead of the more
/// verbose `AppLocalizations.of(context)!.someKey`. The `!` lives here, in one
/// place, so the call sites stay readable.
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
