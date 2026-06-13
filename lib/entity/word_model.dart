import 'dart:convert';

import 'package:fsrs/fsrs.dart' as fsrs;

class WordModel {
  final String id;
  final String word;
  final String pinyin;
  final String meaning;
  final List<String> notes;
  final fsrs.Card fsrsCard;

  WordModel({
    required this.id,
    required this.word,
    required this.pinyin,
    required this.meaning,
    required this.notes,
    required this.fsrsCard,
  });

  // 从 Tostore 的 Map 数据中恢复模型
  factory WordModel.fromMap(Map<String, dynamic> map) {
    // 无论是 KV 还是结构化查询，Tostore 吐出来的都是 Map
    final Map<String, dynamic> cardJson = jsonDecode(
      map['fsrs_card_json'] as String,
    );
    final List<dynamic> notesJson = jsonDecode(map['notes_json'] as String);

    return WordModel(
      id: map['id'] as String,
      word: map['word'] as String,
      pinyin: map['pinyin'] as String,
      meaning: map['meaning'] as String,
      notes: List<String>.from(notesJson),
      fsrsCard: _deserializeCard(cardJson),
    );
  }

  // 转换为 Tostore 的存储 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'pinyin': pinyin,
      'meaning': meaning,
      // 提取由于 FSRS 筛选必备的到期时间戳
      'due_timestamp': fsrsCard.due.millisecondsSinceEpoch,
      'notes_json': jsonEncode(notes),
      'fsrs_card_json': jsonEncode(_serializeCard(fsrsCard)),
    };
  }

  // --- FSRS 辅助序列化（保持一致） ---
  static fsrs.Card _deserializeCard(Map<String, dynamic> json) {
    return fsrs.Card.fromMap(json);
  }

  static Map<String, dynamic> _serializeCard(fsrs.Card card) {
    return card.toMap();
  }

  WordModel copyWith({fsrs.Card? fsrsCard, List<String>? notes}) {
    return WordModel(
      id: id,
      word: word,
      pinyin: pinyin,
      meaning: meaning,
      notes: notes ?? this.notes,
      fsrsCard: fsrsCard ?? this.fsrsCard,
    );
  }
}
