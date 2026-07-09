/// Reasons a [BackupManager] operation (export or restore) can fail.
///
/// Carried in [BackupException.kind] so the UI edge can map to a
/// localized string via `BackupErrorLocalizer.localize(...)`. New kinds
/// must be added to the switch in `BackupErrorLocalizer` AND to the
/// `settingsBackupError*` ARB key set.
enum BackupErrorKind {
  /// File I/O outside of zip corruption (read, write, rename, path
  /// provider failure).
  ioError,

  /// `ZipDecoder.decodeBytes` threw — file is not a valid zip or is
  /// truncated.
  zipCorrupted,

  /// Zip decoded but `manifest.json` is missing or not a JSON object.
  manifestMissing,

  /// `manifest.json` is present but `schemaVersion` does not match the
  /// version this build understands. The found version is carried in
  /// [BackupException.foundVersion].
  manifestUnsupportedVersion,

  /// `database.sqlite` is missing from the zip, or its first 16 bytes
  /// are not the SQLite magic header.
  databaseCorrupted,

  /// Pre-restore safety backup failed (disk full, permissions, …).
  /// Live data is untouched when this is thrown.
  preRestoreFailed,

  /// The DB swap succeeded but a follow-up step (prefs apply, drift
  /// lazy-reopen no-op query) failed. The pre-restore zip is the user's
  /// recovery path.
  restoreFailed,

  /// Anything not covered by the specific kinds above. Carries the
  /// original [Object] in [BackupException.cause].
  unknown,
}

/// Structured exception for backup / restore failures.
///
/// The manager layer stays locale-agnostic by carrying only data
/// (`kind`, optional `foundVersion`, optional `cause`); the UI edge
/// resolves to a localized string at render time.
///
/// **Pre-restore safety contract**: when [kind] is [BackupErrorKind.preRestoreFailed],
/// the live database and SharedPreferences are guaranteed untouched —
/// the restore was aborted before any write.
class BackupException implements Exception {
  const BackupException(
    this.kind, {
    this.message = '',
    this.foundVersion,
    this.cause,
  });

  final BackupErrorKind kind;

  /// Optional developer / log-facing message. Not user-facing —
  /// the UI uses `BackupErrorLocalizer.localize(...)`.
  final String message;

  /// Only set when [kind] is [BackupErrorKind.manifestUnsupportedVersion].
  final int? foundVersion;

  /// Underlying exception (e.g. `FileSystemException`, `FormatException`),
  /// if any. Logged in debug builds, never shown to the user directly.
  final Object? cause;

  @override
  String toString() =>
      'BackupException(${kind.name}'
      '${message.isEmpty ? '' : ': $message'}'
      '${foundVersion == null ? '' : ' [foundVersion=$foundVersion]'})';
}
