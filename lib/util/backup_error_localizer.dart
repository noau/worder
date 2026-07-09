import 'package:flutter/widgets.dart';

import '../manager/backup_exception.dart';
import 'context_l10n.dart';

/// Resolve a structured [BackupException] to a localized user-facing
/// string.
///
/// The manager layer carries only data ([BackupErrorKind] +
/// optional `foundVersion` + optional `cause`) so it stays
/// locale-agnostic and unit-testable. The `BuildContext`-bound
/// resolution happens here, at the UI edge, where Flutter's
/// `AppLocalizations` is in scope. Mirrors the
/// `LlmErrorLocalizer` pattern.
class BackupErrorLocalizer {
  const BackupErrorLocalizer._();

  /// Map a [BackupException] to a localized string via
  /// `context.l10n.settingsBackupErrorXxx(...)`.
  static String localize(BuildContext context, BackupException e) {
    final l10n = context.l10n;
    switch (e.kind) {
      case BackupErrorKind.ioError:
        return l10n.settingsBackupErrorIo;
      case BackupErrorKind.zipCorrupted:
        return l10n.settingsBackupErrorZipCorrupted;
      case BackupErrorKind.manifestMissing:
        return l10n.settingsBackupErrorManifestMissing;
      case BackupErrorKind.manifestUnsupportedVersion:
        return l10n.settingsBackupErrorUnsupportedVersion(e.foundVersion ?? 0);
      case BackupErrorKind.databaseCorrupted:
        return l10n.settingsBackupErrorDatabaseCorrupted;
      case BackupErrorKind.preRestoreFailed:
        return l10n.settingsBackupErrorPreRestoreFailed;
      case BackupErrorKind.restoreFailed:
        return l10n.settingsBackupErrorRestoreFailed;
      case BackupErrorKind.unknown:
        // Defensive fallback for future code that throws `unknown`.
        return l10n.settingsBackupErrorGeneric(
          e.cause?.toString() ?? e.message,
        );
    }
  }
}
