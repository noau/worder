import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' show countAll;
import 'package:fsrs/fsrs.dart' as fsrs;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database.dart';
import '../repository.dart';
import 'backup_exception.dart';

/// The metadata blob written as `manifest.json` at the root of every
/// backup zip. Increments the `currentSchemaVersion` when the layout
/// breaks; the importer rejects any other value.
class BackupManifest {
  BackupManifest({
    required this.schemaVersion,
    required this.appVersion,
    required this.exportedAtIso,
    required this.platform,
    required this.wordCount,
    required this.hasPrefs,
    required this.hasScheduler,
    required this.hasTheme,
  });

  /// Bump when the zip layout or any contained payload's shape changes
  /// in a non-backwards-compatible way. v1 = first release.
  static const int currentSchemaVersion = 1;

  final int schemaVersion;
  final String appVersion;

  /// ISO-8601 UTC, e.g. `2026-07-09T12:34:56.789Z`.
  final String exportedAtIso;

  /// `Platform.operatingSystem` at export time. Informational only —
  /// the importer does NOT validate this.
  final String platform;

  /// Snapshot of `wordRows` row count at export time. Informational;
  /// the importer does NOT fail on mismatch (the live DB may have drifted).
  final int wordCount;

  final bool hasPrefs;
  final bool hasScheduler;

  /// Theme is intentionally `false` in v1 — see plan "Known limitations".
  final bool hasTheme;

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'appVersion': appVersion,
    'exportedAt': exportedAtIso,
    'platform': platform,
    'wordCount': wordCount,
    'hasPrefs': hasPrefs,
    'hasScheduler': hasScheduler,
    'hasTheme': hasTheme,
  };

  factory BackupManifest.fromJson(Map<String, Object?> json) {
    final version = json['schemaVersion'];
    if (version is! int) {
      throw const BackupException(
        BackupErrorKind.manifestMissing,
        message: 'schemaVersion is not an int',
      );
    }
    final appVersion = json['appVersion'];
    final exportedAt = json['exportedAt'];
    final platform = json['platform'];
    final wordCount = json['wordCount'];
    final hasPrefs = json['hasPrefs'];
    final hasScheduler = json['hasScheduler'];
    final hasTheme = json['hasTheme'];
    if (appVersion is! String ||
        exportedAt is! String ||
        platform is! String ||
        wordCount is! int ||
        hasPrefs is! bool ||
        hasScheduler is! bool ||
        hasTheme is! bool) {
      throw const BackupException(
        BackupErrorKind.manifestMissing,
        message: 'manifest is missing required fields',
      );
    }
    return BackupManifest(
      schemaVersion: version,
      appVersion: appVersion,
      exportedAtIso: exportedAt,
      platform: platform,
      wordCount: wordCount,
      hasPrefs: hasPrefs,
      hasScheduler: hasScheduler,
      hasTheme: hasTheme,
    );
  }
}

/// What [BackupManager.restore] returns. The UI surfaces the
/// [preRestoreZipPath] in the "Restart recommended" dialog so the user
/// knows where the previous-state safety backup lives.
class RestoreResult {
  const RestoreResult({required this.preRestoreZipPath});

  /// Absolute path to the auto-created safety zip of the state that
  /// existed *before* the restore. Always written to
  /// `<AppDocuments>/project-worder/worder-backup-<ts>-pre-restore.zip`.
  final String preRestoreZipPath;
}

/// Orchestrates export (drift DB + SharedPreferences → single zip the
/// user picked) and restore (validate → pre-restore safety backup →
/// atomic DB swap → rewrite prefs).
///
/// Inline-construct at the call site (the Settings page); do NOT
/// register in `MultiProvider`. See CLAUDE.md *Manager Layer* for the
/// convention.
///
/// **Threading**: `ZipEncoder.encode` and `ZipDecoder.decodeBytes` are
/// CPU-bound; both run inside `Isolate.run()` so the UI stays
/// responsive for large databases. File I/O stays on the main isolate
/// (`dart:io` is already genuinely async).
class BackupManager {
  BackupManager({
    required AppDatabase appDatabase,
    required PreferencesRepository preferencesRepository,
    required SchedulerRepository schedulerRepository,
  }) : _db = appDatabase,
       _prefs = preferencesRepository,
       _scheduler = schedulerRepository;

