import 'package:fsrs/fsrs.dart' as fsrs;
import 'package:uuid/uuid.dart' as uuid;

class WordModel {
  static const colId = "id";
  static const colWord = "word";
  static const colPinyin = "pinyin";
  static const colMeaning = "meaning";
  static const colState = "state";
  static const colCreateTimestamp = "create_timestamp";
  static const colNotes = "notes";
  static const colFsrsCard = "fsrs_card";
  static const colDueTimestamp = "due_timestamp";
  static const colLastReviewTimestamp = "last_review_timestamp";

  // colState 默认值。需要 const 字面量(schema 是 const 表达式),
  // 因此不能直接写 fsrs.State.learning.value。该值必须与 fsrs.Card.create()
  // 的默认 state(State.learning == 1)保持一致。
  static const defaultStateValue = 1;

  final String id;
  final String word;
  final String pinyin;
  final String meaning;
  final DateTime createAt;
  final List<String> notes;
  final fsrs.Card fsrsCard;

  WordModel({
    required this.id,
    required this.word,
    required this.pinyin,
    required this.meaning,
    required this.createAt,
    required this.notes,
    required this.fsrsCard,
  });

  // 从 Tostore 的 Map 数据中恢复模型
  factory WordModel.fromMap(Map<String, dynamic> map) {
    // 无论是 KV 还是结构化查询，Tostore 吐出来的都是 Map
    final fsrsCard = fsrs.Card.fromMap(
      map[colFsrsCard] as Map<String, dynamic>,
    );
    final notes = map[colNotes] as List<dynamic>;

    return WordModel(
      id: map[colId] as String,
      word: map[colWord] as String,
      pinyin: map[colPinyin] as String,
      meaning: map[colMeaning] as String,
      createAt: DateTime.fromMillisecondsSinceEpoch(
        map[colCreateTimestamp] as int,
        isUtc: true,
      ),
      notes: List<String>.from(notes),
      fsrsCard: fsrsCard,
    );
  }

  // 转换为 Tostore 的存储 Map
  Map<String, dynamic> toMap() {
    return {
      colId: id,
      colWord: word,
      colPinyin: pinyin,
      colMeaning: meaning,
      colState: fsrsCard.state.value,
      colCreateTimestamp: createAt.millisecondsSinceEpoch,
      colNotes: notes,
      colFsrsCard: fsrsCard.toMap(),
      // 提取由于 FSRS 筛选必备的到期时间戳
      colDueTimestamp: fsrsCard.due.millisecondsSinceEpoch,
      colLastReviewTimestamp: fsrsCard.lastReview?.millisecondsSinceEpoch,
    };
  }

  WordModel copyWith({fsrs.Card? fsrsCard, List<String>? notes}) {
    return WordModel(
      id: id,
      word: word,
      pinyin: pinyin,
      meaning: meaning,
      createAt: createAt,
      notes: notes ?? this.notes,
      fsrsCard: fsrsCard ?? this.fsrsCard,
    );
  }

  static Future<WordModel> create({
    required String word,
    required String pinyin,
    required String meaning,
    required String note,
  }) async {
    return WordModel(
      id: uuid.Uuid().v4(),
      word: word,
      pinyin: pinyin,
      meaning: meaning,
      createAt: DateTime.now().toUtc(),
      notes: note.isEmpty ? const <String>[] : [note],
      fsrsCard: await fsrs.Card.create(),
    );
  }
}
