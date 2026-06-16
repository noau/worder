import 'dart:async';
import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:fsrs/fsrs.dart' as fsrs;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:worder/config.dart';
import 'package:worder/entity/word_model.dart';

part 'database.g.dart';

DateTime _todayLocalMidnight() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

DateTime _tomorrowLocalMidnight() =>
    _todayLocalMidnight().add(Duration(days: 1));

enum WordState {
  learning,
  reviewing,
  relearning;

  factory WordState.fromFsrsState(fsrs.State state) => switch (state) {
    fsrs.State.learning => learning,
    fsrs.State.review => reviewing,
    fsrs.State.relearning => relearning,
  };

  fsrs.State toFsrsState() => switch (this) {
    WordState.learning => fsrs.State.learning,
    WordState.reviewing => fsrs.State.review,
    WordState.relearning => fsrs.State.relearning,
  };
}

extension WordEntryMappers on WordRow {
  WordModel toDomain() {
    return WordModel(
      id: id,
      word: word,
      pinyin: pinyin,
      meaning: meaning,
      notes: notes,
      fsrsCard: fsrsCard,
      createAt: createAt,
    );
  }
}

extension WordMappers on WordModel {
  WordRowsCompanion toDbCompanion() {
    return WordRowsCompanion.insert(
      id: id,
      word: word,
      pinyin: pinyin,
      meaning: meaning,
      notes: notes,
      fsrsCard: fsrsCard,
      createAt: createAt,
      // 在这里集中处理反规范化逻辑！
      state: WordState.fromFsrsState(fsrsCard.state),
      dueAt: fsrsCard.due,
      lastReviewAt: Value(fsrsCard.lastReview),
    );
  }
}

JsonTypeConverter2<fsrs.Card, String, Object?> fsrsCardConverter =
    TypeConverter.json2(
      fromJson: (json) => fsrs.Card.fromMap(json as Map<String, Object?>),
      toJson: (pref) => pref.toMap(),
    );

JsonTypeConverter2<List<String>, String, Object?> notesConverter =
    TypeConverter.json2(
      fromJson: (json) => List<String>.from(json as List<dynamic>),
      toJson: (notes) => notes,
    );

class WordRows extends Table {
  TextColumn get id => text()();

  TextColumn get word => text()();

  TextColumn get pinyin => text()();

  TextColumn get meaning => text()();

  TextColumn get notes => text().map(notesConverter)();

  IntColumn get state => intEnum<WordState>()();

  DateTimeColumn get createAt => dateTime()();

  DateTimeColumn get dueAt => dateTime()();

  DateTimeColumn get lastReviewAt => dateTime().nullable()();