  /// Hard-coded — read `pubspec.yaml`'s `version:` field at release
  /// time and update this string. We deliberately don't pull in
  /// `package_info_plus` for a single string. The build number (`+N`)
  /// is omitted because the backup format doesn't carry it.
  static const String _appVersion = '0.1.1';

  final AppDatabase _db;
  final PreferencesRepository _prefs;
  final SchedulerRepository _scheduler;

  /// SQLite magic header (first 16 bytes of every valid `.sqlite` file).
  /// Used to sanity-check the `database.sqlite` entry of an imported
  /// zip without actually opening it. Compared as raw bytes — the null
  /// terminator (`0x00`) at the end is part of the canonical header.
  static const List<int> _sqliteMagicBytes = <int>[
    0x53,
    0x51,
    0x4C,
    0x69,
    0x74,
    0x65,
    0x20,
    0x66,
    0x6F,
    0x72,
    0x6D,
    0x61,
    0x74,
    0x20,
    0x33,
    0x00,
  ];

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Export the current app state into [destinationPath]. Caller is
  /// responsible for prompting the user (via `file_picker.saveFile`).
  /// Returns the path written.
  Future<String> export({required String destinationPath}) async {
    final bytes = await _buildCurrentStateZipBytes();
    await File(destinationPath).writeAsBytes(bytes, flush: true);
    return destinationPath;
  }

  /// Restore app state from the zip at [sourcePath]. The flow is:
  ///   1. Validate the zip (decode, parse manifest, check SQLite magic).
  ///   2. Write a pre-restore safety backup of the CURRENT state into
  ///      `<AppDocuments>/project-worder/worder-backup-<ts>-pre-restore.zip`.
  ///      If this fails the restore is aborted — live data is untouched.
  ///   3. Close the [AppDatabase] so the underlying file handle is
  ///      released. On Windows, `drift_flutter`'s default VFS opens
  ///      the SQLite file without `FILE_SHARE_DELETE`, which blocks
  ///      any rename / delete / replace while the connection is held.
  ///      Linux / macOS don't need this step but it's harmless.
  ///   4. Atomically swap the SQLite file (rename to `.bak`, write new
  ///      bytes, on success delete `.bak`, on failure rename back).
  ///      WAL / SHM sidecars are renamed alongside.
  ///   5. Rewrite SharedPreferences keys (only those present in the
  ///      backup — target install keeps its own defaults for missing
  ///      keys).
  ///   6. The `LazyDatabase` re-establishes the connection on the next
  ///      `select` / `watch`, against the new file. The UI is
  ///      responsible for showing a "Restart recommended" dialog —
  ///      `Stream`s from `watchAllWords()` etc. hold references to
  ///      the old snapshot.
  Future<RestoreResult> restore({required String sourcePath}) async {
    // ---- 1. Validate --------------------------------------------------------
    final Map<String, Uint8List> files;
    try {
      final raw = await File(sourcePath).readAsBytes();
      files = await Isolate.run(() => _decodeZipToFileMap(raw));
    } on BackupException {
      rethrow;
    } on Object catch (e) {
      if (e is FormatException) {
        throw BackupException(
          BackupErrorKind.zipCorrupted,
          message: 'ZipDecoder threw FormatException',
          cause: e,
        );
      }
      throw BackupException(
        BackupErrorKind.ioError,
        message: 'Failed to read or decode backup file',
        cause: e,
      );
    }

    final manifestBytes = files['manifest.json'];
    if (manifestBytes == null) {
      throw const BackupException(BackupErrorKind.manifestMissing);
    }
    final Object? manifestJson;
    try {
      manifestJson = jsonDecode(utf8.decode(manifestBytes));
    } on Object catch (e) {
      throw BackupException(
        BackupErrorKind.manifestMissing,
        message: 'manifest.json is not valid JSON',
        cause: e,
      );
    }
    if (manifestJson is! Map<String, Object?>) {
      throw const BackupException(BackupErrorKind.manifestMissing);
    }
    final manifest = BackupManifest.fromJson(manifestJson);
    if (manifest.schemaVersion != BackupManifest.currentSchemaVersion) {
      throw BackupException(
        BackupErrorKind.manifestUnsupportedVersion,
        message:
            'found v${manifest.schemaVersion}, expected '
            'v${BackupManifest.currentSchemaVersion}',
        foundVersion: manifest.schemaVersion,
      );
    }

    final dbBytes = files['database.sqlite'];
    if (dbBytes == null) {
      throw const BackupException(BackupErrorKind.databaseCorrupted);
    }
    if (!_hasSqliteMagic(dbBytes)) {
      throw const BackupException(BackupErrorKind.databaseCorrupted);
    }

    // ---- 2. Pre-restore safety backup --------------------------------------
    final String safetyPath;
    try {
      safetyPath = await _writePreRestoreSafetyBackup();
    } on BackupException {
      rethrow;
    } on Object catch (e) {
      throw BackupException(
        BackupErrorKind.preRestoreFailed,
        message: 'Could not write the pre-restore safety backup',
        cause: e,
      );
    }

    // ---- 3. Close the DB so we can rename the file on Windows -------------
    // `drift_flutter`'s default VFS opens the SQLite file without
    // `FILE_SHARE_DELETE`; while a connection is held, Windows blocks
    // rename / delete / replace on the underlying file with
    // `ERROR_SHARING_VIOLATION`. Closing first releases the handle so
    // the atomic swap can proceed. On Linux / macOS this is a no-op
    // (the rename would have worked either way).
    try {
      await _db.close();
    } on Object catch (e) {
      // Surface as a hard error — proceeding with the swap would just
      // hit the same Windows sharing violation with a less informative
      // message.
      throw BackupException(
        BackupErrorKind.restoreFailed,
        message: 'Could not close database before restore swap',
        cause: e,
      );
    }

    // ---- 4. Atomic DB swap -------------------------------------------------
    try {
      await _atomicSwapDatabase(dbBytes);
    } on Object catch (e) {
      throw BackupException(
        BackupErrorKind.restoreFailed,
        message: 'Atomic DB swap failed',
        cause: e,
      );
    }

    // ---- 4. Rewrite prefs and scheduler (live; no restart needed) --------
    await _applyOptionalRestoredEntry(
      present: manifest.hasPrefs,
      bytes: files['preferences.json'],
      missingMessage: 'manifest.hasPrefs=true but preferences.json missing',
      apply: _applyRestoredPrefs,
      applyFailureMessage: 'Failed to apply restored preferences',
    );
    await _applyOptionalRestoredEntry(
      present: manifest.hasScheduler,
      bytes: files['scheduler.json'],
      missingMessage: 'manifest.hasScheduler=true but scheduler.json missing',
      apply: _applyRestoredScheduler,
      applyFailureMessage: 'Failed to apply restored scheduler',
    );

    return RestoreResult(preRestoreZipPath: safetyPath);
  }

