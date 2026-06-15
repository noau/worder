import 'package:fsrs/fsrs.dart' as fsrs;
import 'package:uuid/uuid.dart' as uuid;

class WordModel {
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
