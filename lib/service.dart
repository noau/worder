import 'package:tostore/tostore.dart';
import 'package:worder/entity/word_model.dart';

const wordSchema = TableSchema(
  name: 'words',
  primaryKeyConfig: PrimaryKeyConfig(
    name: 'id',
    type: PrimaryKeyType.none,
    isOrdered: false,
  ),
  fields: [
    // FieldSchema(name: 'id', type: DataType.text, nullable: false, unique: true),
    FieldSchema(name: 'word', type: DataType.text, nullable: false),
    FieldSchema(name: 'pinyin', type: DataType.text, nullable: false),
    FieldSchema(name: 'meaning', type: DataType.text, nullable: false),
    FieldSchema(
      name: 'due_timestamp',
      type: DataType.integer,
      nullable: false,
      createIndex: true,
    ),
    FieldSchema(
      name: 'last_review_timestamp',
      type: DataType.integer,
      nullable: true,
      createIndex: true,
    ),
    FieldSchema(name: 'notes_json', type: DataType.text, nullable: false),
    FieldSchema(name: 'fsrs_card_json', type: DataType.text, nullable: false),
  ],
);

class WorderStorageService {
  late final ToStore _db;
  static const String _tableName = 'words';

  // 初始化数据库
  Future<void> init() async {
    _db = await ToStore.open(schemas: [wordSchema]);
  }

  Future<void> saveWord(WordModel word) async {
    final existing = await _db
        .query(_tableName)
        .whereEqual('id', word.id)
        .limit(1);

    if (existing.isNotEmpty) {
      await _db.update(_tableName, word.toMap()).whereEqual('id', word.id);
    } else {
      // 不存在则直接插入
      await _db.insert(_tableName, word.toMap());
    }
  }

  /// 反应式订阅所有单词,按 id 倒序(新→旧);UI 层首选入口。
  // NOTE: UUID v4 is not strictly time-ordered; in prototype scale (~hundreds of
  // words) the imperfection is imperceptible. Add WordModel.createdAt +
  // created_timestamp if/when ordering becomes visibly wrong.
  Stream<List<WordModel>> watchAllWords() {
    return _db
        .query(_tableName)
        .orderByDesc('id')
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
