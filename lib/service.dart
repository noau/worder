import 'dart:developer';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tostore/tostore.dart';
import 'package:worder/entity/word_model.dart';

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
      await _db.update(tableName, word.toMap()).whereEqual(WordModel.colId, word.id);
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

  /// 获取当前 FSRS 到期需要复习的生词
  /// TODO：考虑改为 Stream API
  Future<List<WordModel>> getExpiredWords() async {
    throw UnimplementedError("`getExpiredWords` is not implemented yet.");
  }

  /// 获取全部收集的生词
  Future<List<WordModel>> getAllWords() async {
    throw UnimplementedError("`getAllWords` is not implemented yet.");
  }

  /// 删除生词
  Future<void> deleteWord(String id) async {
    throw UnimplementedError("`deleteWord` is not implemented yet.");
  }
}