  /// Returns the canonical SQLite file path the [AppDatabase] uses.
  /// Exposed for diagnostics and the test-suite seam; production code
  /// only needs `export` and `restore`.
  Future<String> databaseFilePath() async {
    final docs = await getApplicationDocumentsDirectory();
    return p.join(docs.path, 'project-worder', 'worder_database.sqlite');
  }

  // ---------------------------------------------------------------------------
  // Export-side helpers
  // ---------------------------------------------------------------------------

  /// Build the zip bytes for the current app state (DB + prefs +
  /// scheduler + manifest). The `ZipEncoder.encode` call runs in a
  /// background isolate so the UI stays responsive for large DBs.
  Future<List<int>> _buildCurrentStateZipBytes() async {
    final dbBytes = await _readDatabaseBytes();
    final prefsJson = _gatherPreferencesJson();
    final schedulerJson = _gatherSchedulerJson();
    final wordCount = await _countWords();

    final manifest = BackupManifest(
      schemaVersion: BackupManifest.currentSchemaVersion,
      appVersion: _appVersion,
      exportedAtIso: DateTime.now().toUtc().toIso8601String(),
      platform: Platform.operatingSystem,
      wordCount: wordCount,
      hasPrefs: prefsJson != null,
      hasScheduler: schedulerJson != null,
      hasTheme: false,
    );

    final prefsMap = prefsJson ?? <String, Object?>{};
    final schedulerMap = schedulerJson ?? <String, Object?>{};

    final manifestJson = utf8.encode(jsonEncode(manifest.toJson()));
    final prefsJsonBytes = prefsJson == null
        ? null
        : utf8.encode(jsonEncode(prefsMap));
    final schedulerJsonBytes = schedulerJson == null
        ? null
        : utf8.encode(jsonEncode(schedulerMap));

    // Encode off the main isolate. The Archive itself is built on the
    // main isolate (its file list is small) and only the zip encode
    // moves to a worker.
    return Isolate.run(() {
      final archive = Archive();
      archive.addFile(
        ArchiveFile('manifest.json', manifestJson.length, manifestJson),
      );
      archive.addFile(ArchiveFile('database.sqlite', dbBytes.length, dbBytes));
      if (prefsJsonBytes != null) {
        archive.addFile(
          ArchiveFile(
            'preferences.json',
            prefsJsonBytes.length,
            prefsJsonBytes,
          ),
        );
      }
      if (schedulerJsonBytes != null) {
        archive.addFile(
          ArchiveFile(
            'scheduler.json',
            schedulerJsonBytes.length,
            schedulerJsonBytes,
          ),
        );
      }
      return ZipEncoder().encode(archive);
    });
  }