  TextColumn get fsrsCard => text().map(fsrsCardConverter)();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

@DriftDatabase(tables: [WordRows])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (openingDetails) async {
      if (kDebugMode && debugDeleteAllDatabaseTables) {
        final m = createMigrator();
        for (final table in allTables) {
          await m.deleteTable(table.actualTableName);
          await m.createTable(table);
        }
      }
    },
  );

  static QueryExecutor _openConnection() {
    final db = driftDatabase(
      name: 'worder_database',
      native: DriftNativeOptions(
        databaseDirectory: () async => p.join(
          (await getApplicationDocumentsDirectory()).path,
          "project-worder",
        ),
      ),
    );
    if (debugDatabaseLogs) {
      return db.interceptWith(LogInterceptor());
    } else {
      return db;
    }
  }

  Future<int> saveWord(WordModel word) =>
      into(wordRows).insertOnConflictUpdate(word.toDbCompanion());

  /// Deletes [word] from the wordRows table by its primary key.
  ///
  /// Returns the number of rows affected. The `watchAllWords` stream will
  /// auto-emit a refreshed list, so callers don't need to refresh manually.
  Future<int> deleteWord(WordModel word) =>
      (delete(wordRows)..where((r) => r.id.equals(word.id))).go();

  Stream<List<WordModel>> watchAllWords() {
    return (select(wordRows)..orderBy([(r) => OrderingTerm.desc(r.createAt)]))
        .watch()
        .map((rows) => rows.map((row) => row.toDomain()).toList());
  }

  Stream<List<WordModel>> watchExpiredWords() {
    return (select(wordRows)
          ..where((r) => r.state.equals(WordState.reviewing.index))
          ..where((r) => r.dueAt.isSmallerOrEqual(currentDateAndTime))
          ..orderBy([(r) => OrderingTerm.asc(r.dueAt)]))
        .map((row) => row.toDomain())
        .watch();
  }

  Future<List<WordModel>> getExpiredWords({int limit = 20}) {
    return (select(wordRows)
          ..where((r) => r.state.equals(WordState.reviewing.index))
          ..where((r) => r.dueAt.isSmallerOrEqual(currentDateAndTime))
          ..orderBy([(r) => OrderingTerm.asc(r.dueAt)])
          ..limit(limit))
        .map((row) => row.toDomain())
        .get();
  }

  Stream<int> watchExpiredWordsCount() {
    // 1. 使用 selectOnly 纯计数，避免捞取整行数据
    final query = selectOnly(wordRows)
      ..addColumns([wordRows.id.count()])
      // 2. 保持完全相同的过滤条件
      ..where(wordRows.state.equals(WordState.reviewing.index))
      ..where(wordRows.dueAt.isSmallerOrEqual(currentDateAndTime));

    // 3. 监听单行结果，并将 count 值映射提取出来
    return query.watchSingle().map((row) {
      return row.read(wordRows.id.count()) ?? 0;
    });
  }

  Future<int> getExpiredWordsCount() {
    final query = selectOnly(wordRows)
      ..addColumns([wordRows.id.count()])
      ..where(wordRows.state.equals(WordState.reviewing.index))
      ..where(wordRows.dueAt.isSmallerOrEqual(currentDateAndTime));

    return query.getSingle().then((row) {
      return row.read(wordRows.id.count()) ?? 0;
    });
  }

  Stream<List<WordModel>> watchReviewedToday() {
    final start = _todayLocalMidnight();
    final end = _tomorrowLocalMidnight();
    return (select(wordRows)
          ..where((r) => r.lastReviewAt.isNotNull())
          ..where((r) => r.lastReviewAt.isBetweenValues(start, end))
          ..orderBy([(r) => OrderingTerm.desc(r.lastReviewAt)]))
        .map((row) => row.toDomain())
        .watch();
  }

  Stream<int> watchReviewedTodayCount() {
    final start = _todayLocalMidnight();
    final end = _tomorrowLocalMidnight();
    final query = selectOnly(wordRows)
      ..addColumns([countAll()]) // 或者使用 wordRows.id.count() 确保精确
      ..where(wordRows.lastReviewAt.isNotNull())
      ..where(wordRows.lastReviewAt.isBetweenValues(start, end));

    return query.watchSingle().map((row) {
      return row.read(countAll()) ?? 0;
    });
  }

  Stream<List<WordModel>> watchRecentlyReviewed({int limit = 20}) {
    return (select(wordRows)
          ..where((r) => r.lastReviewAt.isNotNull())
          ..orderBy([(r) => OrderingTerm.desc(r.lastReviewAt)])
          ..limit(limit))
        .map((row) => row.toDomain())
        .watch();
  }

  Future<List<WordModel>> getLearningWords({int limit = 10}) {
    return (select(wordRows)
          ..where(
            (r) =>
                r.state.equals(WordState.learning.index) |
                r.state.equals(WordState.relearning.index),
          )
          ..orderBy([(r) => OrderingTerm.asc(r.createAt)])
          ..limit(limit))
        .map((row) => row.toDomain())
        .get();
  }
}

class LogInterceptor extends QueryInterceptor {
  Future<T> _run<T>(
    String description,
    FutureOr<T> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();
    log('Running $description');

    try {
      final result = await operation();
      log(' => succeeded after ${stopwatch.elapsedMilliseconds}ms');
      return result;
    } on Object catch (e) {
      log(' => failed after ${stopwatch.elapsedMilliseconds}ms ($e)');
      rethrow;
    }
  }

  @override
  TransactionExecutor beginTransaction(QueryExecutor parent) {
    log('begin');
    return super.beginTransaction(parent);
  }

  @override
  Future<void> commitTransaction(TransactionExecutor inner) {
    return _run('commit', () => inner.send());
  }

  @override
  Future<void> rollbackTransaction(TransactionExecutor inner) {
    return _run('rollback', () => inner.rollback());
  }

  @override
  Future<void> runBatched(
    QueryExecutor executor,
    BatchedStatements statements,
  ) {
    return _run(
      'batch with $statements',
      () => executor.runBatched(statements),
    );
  }

  @override
  Future<int> runInsert(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    return _run(
      '$statement with $args',
      () => executor.runInsert(statement, args),
    );
  }

  @override
  Future<int> runUpdate(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    return _run(
      '$statement with $args',
      () => executor.runUpdate(statement, args),
    );
  }

  @override
  Future<int> runDelete(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    return _run(
      '$statement with $args',
      () => executor.runDelete(statement, args),
    );
  }

  @override
  Future<void> runCustom(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    return _run(
      '$statement with $args',
      () => executor.runCustom(statement, args),
    );
  }

  @override
  Future<List<Map<String, Object?>>> runSelect(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    return _run(
      '$statement with $args',
      () => executor.runSelect(statement, args),
    );
  }
}
