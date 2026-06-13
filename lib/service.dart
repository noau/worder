import 'package:tostore/tostore.dart';
import 'package:worder/entity/word_model.dart';

class WorderStorageService {
  late final ToStore _db;
  static const String _tableName = 'words';

  // 初始化数据库
  Future<void> init() async {
    _db = await ToStore.open();
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
