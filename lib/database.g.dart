// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $WordRowsTable extends WordRows with TableInfo<$WordRowsTable, WordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
    'word',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pinyinMeta = const VerificationMeta('pinyin');
  @override
  late final GeneratedColumn<String> pinyin = GeneratedColumn<String>(
    'pinyin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meaningMeta = const VerificationMeta(
    'meaning',
  );
  @override
  late final GeneratedColumn<String> meaning = GeneratedColumn<String>(
    'meaning',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> notes =
      GeneratedColumn<String>(
        'notes',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($WordRowsTable.$converternotes);
  @override
  late final GeneratedColumnWithTypeConverter<WordState, int> state =
      GeneratedColumn<int>(
        'state',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<WordState>($WordRowsTable.$converterstate);
  static const VerificationMeta _createAtMeta = const VerificationMeta(
    'createAt',
  );
  @override
  late final GeneratedColumn<DateTime> createAt = GeneratedColumn<DateTime>(
    'create_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastReviewAtMeta = const VerificationMeta(
    'lastReviewAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastReviewAt = GeneratedColumn<DateTime>(
    'last_review_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<fsrs.Card, String> fsrsCard =
      GeneratedColumn<String>(
        'fsrs_card',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<fsrs.Card>($WordRowsTable.$converterfsrsCard);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    word,
    pinyin,
    meaning,
    notes,
    state,
    createAt,
    dueAt,
    lastReviewAt,
    fsrsCard,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('word')) {
      context.handle(
        _wordMeta,
        word.isAcceptableOrUnknown(data['word']!, _wordMeta),
      );
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('pinyin')) {
      context.handle(
        _pinyinMeta,
        pinyin.isAcceptableOrUnknown(data['pinyin']!, _pinyinMeta),
      );
    } else if (isInserting) {
      context.missing(_pinyinMeta);
    }
    if (data.containsKey('meaning')) {
      context.handle(
        _meaningMeta,
        meaning.isAcceptableOrUnknown(data['meaning']!, _meaningMeta),
      );
    } else if (isInserting) {
      context.missing(_meaningMeta);
    }
    if (data.containsKey('create_at')) {
      context.handle(
        _createAtMeta,
        createAt.isAcceptableOrUnknown(data['create_at']!, _createAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createAtMeta);
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    } else if (isInserting) {
      context.missing(_dueAtMeta);
    }
    if (data.containsKey('last_review_at')) {
      context.handle(
        _lastReviewAtMeta,
        lastReviewAt.isAcceptableOrUnknown(
          data['last_review_at']!,
          _lastReviewAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      word: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word'],
      )!,
      pinyin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pinyin'],
      )!,
      meaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning'],
      )!,
      notes: $WordRowsTable.$converternotes.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}notes'],
        )!,
      ),
      state: $WordRowsTable.$converterstate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}state'],
        )!,
      ),
      createAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}create_at'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      )!,
      lastReviewAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_review_at'],
      ),
      fsrsCard: $WordRowsTable.$converterfsrsCard.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}fsrs_card'],
        )!,
      ),
    );
  }

  @override
  $WordRowsTable createAlias(String alias) {
    return $WordRowsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<List<String>, String, Object?> $converternotes =
      notesConverter;
  static JsonTypeConverter2<WordState, int, int> $converterstate =
      const EnumIndexConverter<WordState>(WordState.values);
  static JsonTypeConverter2<fsrs.Card, String, Object?> $converterfsrsCard =
      fsrsCardConverter;
}

class WordRow extends DataClass implements Insertable<WordRow> {
  final String id;
  final String word;
  final String pinyin;
  final String meaning;
  final List<String> notes;
  final WordState state;
  final DateTime createAt;
  final DateTime dueAt;
  final DateTime? lastReviewAt;
  final fsrs.Card fsrsCard;
  const WordRow({
    required this.id,
    required this.word,
    required this.pinyin,
    required this.meaning,
    required this.notes,
    required this.state,
    required this.createAt,
    required this.dueAt,
    this.lastReviewAt,
    required this.fsrsCard,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['word'] = Variable<String>(word);
    map['pinyin'] = Variable<String>(pinyin);
    map['meaning'] = Variable<String>(meaning);
    {
      map['notes'] = Variable<String>(
        $WordRowsTable.$converternotes.toSql(notes),
      );
    }
    {
      map['state'] = Variable<int>($WordRowsTable.$converterstate.toSql(state));
    }
    map['create_at'] = Variable<DateTime>(createAt);
    map['due_at'] = Variable<DateTime>(dueAt);
    if (!nullToAbsent || lastReviewAt != null) {
      map['last_review_at'] = Variable<DateTime>(lastReviewAt);
    }
    {
      map['fsrs_card'] = Variable<String>(
        $WordRowsTable.$converterfsrsCard.toSql(fsrsCard),
      );
    }
    return map;
  }

  WordRowsCompanion toCompanion(bool nullToAbsent) {
    return WordRowsCompanion(
      id: Value(id),
      word: Value(word),
      pinyin: Value(pinyin),
      meaning: Value(meaning),
      notes: Value(notes),
      state: Value(state),
      createAt: Value(createAt),
      dueAt: Value(dueAt),
      lastReviewAt: lastReviewAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewAt),
      fsrsCard: Value(fsrsCard),
    );
  }