  Future<List<int>> _readDatabaseBytes() async {
    final path = await databaseFilePath();
    return File(path).readAsBytes();
  }

  Future<int> _countWords() async {
    // `countAll()` is a constant Expression<int> that drifts generates
    // for every table — simpler than `wordRows.id.count()` and avoids
    // relying on the column type to expose the aggregate.
    final query = _db.selectOnly(_db.wordRows)..addColumns([countAll()]);
    final row = await query.getSingle();
    return row.read(countAll()) ?? 0;
  }

  /// Snapshot the SharedPreferences keys this app owns. Returns `null`
  /// when none of the keys have been written yet (first launch) so the
  /// manifest's `hasPrefs` stays `false` and the file isn't included.
  Map<String, Object?>? _gatherPreferencesJson() {
    final sp = _prefs.preferences;
    final llmRaw = sp.getString('LLM_CONFIG');
    final days = sp.getInt('DAYS_LEARNT');
    final last = sp.getString('LAST_LEARNT_DAY');

    if (llmRaw == null && days == null && last == null) {
      return null;
    }

    return <String, Object?>{
      'LLM_CONFIG': llmRaw == null ? null : jsonDecode(llmRaw),
      'DAYS_LEARNT': days,
      'LAST_LEARNT_DAY': last,
    };
  }

