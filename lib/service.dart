import 'dart:developer';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tostore/tostore.dart';
import 'package:worder/entity/word_model.dart';

DateTime _todayLocalMidnight() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

DateTime _tomorrowLocalMidnight() {
  final t = _todayLocalMidnight();
  return DateTime(t.year, t.month, t.day + 1);
}

const wordSchema = TableSchema(
  name: WorderStorageService.tableName,
  primaryKeyConfig: PrimaryKeyConfig(
    name: WordModel.colId,
    type: PrimaryKeyType.none,
    isOrdered: false,
  ),
  fields: [
    FieldSchema(name: WordModel.colWord, type: DataType.text, nullable: false),
    FieldSchema(
      name: WordModel.colPinyin,
      type: DataType.text,
      nullable: false,
    ),
    FieldSchema(
      name: WordModel.colMeaning,
      type: DataType.text,
      nullable: false,
    ),
    FieldSchema(
      name: WordModel.colNotes,
      type: DataType.array,
      nullable: false,
    ),
    FieldSchema(
      name: WordModel.colFsrsCard,
      type: DataType.json,
      nullable: false,
    ),
    FieldSchema(
      name: WordModel.colCreateTimestamp,
      type: DataType.integer,
      nullable: false,
      createIndex: true,
    ),
    FieldSchema(
      name: WordModel.colDueTimestamp,
      type: DataType.integer,
      nullable: false,
      createIndex: true,
    ),
    FieldSchema(
      name: WordModel.colLastReviewTimestamp,
      type: DataType.integer,
      nullable: true,
      createIndex: true,
    ),
  ],
  indexes: [
    IndexSchema(
      indexName: 'idx_words_create', // 索引名，可选
      fields: [WordModel.colCreateTimestamp], // 复合索引字段列表
      unique: false, // 是否唯一索引
      type: IndexType.btree,
    ),
    IndexSchema(
      indexName: 'idx_words_last_review', // 索引名，可选
      fields: [WordModel.colLastReviewTimestamp], // 复合索引字段列表
      unique: false, // 是否唯一索引
      type: IndexType.btree,
    ),
    IndexSchema(
      indexName: 'idx_words_due', // 索引名，可选
      fields: [WordModel.colDueTimestamp], // 复合索引字段列表
      unique: false, // 是否唯一索引
      type: IndexType.btree,
    ),
  ],
);

class WorderStorageService {
  late final ToStore _db;
  static const String dbName = 'worder-db';
  static const String tableName = 'words';

  // 初始化数据库
  Future<void> init() async {
    final appDocsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(appDocsDir.path, "project-worder");
    log("Opening database `$dbName` at `$dbPath`");
    _db = await ToStore.open(
      dbPath: dbPath,
      dbName: dbName,
      schemas: [wordSchema],
      reinitialize: false,
      noPersistOnClose: false,
    );
  }

  Future<void> saveWord(WordModel word) async {
    final existing = await _db
        .query(tableName)
        .whereEqual(WordModel.colId, word.id)
        .limit(1);

    if (existing.isNotEmpty) {
      await _db
          .update(tableName, word.toMap())
          .whereEqual(WordModel.colId, word.id);
    } else {
      // 不存在则直接插入
      await _db.insert(tableName, word.toMap());
    }
  }

  /// 反应式订阅所有单词,按 create_timestamp 倒序(新→旧);UI 层首选入口。
  Stream<List<WordModel>> watchAllWords() {
    return _db
        .query(tableName)
        .orderByDesc(WordModel.colCreateTimestamp)
        .limit(1000)
        .watch()
        .map((maps) => maps.map(WordModel.fromMap).toList());
  }

  /// 反应式订阅 FSRS 到期需要复习的生词(due ≤ now,按 due 升序)。
  /// 计数与列表共用一个流(Dashboard 复用)。
  Stream<List<WordModel>> watchExpiredWords() {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    return _db
        .query(tableName)
        .whereLessThanOrEqualTo(WordModel.colDueTimestamp, nowMs)
        .orderByAsc(WordModel.colDueTimestamp)
        .limit(1000)
        .watch()
        .map((maps) => maps.map(WordModel.fromMap).toList());
  }

  /// 反应式订阅"今天"复习过的生词(last_review 在 [todayStart, tomorrowStart],
  /// tostore whereBetween 是闭区间)。
  /// day boundary 在订阅时确定一次;跨午夜不会自动刷新。
  /// TODO: 监听日期变化重订阅
  Stream<List<WordModel>> watchReviewedToday() {
    final s = _todayLocalMidnight().millisecondsSinceEpoch;
    final e = _tomorrowLocalMidnight().millisecondsSinceEpoch;
    return _db
        .query(tableName)
        .whereBetween(WordModel.colLastReviewTimestamp, s, e)
        .orderByDesc(WordModel.colLastReviewTimestamp)
        .limit(1000)
        .watch()
        .map((maps) => maps.map(WordModel.fromMap).toList());
  }

  /// 反应式订阅"今天"新学的生词(createAt 在 [todayStart, tomorrowStart])。
  /// TODO: 当 Learn session 流程落地后,改用 fsrsCard.state 转换或新增 learned_at 列。
  Stream<List<WordModel>> watchLearnedToday() {
    final s = _todayLocalMidnight().millisecondsSinceEpoch;
    final e = _tomorrowLocalMidnight().millisecondsSinceEpoch;
    return _db
        .query(tableName)
        .whereBetween(WordModel.colCreateTimestamp, s, e)
        .orderByDesc(WordModel.colCreateTimestamp)
        .limit(1000)
        .watch()
        .map((maps) => maps.map(WordModel.fromMap).toList());
  }

  /// 反应式订阅最近复习过的 [limit] 个生词(排除从未复习的)
  Stream<List<WordModel>> watchRecentlyReviewed({int limit = 20}) {
    return _db
        .query(tableName)
        .whereNotNull(WordModel.colLastReviewTimestamp)
        .orderByDesc(WordModel.colLastReviewTimestamp)
        .limit(limit)
        .watch()
        .map((maps) => maps.map(WordModel.fromMap).toList());
  }

  /// 获取当前 FSRS 到期需要复习的生词;目前无 in-tree 调用方。
  /// 实时订阅请用 [watchExpiredWords];此占位保留以备未来一次性调用。
  Future<List<WordModel>> getExpiredWords() async {
    throw UnimplementedError("`getExpiredWords` is not implemented yet.");
  }

  /// 获取全部收集的生词;目前无 in-tree 调用方。
  /// 实时订阅请用 [watchAllWords];此占位保留以备未来一次性调用。
  Future<List<WordModel>> getAllWords() async {
    throw UnimplementedError("`getAllWords` is not implemented yet.");
  }

  /// 删除生词
  Future<void> deleteWord(String id) async {
    throw UnimplementedError("`deleteWord` is not implemented yet.");
  }
}