  factory WordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordRow(
      id: serializer.fromJson<String>(json['id']),
      word: serializer.fromJson<String>(json['word']),
      pinyin: serializer.fromJson<String>(json['pinyin']),
      meaning: serializer.fromJson<String>(json['meaning']),
      notes: $WordRowsTable.$converternotes.fromJson(
        serializer.fromJson<Object?>(json['notes']),
      ),
      state: $WordRowsTable.$converterstate.fromJson(
        serializer.fromJson<int>(json['state']),
      ),
      createAt: serializer.fromJson<DateTime>(json['createAt']),
      dueAt: serializer.fromJson<DateTime>(json['dueAt']),
      lastReviewAt: serializer.fromJson<DateTime?>(json['lastReviewAt']),
      fsrsCard: $WordRowsTable.$converterfsrsCard.fromJson(
        serializer.fromJson<Object?>(json['fsrsCard']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'word': serializer.toJson<String>(word),
      'pinyin': serializer.toJson<String>(pinyin),
      'meaning': serializer.toJson<String>(meaning),
      'notes': serializer.toJson<Object?>(
        $WordRowsTable.$converternotes.toJson(notes),
      ),
      'state': serializer.toJson<int>(
        $WordRowsTable.$converterstate.toJson(state),
      ),
      'createAt': serializer.toJson<DateTime>(createAt),
      'dueAt': serializer.toJson<DateTime>(dueAt),
      'lastReviewAt': serializer.toJson<DateTime?>(lastReviewAt),
      'fsrsCard': serializer.toJson<Object?>(
        $WordRowsTable.$converterfsrsCard.toJson(fsrsCard),
      ),
    };
  }

  WordRow copyWith({
    String? id,
    String? word,
    String? pinyin,
    String? meaning,
    List<String>? notes,
    WordState? state,
    DateTime? createAt,
    DateTime? dueAt,
    Value<DateTime?> lastReviewAt = const Value.absent(),
    fsrs.Card? fsrsCard,
  }) => WordRow(
    id: id ?? this.id,
    word: word ?? this.word,
    pinyin: pinyin ?? this.pinyin,
    meaning: meaning ?? this.meaning,
    notes: notes ?? this.notes,
    state: state ?? this.state,
    createAt: createAt ?? this.createAt,
    dueAt: dueAt ?? this.dueAt,
    lastReviewAt: lastReviewAt.present ? lastReviewAt.value : this.lastReviewAt,
    fsrsCard: fsrsCard ?? this.fsrsCard,
  );
  WordRow copyWithCompanion(WordRowsCompanion data) {
    return WordRow(
      id: data.id.present ? data.id.value : this.id,
      word: data.word.present ? data.word.value : this.word,
      pinyin: data.pinyin.present ? data.pinyin.value : this.pinyin,
      meaning: data.meaning.present ? data.meaning.value : this.meaning,
      notes: data.notes.present ? data.notes.value : this.notes,
      state: data.state.present ? data.state.value : this.state,
      createAt: data.createAt.present ? data.createAt.value : this.createAt,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      lastReviewAt: data.lastReviewAt.present
          ? data.lastReviewAt.value
          : this.lastReviewAt,
      fsrsCard: data.fsrsCard.present ? data.fsrsCard.value : this.fsrsCard,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordRow(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('pinyin: $pinyin, ')
          ..write('meaning: $meaning, ')
          ..write('notes: $notes, ')
          ..write('state: $state, ')
          ..write('createAt: $createAt, ')
          ..write('dueAt: $dueAt, ')
          ..write('lastReviewAt: $lastReviewAt, ')
          ..write('fsrsCard: $fsrsCard')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    word,
    pinyin,
    meaning,
    notes,
    state,
    createAt,
    dueAt,
    lastReviewAt,
    fsrsCard,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordRow &&
          other.id == this.id &&
          other.word == this.word &&
          other.pinyin == this.pinyin &&
          other.meaning == this.meaning &&
          other.notes == this.notes &&
          other.state == this.state &&
          other.createAt == this.createAt &&
          other.dueAt == this.dueAt &&
          other.lastReviewAt == this.lastReviewAt &&
          other.fsrsCard == this.fsrsCard);
}

class WordRowsCompanion extends UpdateCompanion<WordRow> {
  final Value<String> id;
  final Value<String> word;
  final Value<String> pinyin;
  final Value<String> meaning;
  final Value<List<String>> notes;
  final Value<WordState> state;
  final Value<DateTime> createAt;
  final Value<DateTime> dueAt;
  final Value<DateTime?> lastReviewAt;
  final Value<fsrs.Card> fsrsCard;
  final Value<int> rowid;
  const WordRowsCompanion({
    this.id = const Value.absent(),
    this.word = const Value.absent(),
    this.pinyin = const Value.absent(),
    this.meaning = const Value.absent(),
    this.notes = const Value.absent(),
    this.state = const Value.absent(),
    this.createAt = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.lastReviewAt = const Value.absent(),
    this.fsrsCard = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WordRowsCompanion.insert({
    required String id,
    required String word,
    required String pinyin,
    required String meaning,
    required List<String> notes,
    required WordState state,
    required DateTime createAt,
    required DateTime dueAt,
    this.lastReviewAt = const Value.absent(),
    required fsrs.Card fsrsCard,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       word = Value(word),
       pinyin = Value(pinyin),
       meaning = Value(meaning),
       notes = Value(notes),
       state = Value(state),
       createAt = Value(createAt),
       dueAt = Value(dueAt),
       fsrsCard = Value(fsrsCard);
  static Insertable<WordRow> custom({
    Expression<String>? id,
    Expression<String>? word,
    Expression<String>? pinyin,
    Expression<String>? meaning,
    Expression<String>? notes,
    Expression<int>? state,
    Expression<DateTime>? createAt,
    Expression<DateTime>? dueAt,
    Expression<DateTime>? lastReviewAt,
    Expression<String>? fsrsCard,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (word != null) 'word': word,
      if (pinyin != null) 'pinyin': pinyin,
      if (meaning != null) 'meaning': meaning,
      if (notes != null) 'notes': notes,
      if (state != null) 'state': state,
      if (createAt != null) 'create_at': createAt,
      if (dueAt != null) 'due_at': dueAt,
      if (lastReviewAt != null) 'last_review_at': lastReviewAt,
      if (fsrsCard != null) 'fsrs_card': fsrsCard,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WordRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? word,
    Value<String>? pinyin,
    Value<String>? meaning,
    Value<List<String>>? notes,
    Value<WordState>? state,
    Value<DateTime>? createAt,
    Value<DateTime>? dueAt,
    Value<DateTime?>? lastReviewAt,
    Value<fsrs.Card>? fsrsCard,
    Value<int>? rowid,
  }) {
    return WordRowsCompanion(
      id: id ?? this.id,
      word: word ?? this.word,
      pinyin: pinyin ?? this.pinyin,
      meaning: meaning ?? this.meaning,
      notes: notes ?? this.notes,
      state: state ?? this.state,
      createAt: createAt ?? this.createAt,
      dueAt: dueAt ?? this.dueAt,
      lastReviewAt: lastReviewAt ?? this.lastReviewAt,
      fsrsCard: fsrsCard ?? this.fsrsCard,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (pinyin.present) {
      map['pinyin'] = Variable<String>(pinyin.value);
    }
    if (meaning.present) {
      map['meaning'] = Variable<String>(meaning.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(
        $WordRowsTable.$converternotes.toSql(notes.value),
      );
    }
    if (state.present) {
      map['state'] = Variable<int>(
        $WordRowsTable.$converterstate.toSql(state.value),
      );
    }
    if (createAt.present) {
      map['create_at'] = Variable<DateTime>(createAt.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (lastReviewAt.present) {
      map['last_review_at'] = Variable<DateTime>(lastReviewAt.value);
    }
    if (fsrsCard.present) {
      map['fsrs_card'] = Variable<String>(
        $WordRowsTable.$converterfsrsCard.toSql(fsrsCard.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordRowsCompanion(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('pinyin: $pinyin, ')
          ..write('meaning: $meaning, ')
          ..write('notes: $notes, ')
          ..write('state: $state, ')
          ..write('createAt: $createAt, ')
          ..write('dueAt: $dueAt, ')
          ..write('lastReviewAt: $lastReviewAt, ')
          ..write('fsrsCard: $fsrsCard, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WordRowsTable wordRows = $WordRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [wordRows];
}

typedef $$WordRowsTableCreateCompanionBuilder =
    WordRowsCompanion Function({
      required String id,
      required String word,
      required String pinyin,
      required String meaning,
      required List<String> notes,
      required WordState state,
      required DateTime createAt,
      required DateTime dueAt,
      Value<DateTime?> lastReviewAt,
      required fsrs.Card fsrsCard,
      Value<int> rowid,
    });
typedef $$WordRowsTableUpdateCompanionBuilder =
    WordRowsCompanion Function({
      Value<String> id,
      Value<String> word,
      Value<String> pinyin,
      Value<String> meaning,
      Value<List<String>> notes,
      Value<WordState> state,
      Value<DateTime> createAt,
      Value<DateTime> dueAt,
      Value<DateTime?> lastReviewAt,
      Value<fsrs.Card> fsrsCard,
      Value<int> rowid,
    });

class $$WordRowsTableFilterComposer
    extends Composer<_$AppDatabase, $WordRowsTable> {
  $$WordRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinyin => $composableBuilder(
    column: $table.pinyin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<WordState, WordState, int> get state =>
      $composableBuilder(
        column: $table.state,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createAt => $composableBuilder(
    column: $table.createAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReviewAt => $composableBuilder(
    column: $table.lastReviewAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<fsrs.Card, fsrs.Card, String> get fsrsCard =>
      $composableBuilder(
        column: $table.fsrsCard,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$WordRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordRowsTable> {
  $$WordRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinyin => $composableBuilder(
    column: $table.pinyin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createAt => $composableBuilder(
    column: $table.createAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReviewAt => $composableBuilder(
    column: $table.lastReviewAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fsrsCard => $composableBuilder(
    column: $table.fsrsCard,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WordRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordRowsTable> {
  $$WordRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get pinyin =>
      $composableBuilder(column: $table.pinyin, builder: (column) => column);

  GeneratedColumn<String> get meaning =>
      $composableBuilder(column: $table.meaning, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumnWithTypeConverter<WordState, int> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<DateTime> get createAt =>
      $composableBuilder(column: $table.createAt, builder: (column) => column);

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReviewAt => $composableBuilder(
    column: $table.lastReviewAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<fsrs.Card, String> get fsrsCard =>
      $composableBuilder(column: $table.fsrsCard, builder: (column) => column);
}

class $$WordRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordRowsTable,
          WordRow,
          $$WordRowsTableFilterComposer,
          $$WordRowsTableOrderingComposer,
          $$WordRowsTableAnnotationComposer,
          $$WordRowsTableCreateCompanionBuilder,
          $$WordRowsTableUpdateCompanionBuilder,
          (WordRow, BaseReferences<_$AppDatabase, $WordRowsTable, WordRow>),
          WordRow,
          PrefetchHooks Function()
        > {
  $$WordRowsTableTableManager(_$AppDatabase db, $WordRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> word = const Value.absent(),
                Value<String> pinyin = const Value.absent(),
                Value<String> meaning = const Value.absent(),
                Value<List<String>> notes = const Value.absent(),
                Value<WordState> state = const Value.absent(),
                Value<DateTime> createAt = const Value.absent(),
                Value<DateTime> dueAt = const Value.absent(),
                Value<DateTime?> lastReviewAt = const Value.absent(),
                Value<fsrs.Card> fsrsCard = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WordRowsCompanion(
                id: id,
                word: word,
                pinyin: pinyin,
                meaning: meaning,
                notes: notes,
                state: state,
                createAt: createAt,
                dueAt: dueAt,
                lastReviewAt: lastReviewAt,
                fsrsCard: fsrsCard,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String word,
                required String pinyin,
                required String meaning,
                required List<String> notes,
                required WordState state,
                required DateTime createAt,
                required DateTime dueAt,
                Value<DateTime?> lastReviewAt = const Value.absent(),
                required fsrs.Card fsrsCard,
                Value<int> rowid = const Value.absent(),
              }) => WordRowsCompanion.insert(
                id: id,
                word: word,
                pinyin: pinyin,
                meaning: meaning,
                notes: notes,
                state: state,
                createAt: createAt,
                dueAt: dueAt,
                lastReviewAt: lastReviewAt,
                fsrsCard: fsrsCard,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WordRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordRowsTable,
      WordRow,
      $$WordRowsTableFilterComposer,
      $$WordRowsTableOrderingComposer,
      $$WordRowsTableAnnotationComposer,
      $$WordRowsTableCreateCompanionBuilder,
      $$WordRowsTableUpdateCompanionBuilder,
      (WordRow, BaseReferences<_$AppDatabase, $WordRowsTable, WordRow>),
      WordRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WordRowsTableTableManager get wordRows =>
      $$WordRowsTableTableManager(_db, _db.wordRows);
}