  /// Snapshot the fsrs scheduler. Returns `null` when it hasn't been
  /// saved yet (first launch), in which case the file is omitted.
  Map<String, Object?>? _gatherSchedulerJson() {
    final sp = _scheduler.preferences;
    final raw = sp.getString('fsrs.scheduler');
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, Object?>) return null;
    return decoded;
  }

  // ---------------------------------------------------------------------------
  // Restore-side helpers
  // ---------------------------------------------------------------------------

  /// Decode a zip and return its contents as a flat `name → bytes` map.
  /// Runs in a worker isolate. The `Archive` object itself is not
  /// shipped across the isolate boundary — only its `Uint8List` payload.
  static Map<String, Uint8List> _decodeZipToFileMap(Uint8List raw) {
    final archive = ZipDecoder().decodeBytes(raw);
    return <String, Uint8List>{
      for (final file in archive)
        file.name: Uint8List.fromList(file.content as List<int>),
    };
  }

  bool _hasSqliteMagic(Uint8List bytes) {
    if (bytes.length < _sqliteMagicBytes.length) return false;
    for (var i = 0; i < _sqliteMagicBytes.length; i++) {
      if (bytes[i] != _sqliteMagicBytes[i]) return false;
    }
    return true;
  }

  /// Write a safety backup of the CURRENT state into
  /// `<AppDocuments>/project-worder/worder-backup-<ts>-pre-restore.zip`.
  /// Reuses [_buildCurrentStateZipBytes] so the safety backup is byte-
  /// compatible with a user-initiated export.
  Future<String> _writePreRestoreSafetyBackup() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'project-worder'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final ts = _timestampCompact();
    final path = p.join(dir.path, 'worder-backup-$ts-pre-restore.zip');
    final bytes = await _buildCurrentStateZipBytes();
    await File(path).writeAsBytes(bytes, flush: true);
    return path;
  }

  /// Rename `<db>.sqlite` → `<db>.sqlite.bak`, write new bytes, on
  /// success delete `.bak`, on failure rename back. WAL and SHM sidecars
  /// follow the same swap so a partially-restored DB doesn't crash on
  /// next open.
  Future<void> _atomicSwapDatabase(Uint8List newBytes) async {
    final dbPath = await databaseFilePath();
    final dbFile = File(dbPath);
    final walFile = File('$dbPath-wal');
    final shmFile = File('$dbPath-shm');

    final dbBak = File('$dbPath.bak');
    final walBak = File('$dbPath-wal.bak');
    final shmBak = File('$dbPath-shm.bak');

    // Step 1: rename current files aside (.bak). Missing sidecars are
    // normal on a freshly-opened DB and are simply skipped.
    if (await dbFile.exists()) {
      await dbFile.rename(dbBak.path);
    }
    final hadWal = await walFile.exists();
    if (hadWal) await walFile.rename(walBak.path);
    final hadShm = await shmFile.exists();
    if (hadShm) await shmFile.rename(shmBak.path);

    // Step 2: write the new main file. If this fails, restore the .bak
    // copies so the live DB stays intact.
    try {
      await dbFile.writeAsBytes(newBytes, flush: true);
    } on Object {
      await _rollbackBak(dbBak, dbFile, walBak, walFile, hadWal);
      await _rollbackBak(shmBak, shmFile, null, null, hadShm);
      rethrow;
    }

    // Step 3: write succeeded — drop the .bak copies.
    if (await dbBak.exists()) await dbBak.delete();
    if (hadWal && await walBak.exists()) await walBak.delete();
    if (hadShm && await shmBak.exists()) await shmBak.delete();
  }

  /// Helper for [_atomicSwapDatabase] rollback: rename `bak` back to
  /// `original` if it exists. The `.bak` cleanup runs once per
  /// `_atomicSwapDatabase` call site so we don't double-delete.
  Future<void> _rollbackBak(
    File bak,
    File original,
    File? walBak,
    File? walOriginal,
    bool hadWal,
  ) async {
    if (await bak.exists()) {
      await bak.rename(original.path);
    }
    if (hadWal && walBak != null && walOriginal != null) {
      if (await walBak.exists()) await walBak.rename(walOriginal.path);
    }
  }

  /// Shared shape for the two `hasPrefs` / `hasScheduler` branches in
  /// [restore]: when [present], apply [apply] to [bytes] (which may be
  /// `null`); missing bytes → `BackupErrorKind.ioError` with
  /// [missingMessage]; apply failure → `BackupErrorKind.restoreFailed`
  /// with [applyFailureMessage]. Lets both branches share one
  /// error-translation site instead of duplicating the wrap.
  static Future<void> _applyOptionalRestoredEntry({
    required bool present,
    required Uint8List? bytes,
    required String missingMessage,
    required Future<void> Function(Uint8List bytes) apply,
    required String applyFailureMessage,
  }) async {
    if (!present) return;
    if (bytes == null) {
      throw BackupException(
        BackupErrorKind.ioError,
        message: missingMessage,
      );
    }
    try {
      await apply(bytes);
    } on BackupException {
      rethrow;
    } on Object catch (e) {
      throw BackupException(
        BackupErrorKind.restoreFailed,
        message: applyFailureMessage,
        cause: e,
      );
    }
  }

  Future<void> _applyRestoredPrefs(Uint8List bytes) async {
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map) return;
    final sp = await SharedPreferences.getInstance();
    // Force a reload so we don't shadow any in-memory stale values.
    await sp.reload();

    final llmConfig = decoded['LLM_CONFIG'];
    if (llmConfig != null) {
      await sp.setString('LLM_CONFIG', jsonEncode(llmConfig));
    }
    // A literal null means "key was absent in the backup" — we only
    // write back keys that have a real value.
    if (decoded.containsKey('DAYS_LEARNT') && decoded['DAYS_LEARNT'] is int) {
      await sp.setInt('DAYS_LEARNT', decoded['DAYS_LEARNT'] as int);
    }
    if (decoded.containsKey('LAST_LEARNT_DAY') &&
        decoded['LAST_LEARNT_DAY'] is String) {
      await sp.setString(
        'LAST_LEARNT_DAY',
        decoded['LAST_LEARNT_DAY'] as String,
      );
    }
  }

  Future<void> _applyRestoredScheduler(Uint8List bytes) async {
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map<String, Object?>) return;
    // Mutate in-memory so the rest of the app picks it up immediately
    // (Pages read `_scheduler.scheduler` directly).
    _scheduler.scheduler = fsrs.Scheduler.fromMap(decoded);
    await _scheduler.saveScheduler();
  }

  // ---------------------------------------------------------------------------
  // Misc
  // ---------------------------------------------------------------------------

  static String _timestampCompact() {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${now.year}${two(now.month)}${two(now.day)}-'
        '${two(now.hour)}${two(now.minute)}${two(now.second)}';
  }
}
