// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DecksTable extends Decks with TableInfo<$DecksTable, Deck> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DecksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueCountMeta = const VerificationMeta(
    'dueCount',
  );
  @override
  late final GeneratedColumn<int> dueCount = GeneratedColumn<int>(
    'due_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _newCountMeta = const VerificationMeta(
    'newCount',
  );
  @override
  late final GeneratedColumn<int> newCount = GeneratedColumn<int>(
    'new_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalCountMeta = const VerificationMeta(
    'totalCount',
  );
  @override
  late final GeneratedColumn<int> totalCount = GeneratedColumn<int>(
    'total_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastStudiedMeta = const VerificationMeta(
    'lastStudied',
  );
  @override
  late final GeneratedColumn<DateTime> lastStudied = GeneratedColumn<DateTime>(
    'last_studied',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        description,
        dueCount,
        newCount,
        totalCount,
        lastStudied,
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'decks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Deck> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('due_count')) {
      context.handle(
        _dueCountMeta,
        dueCount.isAcceptableOrUnknown(data['due_count']!, _dueCountMeta),
      );
    }
    if (data.containsKey('new_count')) {
      context.handle(
        _newCountMeta,
        newCount.isAcceptableOrUnknown(data['new_count']!, _newCountMeta),
      );
    }
    if (data.containsKey('total_count')) {
      context.handle(
        _totalCountMeta,
        totalCount.isAcceptableOrUnknown(data['total_count']!, _totalCountMeta),
      );
    }
    if (data.containsKey('last_studied')) {
      context.handle(
        _lastStudiedMeta,
        lastStudied.isAcceptableOrUnknown(
          data['last_studied']!,
          _lastStudiedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Deck map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Deck(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      dueCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_count'],
      )!,
      newCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}new_count'],
      )!,
      totalCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_count'],
      )!,
      lastStudied: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_studied'],
      ),
    );
  }

  @override
  $DecksTable createAlias(String alias) {
    return $DecksTable(attachedDatabase, alias);
  }
}

class Deck extends DataClass implements Insertable<Deck> {
  final String id;
  final String title;
  final String description;
  final int dueCount;
  final int newCount;
  final int totalCount;
  final DateTime? lastStudied;
  const Deck({
    required this.id,
    required this.title,
    required this.description,
    required this.dueCount,
    required this.newCount,
    required this.totalCount,
    this.lastStudied,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['due_count'] = Variable<int>(dueCount);
    map['new_count'] = Variable<int>(newCount);
    map['total_count'] = Variable<int>(totalCount);
    if (!nullToAbsent || lastStudied != null) {
      map['last_studied'] = Variable<DateTime>(lastStudied);
    }
    return map;
  }

  DecksCompanion toCompanion(bool nullToAbsent) {
    return DecksCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      dueCount: Value(dueCount),
      newCount: Value(newCount),
      totalCount: Value(totalCount),
      lastStudied: lastStudied == null && nullToAbsent
          ? const Value.absent()
          : Value(lastStudied),
    );
  }

  factory Deck.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Deck(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      dueCount: serializer.fromJson<int>(json['dueCount']),
      newCount: serializer.fromJson<int>(json['newCount']),
      totalCount: serializer.fromJson<int>(json['totalCount']),
      lastStudied: serializer.fromJson<DateTime?>(json['lastStudied']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'dueCount': serializer.toJson<int>(dueCount),
      'newCount': serializer.toJson<int>(newCount),
      'totalCount': serializer.toJson<int>(totalCount),
      'lastStudied': serializer.toJson<DateTime?>(lastStudied),
    };
  }

  Deck copyWith({
    String? id,
    String? title,
    String? description,
    int? dueCount,
    int? newCount,
    int? totalCount,
    Value<DateTime?> lastStudied = const Value.absent(),
  }) =>
      Deck(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        dueCount: dueCount ?? this.dueCount,
        newCount: newCount ?? this.newCount,
        totalCount: totalCount ?? this.totalCount,
        lastStudied: lastStudied.present ? lastStudied.value : this.lastStudied,
      );
  Deck copyWithCompanion(DecksCompanion data) {
    return Deck(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      dueCount: data.dueCount.present ? data.dueCount.value : this.dueCount,
      newCount: data.newCount.present ? data.newCount.value : this.newCount,
      totalCount:
          data.totalCount.present ? data.totalCount.value : this.totalCount,
      lastStudied:
          data.lastStudied.present ? data.lastStudied.value : this.lastStudied,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Deck(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueCount: $dueCount, ')
          ..write('newCount: $newCount, ')
          ..write('totalCount: $totalCount, ')
          ..write('lastStudied: $lastStudied')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        description,
        dueCount,
        newCount,
        totalCount,
        lastStudied,
      );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Deck &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.dueCount == this.dueCount &&
          other.newCount == this.newCount &&
          other.totalCount == this.totalCount &&
          other.lastStudied == this.lastStudied);
}

class DecksCompanion extends UpdateCompanion<Deck> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<int> dueCount;
  final Value<int> newCount;
  final Value<int> totalCount;
  final Value<DateTime?> lastStudied;
  final Value<int> rowid;
  const DecksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.dueCount = const Value.absent(),
    this.newCount = const Value.absent(),
    this.totalCount = const Value.absent(),
    this.lastStudied = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DecksCompanion.insert({
    required String id,
    required String title,
    required String description,
    this.dueCount = const Value.absent(),
    this.newCount = const Value.absent(),
    this.totalCount = const Value.absent(),
    this.lastStudied = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        description = Value(description);
  static Insertable<Deck> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? dueCount,
    Expression<int>? newCount,
    Expression<int>? totalCount,
    Expression<DateTime>? lastStudied,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (dueCount != null) 'due_count': dueCount,
      if (newCount != null) 'new_count': newCount,
      if (totalCount != null) 'total_count': totalCount,
      if (lastStudied != null) 'last_studied': lastStudied,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DecksCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? description,
    Value<int>? dueCount,
    Value<int>? newCount,
    Value<int>? totalCount,
    Value<DateTime?>? lastStudied,
    Value<int>? rowid,
  }) {
    return DecksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueCount: dueCount ?? this.dueCount,
      newCount: newCount ?? this.newCount,
      totalCount: totalCount ?? this.totalCount,
      lastStudied: lastStudied ?? this.lastStudied,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (dueCount.present) {
      map['due_count'] = Variable<int>(dueCount.value);
    }
    if (newCount.present) {
      map['new_count'] = Variable<int>(newCount.value);
    }
    if (totalCount.present) {
      map['total_count'] = Variable<int>(totalCount.value);
    }
    if (lastStudied.present) {
      map['last_studied'] = Variable<DateTime>(lastStudied.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DecksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueCount: $dueCount, ')
          ..write('newCount: $newCount, ')
          ..write('totalCount: $totalCount, ')
          ..write('lastStudied: $lastStudied, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardsTable extends Cards with TableInfo<$CardsTable, Card> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<String> deckId = GeneratedColumn<String>(
    'deck_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES decks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _frontMeta = const VerificationMeta('front');
  @override
  late final GeneratedColumn<String> front = GeneratedColumn<String>(
    'front',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _backMeta = const VerificationMeta('back');
  @override
  late final GeneratedColumn<String> back = GeneratedColumn<String>(
    'back',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hintMeta = const VerificationMeta('hint');
  @override
  late final GeneratedColumn<String> hint = GeneratedColumn<String>(
    'hint',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteTypeMeta = const VerificationMeta(
    'noteType',
  );
  @override
  late final GeneratedColumn<String> noteType = GeneratedColumn<String>(
    'note_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('basic'),
  );
  static const VerificationMeta _flagMeta = const VerificationMeta('flag');
  @override
  late final GeneratedColumn<int> flag = GeneratedColumn<int>(
    'flag',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isSuspendedMeta = const VerificationMeta(
    'isSuspended',
  );
  @override
  late final GeneratedColumn<bool> isSuspended = GeneratedColumn<bool>(
    'is_suspended',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_suspended" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isBuriedMeta = const VerificationMeta(
    'isBuried',
  );
  @override
  late final GeneratedColumn<bool> isBuried = GeneratedColumn<bool>(
    'is_buried',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_buried" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _intervalDaysMeta = const VerificationMeta(
    'intervalDays',
  );
  @override
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
    'interval_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stabilityMeta = const VerificationMeta(
    'stability',
  );
  @override
  late final GeneratedColumn<double> stability = GeneratedColumn<double>(
    'stability',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<double> difficulty = GeneratedColumn<double>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lapsesMeta = const VerificationMeta('lapses');
  @override
  late final GeneratedColumn<int> lapses = GeneratedColumn<int>(
    'lapses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dueMeta = const VerificationMeta('due');
  @override
  late final GeneratedColumn<DateTime> due = GeneratedColumn<DateTime>(
    'due',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastStudiedMeta = const VerificationMeta(
    'lastStudied',
  );
  @override
  late final GeneratedColumn<DateTime> lastStudied = GeneratedColumn<DateTime>(
    'last_studied',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
        id,
        deckId,
        front,
        back,
        hint,
        noteType,
        flag,
        isSuspended,
        isBuried,
        tags,
        intervalDays,
        stability,
        difficulty,
        reps,
        lapses,
        due,
        lastStudied,
        createdAt,
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<Card> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('deck_id')) {
      context.handle(
        _deckIdMeta,
        deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('front')) {
      context.handle(
        _frontMeta,
        front.isAcceptableOrUnknown(data['front']!, _frontMeta),
      );
    } else if (isInserting) {
      context.missing(_frontMeta);
    }
    if (data.containsKey('back')) {
      context.handle(
        _backMeta,
        back.isAcceptableOrUnknown(data['back']!, _backMeta),
      );
    } else if (isInserting) {
      context.missing(_backMeta);
    }
    if (data.containsKey('hint')) {
      context.handle(
        _hintMeta,
        hint.isAcceptableOrUnknown(data['hint']!, _hintMeta),
      );
    }
    if (data.containsKey('note_type')) {
      context.handle(
        _noteTypeMeta,
        noteType.isAcceptableOrUnknown(data['note_type']!, _noteTypeMeta),
      );
    }
    if (data.containsKey('flag')) {
      context.handle(
        _flagMeta,
        flag.isAcceptableOrUnknown(data['flag']!, _flagMeta),
      );
    }
    if (data.containsKey('is_suspended')) {
      context.handle(
        _isSuspendedMeta,
        isSuspended.isAcceptableOrUnknown(
          data['is_suspended']!,
          _isSuspendedMeta,
        ),
      );
    }
    if (data.containsKey('is_buried')) {
      context.handle(
        _isBuriedMeta,
        isBuried.isAcceptableOrUnknown(data['is_buried']!, _isBuriedMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('interval_days')) {
      context.handle(
        _intervalDaysMeta,
        intervalDays.isAcceptableOrUnknown(
          data['interval_days']!,
          _intervalDaysMeta,
        ),
      );
    }
    if (data.containsKey('stability')) {
      context.handle(
        _stabilityMeta,
        stability.isAcceptableOrUnknown(data['stability']!, _stabilityMeta),
      );
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    }
    if (data.containsKey('lapses')) {
      context.handle(
        _lapsesMeta,
        lapses.isAcceptableOrUnknown(data['lapses']!, _lapsesMeta),
      );
    }
    if (data.containsKey('due')) {
      context.handle(
        _dueMeta,
        due.isAcceptableOrUnknown(data['due']!, _dueMeta),
      );
    }
    if (data.containsKey('last_studied')) {
      context.handle(
        _lastStudiedMeta,
        lastStudied.isAcceptableOrUnknown(
          data['last_studied']!,
          _lastStudiedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Card map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Card(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deckId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deck_id'],
      )!,
      front: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}front'],
      )!,
      back: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}back'],
      )!,
      hint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hint'],
      ),
      noteType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_type'],
      )!,
      flag: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}flag'],
      )!,
      isSuspended: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_suspended'],
      )!,
      isBuried: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_buried'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
      intervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_days'],
      )!,
      stability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stability'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}difficulty'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      lapses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lapses'],
      )!,
      due: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due'],
      ),
      lastStudied: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_studied'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
    );
  }

  @override
  $CardsTable createAlias(String alias) {
    return $CardsTable(attachedDatabase, alias);
  }
}

class Card extends DataClass implements Insertable<Card> {
  final String id;
  final String deckId;
  final String front;
  final String back;
  final String? hint;
  final String noteType;
  final int flag;
  final bool isSuspended;
  final bool isBuried;
  final String tags;
  final int intervalDays;
  final double stability;
  final double difficulty;
  final int reps;
  final int lapses;
  final DateTime? due;
  final DateTime? lastStudied;
  final DateTime? createdAt;
  const Card({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    this.hint,
    required this.noteType,
    required this.flag,
    required this.isSuspended,
    required this.isBuried,
    required this.tags,
    required this.intervalDays,
    required this.stability,
    required this.difficulty,
    required this.reps,
    required this.lapses,
    this.due,
    this.lastStudied,
    this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['deck_id'] = Variable<String>(deckId);
    map['front'] = Variable<String>(front);
    map['back'] = Variable<String>(back);
    if (!nullToAbsent || hint != null) {
      map['hint'] = Variable<String>(hint);
    }
    map['note_type'] = Variable<String>(noteType);
    map['flag'] = Variable<int>(flag);
    map['is_suspended'] = Variable<bool>(isSuspended);
    map['is_buried'] = Variable<bool>(isBuried);
    map['tags'] = Variable<String>(tags);
    map['interval_days'] = Variable<int>(intervalDays);
    map['stability'] = Variable<double>(stability);
    map['difficulty'] = Variable<double>(difficulty);
    map['reps'] = Variable<int>(reps);
    map['lapses'] = Variable<int>(lapses);
    if (!nullToAbsent || due != null) {
      map['due'] = Variable<DateTime>(due);
    }
    if (!nullToAbsent || lastStudied != null) {
      map['last_studied'] = Variable<DateTime>(lastStudied);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    return map;
  }

  CardsCompanion toCompanion(bool nullToAbsent) {
    return CardsCompanion(
      id: Value(id),
      deckId: Value(deckId),
      front: Value(front),
      back: Value(back),
      hint: hint == null && nullToAbsent ? const Value.absent() : Value(hint),
      noteType: Value(noteType),
      flag: Value(flag),
      isSuspended: Value(isSuspended),
      isBuried: Value(isBuried),
      tags: Value(tags),
      intervalDays: Value(intervalDays),
      stability: Value(stability),
      difficulty: Value(difficulty),
      reps: Value(reps),
      lapses: Value(lapses),
      due: due == null && nullToAbsent ? const Value.absent() : Value(due),
      lastStudied: lastStudied == null && nullToAbsent
          ? const Value.absent()
          : Value(lastStudied),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory Card.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Card(
      id: serializer.fromJson<String>(json['id']),
      deckId: serializer.fromJson<String>(json['deckId']),
      front: serializer.fromJson<String>(json['front']),
      back: serializer.fromJson<String>(json['back']),
      hint: serializer.fromJson<String?>(json['hint']),
      noteType: serializer.fromJson<String>(json['noteType']),
      flag: serializer.fromJson<int>(json['flag']),
      isSuspended: serializer.fromJson<bool>(json['isSuspended']),
      isBuried: serializer.fromJson<bool>(json['isBuried']),
      tags: serializer.fromJson<String>(json['tags']),
      intervalDays: serializer.fromJson<int>(json['intervalDays']),
      stability: serializer.fromJson<double>(json['stability']),
      difficulty: serializer.fromJson<double>(json['difficulty']),
      reps: serializer.fromJson<int>(json['reps']),
      lapses: serializer.fromJson<int>(json['lapses']),
      due: serializer.fromJson<DateTime?>(json['due']),
      lastStudied: serializer.fromJson<DateTime?>(json['lastStudied']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deckId': serializer.toJson<String>(deckId),
      'front': serializer.toJson<String>(front),
      'back': serializer.toJson<String>(back),
      'hint': serializer.toJson<String?>(hint),
      'noteType': serializer.toJson<String>(noteType),
      'flag': serializer.toJson<int>(flag),
      'isSuspended': serializer.toJson<bool>(isSuspended),
      'isBuried': serializer.toJson<bool>(isBuried),
      'tags': serializer.toJson<String>(tags),
      'intervalDays': serializer.toJson<int>(intervalDays),
      'stability': serializer.toJson<double>(stability),
      'difficulty': serializer.toJson<double>(difficulty),
      'reps': serializer.toJson<int>(reps),
      'lapses': serializer.toJson<int>(lapses),
      'due': serializer.toJson<DateTime?>(due),
      'lastStudied': serializer.toJson<DateTime?>(lastStudied),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  Card copyWith({
    String? id,
    String? deckId,
    String? front,
    String? back,
    Value<String?> hint = const Value.absent(),
    String? noteType,
    int? flag,
    bool? isSuspended,
    bool? isBuried,
    String? tags,
    int? intervalDays,
    double? stability,
    double? difficulty,
    int? reps,
    int? lapses,
    Value<DateTime?> due = const Value.absent(),
    Value<DateTime?> lastStudied = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
  }) =>
      Card(
        id: id ?? this.id,
        deckId: deckId ?? this.deckId,
        front: front ?? this.front,
        back: back ?? this.back,
        hint: hint.present ? hint.value : this.hint,
        noteType: noteType ?? this.noteType,
        flag: flag ?? this.flag,
        isSuspended: isSuspended ?? this.isSuspended,
        isBuried: isBuried ?? this.isBuried,
        tags: tags ?? this.tags,
        intervalDays: intervalDays ?? this.intervalDays,
        stability: stability ?? this.stability,
        difficulty: difficulty ?? this.difficulty,
        reps: reps ?? this.reps,
        lapses: lapses ?? this.lapses,
        due: due.present ? due.value : this.due,
        lastStudied: lastStudied.present ? lastStudied.value : this.lastStudied,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
      );
  Card copyWithCompanion(CardsCompanion data) {
    return Card(
      id: data.id.present ? data.id.value : this.id,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      front: data.front.present ? data.front.value : this.front,
      back: data.back.present ? data.back.value : this.back,
      hint: data.hint.present ? data.hint.value : this.hint,
      noteType: data.noteType.present ? data.noteType.value : this.noteType,
      flag: data.flag.present ? data.flag.value : this.flag,
      isSuspended:
          data.isSuspended.present ? data.isSuspended.value : this.isSuspended,
      isBuried: data.isBuried.present ? data.isBuried.value : this.isBuried,
      tags: data.tags.present ? data.tags.value : this.tags,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      stability: data.stability.present ? data.stability.value : this.stability,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      reps: data.reps.present ? data.reps.value : this.reps,
      lapses: data.lapses.present ? data.lapses.value : this.lapses,
      due: data.due.present ? data.due.value : this.due,
      lastStudied:
          data.lastStudied.present ? data.lastStudied.value : this.lastStudied,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Card(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('front: $front, ')
          ..write('back: $back, ')
          ..write('hint: $hint, ')
          ..write('noteType: $noteType, ')
          ..write('flag: $flag, ')
          ..write('isSuspended: $isSuspended, ')
          ..write('isBuried: $isBuried, ')
          ..write('tags: $tags, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('due: $due, ')
          ..write('lastStudied: $lastStudied, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
        id,
        deckId,
        front,
        back,
        hint,
        noteType,
        flag,
        isSuspended,
        isBuried,
        tags,
        intervalDays,
        stability,
        difficulty,
        reps,
        lapses,
        due,
        lastStudied,
        createdAt,
      );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Card &&
          other.id == this.id &&
          other.deckId == this.deckId &&
          other.front == this.front &&
          other.back == this.back &&
          other.hint == this.hint &&
          other.noteType == this.noteType &&
          other.flag == this.flag &&
          other.isSuspended == this.isSuspended &&
          other.isBuried == this.isBuried &&
          other.tags == this.tags &&
          other.intervalDays == this.intervalDays &&
          other.stability == this.stability &&
          other.difficulty == this.difficulty &&
          other.reps == this.reps &&
          other.lapses == this.lapses &&
          other.due == this.due &&
          other.lastStudied == this.lastStudied &&
          other.createdAt == this.createdAt);
}

class CardsCompanion extends UpdateCompanion<Card> {
  final Value<String> id;
  final Value<String> deckId;
  final Value<String> front;
  final Value<String> back;
  final Value<String?> hint;
  final Value<String> noteType;
  final Value<int> flag;
  final Value<bool> isSuspended;
  final Value<bool> isBuried;
  final Value<String> tags;
  final Value<int> intervalDays;
  final Value<double> stability;
  final Value<double> difficulty;
  final Value<int> reps;
  final Value<int> lapses;
  final Value<DateTime?> due;
  final Value<DateTime?> lastStudied;
  final Value<DateTime?> createdAt;
  final Value<int> rowid;
  const CardsCompanion({
    this.id = const Value.absent(),
    this.deckId = const Value.absent(),
    this.front = const Value.absent(),
    this.back = const Value.absent(),
    this.hint = const Value.absent(),
    this.noteType = const Value.absent(),
    this.flag = const Value.absent(),
    this.isSuspended = const Value.absent(),
    this.isBuried = const Value.absent(),
    this.tags = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    this.due = const Value.absent(),
    this.lastStudied = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardsCompanion.insert({
    required String id,
    required String deckId,
    required String front,
    required String back,
    this.hint = const Value.absent(),
    this.noteType = const Value.absent(),
    this.flag = const Value.absent(),
    this.isSuspended = const Value.absent(),
    this.isBuried = const Value.absent(),
    this.tags = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    this.due = const Value.absent(),
    this.lastStudied = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        deckId = Value(deckId),
        front = Value(front),
        back = Value(back);
  static Insertable<Card> custom({
    Expression<String>? id,
    Expression<String>? deckId,
    Expression<String>? front,
    Expression<String>? back,
    Expression<String>? hint,
    Expression<String>? noteType,
    Expression<int>? flag,
    Expression<bool>? isSuspended,
    Expression<bool>? isBuried,
    Expression<String>? tags,
    Expression<int>? intervalDays,
    Expression<double>? stability,
    Expression<double>? difficulty,
    Expression<int>? reps,
    Expression<int>? lapses,
    Expression<DateTime>? due,
    Expression<DateTime>? lastStudied,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deckId != null) 'deck_id': deckId,
      if (front != null) 'front': front,
      if (back != null) 'back': back,
      if (hint != null) 'hint': hint,
      if (noteType != null) 'note_type': noteType,
      if (flag != null) 'flag': flag,
      if (isSuspended != null) 'is_suspended': isSuspended,
      if (isBuried != null) 'is_buried': isBuried,
      if (tags != null) 'tags': tags,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (stability != null) 'stability': stability,
      if (difficulty != null) 'difficulty': difficulty,
      if (reps != null) 'reps': reps,
      if (lapses != null) 'lapses': lapses,
      if (due != null) 'due': due,
      if (lastStudied != null) 'last_studied': lastStudied,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardsCompanion copyWith({
    Value<String>? id,
    Value<String>? deckId,
    Value<String>? front,
    Value<String>? back,
    Value<String?>? hint,
    Value<String>? noteType,
    Value<int>? flag,
    Value<bool>? isSuspended,
    Value<bool>? isBuried,
    Value<String>? tags,
    Value<int>? intervalDays,
    Value<double>? stability,
    Value<double>? difficulty,
    Value<int>? reps,
    Value<int>? lapses,
    Value<DateTime?>? due,
    Value<DateTime?>? lastStudied,
    Value<DateTime?>? createdAt,
    Value<int>? rowid,
  }) {
    return CardsCompanion(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      front: front ?? this.front,
      back: back ?? this.back,
      hint: hint ?? this.hint,
      noteType: noteType ?? this.noteType,
      flag: flag ?? this.flag,
      isSuspended: isSuspended ?? this.isSuspended,
      isBuried: isBuried ?? this.isBuried,
      tags: tags ?? this.tags,
      intervalDays: intervalDays ?? this.intervalDays,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      due: due ?? this.due,
      lastStudied: lastStudied ?? this.lastStudied,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<String>(deckId.value);
    }
    if (front.present) {
      map['front'] = Variable<String>(front.value);
    }
    if (back.present) {
      map['back'] = Variable<String>(back.value);
    }
    if (hint.present) {
      map['hint'] = Variable<String>(hint.value);
    }
    if (noteType.present) {
      map['note_type'] = Variable<String>(noteType.value);
    }
    if (flag.present) {
      map['flag'] = Variable<int>(flag.value);
    }
    if (isSuspended.present) {
      map['is_suspended'] = Variable<bool>(isSuspended.value);
    }
    if (isBuried.present) {
      map['is_buried'] = Variable<bool>(isBuried.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (stability.present) {
      map['stability'] = Variable<double>(stability.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<double>(difficulty.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (lapses.present) {
      map['lapses'] = Variable<int>(lapses.value);
    }
    if (due.present) {
      map['due'] = Variable<DateTime>(due.value);
    }
    if (lastStudied.present) {
      map['last_studied'] = Variable<DateTime>(lastStudied.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardsCompanion(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('front: $front, ')
          ..write('back: $back, ')
          ..write('hint: $hint, ')
          ..write('noteType: $noteType, ')
          ..write('flag: $flag, ')
          ..write('isSuspended: $isSuspended, ')
          ..write('isBuried: $isBuried, ')
          ..write('tags: $tags, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('due: $due, ')
          ..write('lastStudied: $lastStudied, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReviewLogsTable extends ReviewLogs
    with TableInfo<$ReviewLogsTable, ReviewLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cards (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reviewTimeMeta = const VerificationMeta(
    'reviewTime',
  );
  @override
  late final GeneratedColumn<DateTime> reviewTime = GeneratedColumn<DateTime>(
    'review_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledDaysMeta = const VerificationMeta(
    'scheduledDays',
  );
  @override
  late final GeneratedColumn<int> scheduledDays = GeneratedColumn<int>(
    'scheduled_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _elapsedDaysMeta = const VerificationMeta(
    'elapsedDays',
  );
  @override
  late final GeneratedColumn<int> elapsedDays = GeneratedColumn<int>(
    'elapsed_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
        id,
        cardId,
        rating,
        reviewTime,
        scheduledDays,
        elapsedDays,
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    } else if (isInserting) {
      context.missing(_ratingMeta);
    }
    if (data.containsKey('review_time')) {
      context.handle(
        _reviewTimeMeta,
        reviewTime.isAcceptableOrUnknown(data['review_time']!, _reviewTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_reviewTimeMeta);
    }
    if (data.containsKey('scheduled_days')) {
      context.handle(
        _scheduledDaysMeta,
        scheduledDays.isAcceptableOrUnknown(
          data['scheduled_days']!,
          _scheduledDaysMeta,
        ),
      );
    }
    if (data.containsKey('elapsed_days')) {
      context.handle(
        _elapsedDaysMeta,
        elapsedDays.isAcceptableOrUnknown(
          data['elapsed_days']!,
          _elapsedDaysMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReviewLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      )!,
      reviewTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}review_time'],
      )!,
      scheduledDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scheduled_days'],
      )!,
      elapsedDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_days'],
      )!,
    );
  }

  @override
  $ReviewLogsTable createAlias(String alias) {
    return $ReviewLogsTable(attachedDatabase, alias);
  }
}

class ReviewLog extends DataClass implements Insertable<ReviewLog> {
  final int id;
  final String cardId;
  final int rating;
  final DateTime reviewTime;
  final int scheduledDays;
  final int elapsedDays;
  const ReviewLog({
    required this.id,
    required this.cardId,
    required this.rating,
    required this.reviewTime,
    required this.scheduledDays,
    required this.elapsedDays,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['card_id'] = Variable<String>(cardId);
    map['rating'] = Variable<int>(rating);
    map['review_time'] = Variable<DateTime>(reviewTime);
    map['scheduled_days'] = Variable<int>(scheduledDays);
    map['elapsed_days'] = Variable<int>(elapsedDays);
    return map;
  }

  ReviewLogsCompanion toCompanion(bool nullToAbsent) {
    return ReviewLogsCompanion(
      id: Value(id),
      cardId: Value(cardId),
      rating: Value(rating),
      reviewTime: Value(reviewTime),
      scheduledDays: Value(scheduledDays),
      elapsedDays: Value(elapsedDays),
    );
  }

  factory ReviewLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewLog(
      id: serializer.fromJson<int>(json['id']),
      cardId: serializer.fromJson<String>(json['cardId']),
      rating: serializer.fromJson<int>(json['rating']),
      reviewTime: serializer.fromJson<DateTime>(json['reviewTime']),
      scheduledDays: serializer.fromJson<int>(json['scheduledDays']),
      elapsedDays: serializer.fromJson<int>(json['elapsedDays']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cardId': serializer.toJson<String>(cardId),
      'rating': serializer.toJson<int>(rating),
      'reviewTime': serializer.toJson<DateTime>(reviewTime),
      'scheduledDays': serializer.toJson<int>(scheduledDays),
      'elapsedDays': serializer.toJson<int>(elapsedDays),
    };
  }

  ReviewLog copyWith({
    int? id,
    String? cardId,
    int? rating,
    DateTime? reviewTime,
    int? scheduledDays,
    int? elapsedDays,
  }) =>
      ReviewLog(
        id: id ?? this.id,
        cardId: cardId ?? this.cardId,
        rating: rating ?? this.rating,
        reviewTime: reviewTime ?? this.reviewTime,
        scheduledDays: scheduledDays ?? this.scheduledDays,
        elapsedDays: elapsedDays ?? this.elapsedDays,
      );
  ReviewLog copyWithCompanion(ReviewLogsCompanion data) {
    return ReviewLog(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      rating: data.rating.present ? data.rating.value : this.rating,
      reviewTime:
          data.reviewTime.present ? data.reviewTime.value : this.reviewTime,
      scheduledDays: data.scheduledDays.present
          ? data.scheduledDays.value
          : this.scheduledDays,
      elapsedDays:
          data.elapsedDays.present ? data.elapsedDays.value : this.elapsedDays,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewLog(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('rating: $rating, ')
          ..write('reviewTime: $reviewTime, ')
          ..write('scheduledDays: $scheduledDays, ')
          ..write('elapsedDays: $elapsedDays')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, cardId, rating, reviewTime, scheduledDays, elapsedDays);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewLog &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.rating == this.rating &&
          other.reviewTime == this.reviewTime &&
          other.scheduledDays == this.scheduledDays &&
          other.elapsedDays == this.elapsedDays);
}

class ReviewLogsCompanion extends UpdateCompanion<ReviewLog> {
  final Value<int> id;
  final Value<String> cardId;
  final Value<int> rating;
  final Value<DateTime> reviewTime;
  final Value<int> scheduledDays;
  final Value<int> elapsedDays;
  const ReviewLogsCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.rating = const Value.absent(),
    this.reviewTime = const Value.absent(),
    this.scheduledDays = const Value.absent(),
    this.elapsedDays = const Value.absent(),
  });
  ReviewLogsCompanion.insert({
    this.id = const Value.absent(),
    required String cardId,
    required int rating,
    required DateTime reviewTime,
    this.scheduledDays = const Value.absent(),
    this.elapsedDays = const Value.absent(),
  })  : cardId = Value(cardId),
        rating = Value(rating),
        reviewTime = Value(reviewTime);
  static Insertable<ReviewLog> custom({
    Expression<int>? id,
    Expression<String>? cardId,
    Expression<int>? rating,
    Expression<DateTime>? reviewTime,
    Expression<int>? scheduledDays,
    Expression<int>? elapsedDays,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (rating != null) 'rating': rating,
      if (reviewTime != null) 'review_time': reviewTime,
      if (scheduledDays != null) 'scheduled_days': scheduledDays,
      if (elapsedDays != null) 'elapsed_days': elapsedDays,
    });
  }

  ReviewLogsCompanion copyWith({
    Value<int>? id,
    Value<String>? cardId,
    Value<int>? rating,
    Value<DateTime>? reviewTime,
    Value<int>? scheduledDays,
    Value<int>? elapsedDays,
  }) {
    return ReviewLogsCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      rating: rating ?? this.rating,
      reviewTime: reviewTime ?? this.reviewTime,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      elapsedDays: elapsedDays ?? this.elapsedDays,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (reviewTime.present) {
      map['review_time'] = Variable<DateTime>(reviewTime.value);
    }
    if (scheduledDays.present) {
      map['scheduled_days'] = Variable<int>(scheduledDays.value);
    }
    if (elapsedDays.present) {
      map['elapsed_days'] = Variable<int>(elapsedDays.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewLogsCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('rating: $rating, ')
          ..write('reviewTime: $reviewTime, ')
          ..write('scheduledDays: $scheduledDays, ')
          ..write('elapsedDays: $elapsedDays')
          ..write(')'))
        .toString();
  }
}

class $GrammarProgressEntriesTable extends GrammarProgressEntries
    with TableInfo<$GrammarProgressEntriesTable, GrammarProgressEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GrammarProgressEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<String> unitId = GeneratedColumn<String>(
    'unit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stabilityMeta = const VerificationMeta(
    'stability',
  );
  @override
  late final GeneratedColumn<double> stability = GeneratedColumn<double>(
    'stability',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<double> difficulty = GeneratedColumn<double>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _dueMeta = const VerificationMeta('due');
  @override
  late final GeneratedColumn<DateTime> due = GeneratedColumn<DateTime>(
    'due',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastStudiedMeta = const VerificationMeta(
    'lastStudied',
  );
  @override
  late final GeneratedColumn<DateTime> lastStudied = GeneratedColumn<DateTime>(
    'last_studied',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lapsesMeta = const VerificationMeta('lapses');
  @override
  late final GeneratedColumn<int> lapses = GeneratedColumn<int>(
    'lapses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<CardState, int> state =
      GeneratedColumn<int>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  ).withConverter<CardState>($GrammarProgressEntriesTable.$converterstate);
  static const VerificationMeta _isGhostMeta = const VerificationMeta(
    'isGhost',
  );
  @override
  late final GeneratedColumn<bool> isGhost = GeneratedColumn<bool>(
    'is_ghost',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_ghost" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastUserAnswerMeta = const VerificationMeta(
    'lastUserAnswer',
  );
  @override
  late final GeneratedColumn<String> lastUserAnswer = GeneratedColumn<String>(
    'last_user_answer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
        unitId,
        exerciseId,
        stability,
        difficulty,
        due,
        lastStudied,
        reps,
        lapses,
        state,
        isGhost,
        isCompleted,
        lastUserAnswer,
        updatedAt,
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grammar_progress_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<GrammarProgressEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('unit_id')) {
      context.handle(
        _unitIdMeta,
        unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_unitIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('stability')) {
      context.handle(
        _stabilityMeta,
        stability.isAcceptableOrUnknown(data['stability']!, _stabilityMeta),
      );
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('due')) {
      context.handle(
        _dueMeta,
        due.isAcceptableOrUnknown(data['due']!, _dueMeta),
      );
    }
    if (data.containsKey('last_studied')) {
      context.handle(
        _lastStudiedMeta,
        lastStudied.isAcceptableOrUnknown(
          data['last_studied']!,
          _lastStudiedMeta,
        ),
      );
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    }
    if (data.containsKey('lapses')) {
      context.handle(
        _lapsesMeta,
        lapses.isAcceptableOrUnknown(data['lapses']!, _lapsesMeta),
      );
    }
    if (data.containsKey('is_ghost')) {
      context.handle(
        _isGhostMeta,
        isGhost.isAcceptableOrUnknown(data['is_ghost']!, _isGhostMeta),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('last_user_answer')) {
      context.handle(
        _lastUserAnswerMeta,
        lastUserAnswer.isAcceptableOrUnknown(
          data['last_user_answer']!,
          _lastUserAnswerMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {unitId, exerciseId};
  @override
  GrammarProgressEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GrammarProgressEntry(
      unitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      stability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stability'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}difficulty'],
      )!,
      due: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due'],
      ),
      lastStudied: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_studied'],
      ),
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      lapses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lapses'],
      )!,
      state: $GrammarProgressEntriesTable.$converterstate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}state'],
        )!,
      ),
      isGhost: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_ghost'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      lastUserAnswer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_user_answer'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $GrammarProgressEntriesTable createAlias(String alias) {
    return $GrammarProgressEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CardState, int, int> $converterstate =
      const EnumIndexConverter<CardState>(CardState.values);
}

class GrammarProgressEntry extends DataClass
    implements Insertable<GrammarProgressEntry> {
  final String unitId;
  final String exerciseId;
  final double stability;
  final double difficulty;
  final DateTime? due;
  final DateTime? lastStudied;
  final int reps;
  final int lapses;
  final CardState state;
  final bool isGhost;
  final bool isCompleted;
  final String? lastUserAnswer;
  final DateTime updatedAt;
  const GrammarProgressEntry({
    required this.unitId,
    required this.exerciseId,
    required this.stability,
    required this.difficulty,
    this.due,
    this.lastStudied,
    required this.reps,
    required this.lapses,
    required this.state,
    required this.isGhost,
    required this.isCompleted,
    this.lastUserAnswer,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['unit_id'] = Variable<String>(unitId);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['stability'] = Variable<double>(stability);
    map['difficulty'] = Variable<double>(difficulty);
    if (!nullToAbsent || due != null) {
      map['due'] = Variable<DateTime>(due);
    }
    if (!nullToAbsent || lastStudied != null) {
      map['last_studied'] = Variable<DateTime>(lastStudied);
    }
    map['reps'] = Variable<int>(reps);
    map['lapses'] = Variable<int>(lapses);
    {
      map['state'] = Variable<int>(
        $GrammarProgressEntriesTable.$converterstate.toSql(state),
      );
    }
    map['is_ghost'] = Variable<bool>(isGhost);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || lastUserAnswer != null) {
      map['last_user_answer'] = Variable<String>(lastUserAnswer);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  GrammarProgressEntriesCompanion toCompanion(bool nullToAbsent) {
    return GrammarProgressEntriesCompanion(
      unitId: Value(unitId),
      exerciseId: Value(exerciseId),
      stability: Value(stability),
      difficulty: Value(difficulty),
      due: due == null && nullToAbsent ? const Value.absent() : Value(due),
      lastStudied: lastStudied == null && nullToAbsent
          ? const Value.absent()
          : Value(lastStudied),
      reps: Value(reps),
      lapses: Value(lapses),
      state: Value(state),
      isGhost: Value(isGhost),
      isCompleted: Value(isCompleted),
      lastUserAnswer: lastUserAnswer == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUserAnswer),
      updatedAt: Value(updatedAt),
    );
  }

  factory GrammarProgressEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GrammarProgressEntry(
      unitId: serializer.fromJson<String>(json['unitId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      stability: serializer.fromJson<double>(json['stability']),
      difficulty: serializer.fromJson<double>(json['difficulty']),
      due: serializer.fromJson<DateTime?>(json['due']),
      lastStudied: serializer.fromJson<DateTime?>(json['lastStudied']),
      reps: serializer.fromJson<int>(json['reps']),
      lapses: serializer.fromJson<int>(json['lapses']),
      state: $GrammarProgressEntriesTable.$converterstate.fromJson(
        serializer.fromJson<int>(json['state']),
      ),
      isGhost: serializer.fromJson<bool>(json['isGhost']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      lastUserAnswer: serializer.fromJson<String?>(json['lastUserAnswer']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'unitId': serializer.toJson<String>(unitId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'stability': serializer.toJson<double>(stability),
      'difficulty': serializer.toJson<double>(difficulty),
      'due': serializer.toJson<DateTime?>(due),
      'lastStudied': serializer.toJson<DateTime?>(lastStudied),
      'reps': serializer.toJson<int>(reps),
      'lapses': serializer.toJson<int>(lapses),
      'state': serializer.toJson<int>(
        $GrammarProgressEntriesTable.$converterstate.toJson(state),
      ),
      'isGhost': serializer.toJson<bool>(isGhost),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'lastUserAnswer': serializer.toJson<String?>(lastUserAnswer),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  GrammarProgressEntry copyWith({
    String? unitId,
    String? exerciseId,
    double? stability,
    double? difficulty,
    Value<DateTime?> due = const Value.absent(),
    Value<DateTime?> lastStudied = const Value.absent(),
    int? reps,
    int? lapses,
    CardState? state,
    bool? isGhost,
    bool? isCompleted,
    Value<String?> lastUserAnswer = const Value.absent(),
    DateTime? updatedAt,
  }) =>
      GrammarProgressEntry(
        unitId: unitId ?? this.unitId,
        exerciseId: exerciseId ?? this.exerciseId,
        stability: stability ?? this.stability,
        difficulty: difficulty ?? this.difficulty,
        due: due.present ? due.value : this.due,
        lastStudied: lastStudied.present ? lastStudied.value : this.lastStudied,
        reps: reps ?? this.reps,
        lapses: lapses ?? this.lapses,
        state: state ?? this.state,
        isGhost: isGhost ?? this.isGhost,
        isCompleted: isCompleted ?? this.isCompleted,
        lastUserAnswer:
            lastUserAnswer.present ? lastUserAnswer.value : this.lastUserAnswer,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  GrammarProgressEntry copyWithCompanion(GrammarProgressEntriesCompanion data) {
    return GrammarProgressEntry(
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
      exerciseId:
          data.exerciseId.present ? data.exerciseId.value : this.exerciseId,
      stability: data.stability.present ? data.stability.value : this.stability,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      due: data.due.present ? data.due.value : this.due,
      lastStudied:
          data.lastStudied.present ? data.lastStudied.value : this.lastStudied,
      reps: data.reps.present ? data.reps.value : this.reps,
      lapses: data.lapses.present ? data.lapses.value : this.lapses,
      state: data.state.present ? data.state.value : this.state,
      isGhost: data.isGhost.present ? data.isGhost.value : this.isGhost,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      lastUserAnswer: data.lastUserAnswer.present
          ? data.lastUserAnswer.value
          : this.lastUserAnswer,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GrammarProgressEntry(')
          ..write('unitId: $unitId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('due: $due, ')
          ..write('lastStudied: $lastStudied, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('state: $state, ')
          ..write('isGhost: $isGhost, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('lastUserAnswer: $lastUserAnswer, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
        unitId,
        exerciseId,
        stability,
        difficulty,
        due,
        lastStudied,
        reps,
        lapses,
        state,
        isGhost,
        isCompleted,
        lastUserAnswer,
        updatedAt,
      );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GrammarProgressEntry &&
          other.unitId == this.unitId &&
          other.exerciseId == this.exerciseId &&
          other.stability == this.stability &&
          other.difficulty == this.difficulty &&
          other.due == this.due &&
          other.lastStudied == this.lastStudied &&
          other.reps == this.reps &&
          other.lapses == this.lapses &&
          other.state == this.state &&
          other.isGhost == this.isGhost &&
          other.isCompleted == this.isCompleted &&
          other.lastUserAnswer == this.lastUserAnswer &&
          other.updatedAt == this.updatedAt);
}

class GrammarProgressEntriesCompanion
    extends UpdateCompanion<GrammarProgressEntry> {
  final Value<String> unitId;
  final Value<String> exerciseId;
  final Value<double> stability;
  final Value<double> difficulty;
  final Value<DateTime?> due;
  final Value<DateTime?> lastStudied;
  final Value<int> reps;
  final Value<int> lapses;
  final Value<CardState> state;
  final Value<bool> isGhost;
  final Value<bool> isCompleted;
  final Value<String?> lastUserAnswer;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const GrammarProgressEntriesCompanion({
    this.unitId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.due = const Value.absent(),
    this.lastStudied = const Value.absent(),
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    this.state = const Value.absent(),
    this.isGhost = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.lastUserAnswer = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GrammarProgressEntriesCompanion.insert({
    required String unitId,
    required String exerciseId,
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.due = const Value.absent(),
    this.lastStudied = const Value.absent(),
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    this.state = const Value.absent(),
    this.isGhost = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.lastUserAnswer = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : unitId = Value(unitId),
        exerciseId = Value(exerciseId);
  static Insertable<GrammarProgressEntry> custom({
    Expression<String>? unitId,
    Expression<String>? exerciseId,
    Expression<double>? stability,
    Expression<double>? difficulty,
    Expression<DateTime>? due,
    Expression<DateTime>? lastStudied,
    Expression<int>? reps,
    Expression<int>? lapses,
    Expression<int>? state,
    Expression<bool>? isGhost,
    Expression<bool>? isCompleted,
    Expression<String>? lastUserAnswer,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (unitId != null) 'unit_id': unitId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (stability != null) 'stability': stability,
      if (difficulty != null) 'difficulty': difficulty,
      if (due != null) 'due': due,
      if (lastStudied != null) 'last_studied': lastStudied,
      if (reps != null) 'reps': reps,
      if (lapses != null) 'lapses': lapses,
      if (state != null) 'state': state,
      if (isGhost != null) 'is_ghost': isGhost,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (lastUserAnswer != null) 'last_user_answer': lastUserAnswer,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GrammarProgressEntriesCompanion copyWith({
    Value<String>? unitId,
    Value<String>? exerciseId,
    Value<double>? stability,
    Value<double>? difficulty,
    Value<DateTime?>? due,
    Value<DateTime?>? lastStudied,
    Value<int>? reps,
    Value<int>? lapses,
    Value<CardState>? state,
    Value<bool>? isGhost,
    Value<bool>? isCompleted,
    Value<String?>? lastUserAnswer,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return GrammarProgressEntriesCompanion(
      unitId: unitId ?? this.unitId,
      exerciseId: exerciseId ?? this.exerciseId,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      due: due ?? this.due,
      lastStudied: lastStudied ?? this.lastStudied,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      state: state ?? this.state,
      isGhost: isGhost ?? this.isGhost,
      isCompleted: isCompleted ?? this.isCompleted,
      lastUserAnswer: lastUserAnswer ?? this.lastUserAnswer,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (unitId.present) {
      map['unit_id'] = Variable<String>(unitId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (stability.present) {
      map['stability'] = Variable<double>(stability.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<double>(difficulty.value);
    }
    if (due.present) {
      map['due'] = Variable<DateTime>(due.value);
    }
    if (lastStudied.present) {
      map['last_studied'] = Variable<DateTime>(lastStudied.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (lapses.present) {
      map['lapses'] = Variable<int>(lapses.value);
    }
    if (state.present) {
      map['state'] = Variable<int>(
        $GrammarProgressEntriesTable.$converterstate.toSql(state.value),
      );
    }
    if (isGhost.present) {
      map['is_ghost'] = Variable<bool>(isGhost.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (lastUserAnswer.present) {
      map['last_user_answer'] = Variable<String>(lastUserAnswer.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GrammarProgressEntriesCompanion(')
          ..write('unitId: $unitId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('due: $due, ')
          ..write('lastStudied: $lastStudied, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('state: $state, ')
          ..write('isGhost: $isGhost, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('lastUserAnswer: $lastUserAnswer, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DecksTable decks = $DecksTable(this);
  late final $CardsTable cards = $CardsTable(this);
  late final $ReviewLogsTable reviewLogs = $ReviewLogsTable(this);
  late final $GrammarProgressEntriesTable grammarProgressEntries =
      $GrammarProgressEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        decks,
        cards,
        reviewLogs,
        grammarProgressEntries,
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
        WritePropagation(
          on: TableUpdateQuery.onTableName(
            'decks',
            limitUpdateKind: UpdateKind.delete,
          ),
          result: [TableUpdate('cards', kind: UpdateKind.delete)],
        ),
        WritePropagation(
          on: TableUpdateQuery.onTableName(
            'cards',
            limitUpdateKind: UpdateKind.delete,
          ),
          result: [TableUpdate('review_logs', kind: UpdateKind.delete)],
        ),
      ]);
}

typedef $$DecksTableCreateCompanionBuilder = DecksCompanion Function({
  required String id,
  required String title,
  required String description,
  Value<int> dueCount,
  Value<int> newCount,
  Value<int> totalCount,
  Value<DateTime?> lastStudied,
  Value<int> rowid,
});
typedef $$DecksTableUpdateCompanionBuilder = DecksCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> description,
  Value<int> dueCount,
  Value<int> newCount,
  Value<int> totalCount,
  Value<DateTime?> lastStudied,
  Value<int> rowid,
});

final class $$DecksTableReferences
    extends BaseReferences<_$AppDatabase, $DecksTable, Deck> {
  $$DecksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CardsTable, List<Card>> _cardsRefsTable(
    _$AppDatabase db,
  ) =>
      MultiTypedResultKey.fromTable(
        db.cards,
        aliasName: 'decks__id__cards__deck_id',
      );

  $$CardsTableProcessedTableManager get cardsRefs {
    final manager = $$CardsTableTableManager(
      $_db,
      $_db.cards,
    ).filter((f) => f.deckId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DecksTableFilterComposer extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
        column: $table.title,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<String> get description => $composableBuilder(
        column: $table.description,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<int> get dueCount => $composableBuilder(
        column: $table.dueCount,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<int> get newCount => $composableBuilder(
        column: $table.newCount,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<int> get totalCount => $composableBuilder(
        column: $table.totalCount,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<DateTime> get lastStudied => $composableBuilder(
        column: $table.lastStudied,
        builder: (column) => ColumnFilters(column),
      );

  Expression<bool> cardsRefs(
    Expression<bool> Function($$CardsTableFilterComposer f) f,
  ) {
    final $$CardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.deckId,
      builder: (
        joinBuilder, {
        $addJoinBuilderToRootComposer,
        $removeJoinBuilderFromRootComposer,
      }) =>
          $$CardsTableFilterComposer(
        $db: $db,
        $table: $db.cards,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }
}

class $$DecksTableOrderingComposer
    extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
        column: $table.title,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<String> get description => $composableBuilder(
        column: $table.description,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<int> get dueCount => $composableBuilder(
        column: $table.dueCount,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<int> get newCount => $composableBuilder(
        column: $table.newCount,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<int> get totalCount => $composableBuilder(
        column: $table.totalCount,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<DateTime> get lastStudied => $composableBuilder(
        column: $table.lastStudied,
        builder: (column) => ColumnOrderings(column),
      );
}

class $$DecksTableAnnotationComposer
    extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
        column: $table.description,
        builder: (column) => column,
      );

  GeneratedColumn<int> get dueCount =>
      $composableBuilder(column: $table.dueCount, builder: (column) => column);

  GeneratedColumn<int> get newCount =>
      $composableBuilder(column: $table.newCount, builder: (column) => column);

  GeneratedColumn<int> get totalCount => $composableBuilder(
        column: $table.totalCount,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get lastStudied => $composableBuilder(
        column: $table.lastStudied,
        builder: (column) => column,
      );

  Expression<T> cardsRefs<T extends Object>(
    Expression<T> Function($$CardsTableAnnotationComposer a) f,
  ) {
    final $$CardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.deckId,
      builder: (
        joinBuilder, {
        $addJoinBuilderToRootComposer,
        $removeJoinBuilderFromRootComposer,
      }) =>
          $$CardsTableAnnotationComposer(
        $db: $db,
        $table: $db.cards,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }
}

class $$DecksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DecksTable,
    Deck,
    $$DecksTableFilterComposer,
    $$DecksTableOrderingComposer,
    $$DecksTableAnnotationComposer,
    $$DecksTableCreateCompanionBuilder,
    $$DecksTableUpdateCompanionBuilder,
    (Deck, $$DecksTableReferences),
    Deck,
    PrefetchHooks Function({bool cardsRefs})> {
  $$DecksTableTableManager(_$AppDatabase db, $DecksTable table)
      : super(
          TableManagerState(
            db: db,
            table: table,
            createFilteringComposer: () =>
                $$DecksTableFilterComposer($db: db, $table: table),
            createOrderingComposer: () =>
                $$DecksTableOrderingComposer($db: db, $table: table),
            createComputedFieldComposer: () =>
                $$DecksTableAnnotationComposer($db: db, $table: table),
            updateCompanionCallback: ({
              Value<String> id = const Value.absent(),
              Value<String> title = const Value.absent(),
              Value<String> description = const Value.absent(),
              Value<int> dueCount = const Value.absent(),
              Value<int> newCount = const Value.absent(),
              Value<int> totalCount = const Value.absent(),
              Value<DateTime?> lastStudied = const Value.absent(),
              Value<int> rowid = const Value.absent(),
            }) =>
                DecksCompanion(
              id: id,
              title: title,
              description: description,
              dueCount: dueCount,
              newCount: newCount,
              totalCount: totalCount,
              lastStudied: lastStudied,
              rowid: rowid,
            ),
            createCompanionCallback: ({
              required String id,
              required String title,
              required String description,
              Value<int> dueCount = const Value.absent(),
              Value<int> newCount = const Value.absent(),
              Value<int> totalCount = const Value.absent(),
              Value<DateTime?> lastStudied = const Value.absent(),
              Value<int> rowid = const Value.absent(),
            }) =>
                DecksCompanion.insert(
              id: id,
              title: title,
              description: description,
              dueCount: dueCount,
              newCount: newCount,
              totalCount: totalCount,
              lastStudied: lastStudied,
              rowid: rowid,
            ),
            withReferenceMapper: (p0) => p0
                .map(
                  (e) => (
                    e.readTable<$DecksTable, Deck>(table),
                    $$DecksTableReferences(db, table, e),
                  ),
                )
                .toList(),
            prefetchHooksCallback: ({cardsRefs = false}) {
              return PrefetchHooks(
                db: db,
                explicitlyWatchedTables: [if (cardsRefs) db.cards],
                addJoins: null,
                getPrefetchedDataCallback: (items) async {
                  return [
                    if (cardsRefs)
                      await $_getPrefetchedData<Deck, $DecksTable, Card>(
                        currentTable: table,
                        referencedTable: $$DecksTableReferences._cardsRefsTable(
                          db,
                        ),
                        managerFromTypedResult: (p0) =>
                            $$DecksTableReferences(db, table, p0).cardsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.deckId == item.id),
                        typedResults: items,
                      ),
                  ];
                },
              );
            },
          ),
        );
}

typedef $$DecksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DecksTable,
    Deck,
    $$DecksTableFilterComposer,
    $$DecksTableOrderingComposer,
    $$DecksTableAnnotationComposer,
    $$DecksTableCreateCompanionBuilder,
    $$DecksTableUpdateCompanionBuilder,
    (Deck, $$DecksTableReferences),
    Deck,
    PrefetchHooks Function({bool cardsRefs})>;
typedef $$CardsTableCreateCompanionBuilder = CardsCompanion Function({
  required String id,
  required String deckId,
  required String front,
  required String back,
  Value<String?> hint,
  Value<String> noteType,
  Value<int> flag,
  Value<bool> isSuspended,
  Value<bool> isBuried,
  Value<String> tags,
  Value<int> intervalDays,
  Value<double> stability,
  Value<double> difficulty,
  Value<int> reps,
  Value<int> lapses,
  Value<DateTime?> due,
  Value<DateTime?> lastStudied,
  Value<DateTime?> createdAt,
  Value<int> rowid,
});
typedef $$CardsTableUpdateCompanionBuilder = CardsCompanion Function({
  Value<String> id,
  Value<String> deckId,
  Value<String> front,
  Value<String> back,
  Value<String?> hint,
  Value<String> noteType,
  Value<int> flag,
  Value<bool> isSuspended,
  Value<bool> isBuried,
  Value<String> tags,
  Value<int> intervalDays,
  Value<double> stability,
  Value<double> difficulty,
  Value<int> reps,
  Value<int> lapses,
  Value<DateTime?> due,
  Value<DateTime?> lastStudied,
  Value<DateTime?> createdAt,
  Value<int> rowid,
});

final class $$CardsTableReferences
    extends BaseReferences<_$AppDatabase, $CardsTable, Card> {
  $$CardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DecksTable _deckIdTable(_$AppDatabase db) =>
      db.decks.createAlias('cards__deck_id__decks__id');

  $$DecksTableProcessedTableManager get deckId {
    final $_column = $_itemColumn<String>('deck_id')!;

    final manager = $$DecksTableTableManager(
      $_db,
      $_db.decks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deckIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ReviewLogsTable, List<ReviewLog>>
      _reviewLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
            db.reviewLogs,
            aliasName: 'cards__id__review_logs__card_id',
          );

  $$ReviewLogsTableProcessedTableManager get reviewLogsRefs {
    final manager = $$ReviewLogsTableTableManager(
      $_db,
      $_db.reviewLogs,
    ).filter((f) => f.cardId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_reviewLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CardsTableFilterComposer extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableFilterComposer({
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

  ColumnFilters<String> get front => $composableBuilder(
        column: $table.front,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<String> get back => $composableBuilder(
        column: $table.back,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<String> get hint => $composableBuilder(
        column: $table.hint,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<String> get noteType => $composableBuilder(
        column: $table.noteType,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<int> get flag => $composableBuilder(
        column: $table.flag,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<bool> get isSuspended => $composableBuilder(
        column: $table.isSuspended,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<bool> get isBuried => $composableBuilder(
        column: $table.isBuried,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<String> get tags => $composableBuilder(
        column: $table.tags,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<int> get intervalDays => $composableBuilder(
        column: $table.intervalDays,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<double> get stability => $composableBuilder(
        column: $table.stability,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<double> get difficulty => $composableBuilder(
        column: $table.difficulty,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<int> get reps => $composableBuilder(
        column: $table.reps,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<int> get lapses => $composableBuilder(
        column: $table.lapses,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<DateTime> get due => $composableBuilder(
        column: $table.due,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<DateTime> get lastStudied => $composableBuilder(
        column: $table.lastStudied,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnFilters(column),
      );

  $$DecksTableFilterComposer get deckId {
    final $$DecksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder: (
        joinBuilder, {
        $addJoinBuilderToRootComposer,
        $removeJoinBuilderFromRootComposer,
      }) =>
          $$DecksTableFilterComposer(
        $db: $db,
        $table: $db.decks,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }

  Expression<bool> reviewLogsRefs(
    Expression<bool> Function($$ReviewLogsTableFilterComposer f) f,
  ) {
    final $$ReviewLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviewLogs,
      getReferencedColumn: (t) => t.cardId,
      builder: (
        joinBuilder, {
        $addJoinBuilderToRootComposer,
        $removeJoinBuilderFromRootComposer,
      }) =>
          $$ReviewLogsTableFilterComposer(
        $db: $db,
        $table: $db.reviewLogs,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }
}

class $$CardsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableOrderingComposer({
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

  ColumnOrderings<String> get front => $composableBuilder(
        column: $table.front,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<String> get back => $composableBuilder(
        column: $table.back,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<String> get hint => $composableBuilder(
        column: $table.hint,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<String> get noteType => $composableBuilder(
        column: $table.noteType,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<int> get flag => $composableBuilder(
        column: $table.flag,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<bool> get isSuspended => $composableBuilder(
        column: $table.isSuspended,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<bool> get isBuried => $composableBuilder(
        column: $table.isBuried,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<String> get tags => $composableBuilder(
        column: $table.tags,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<int> get intervalDays => $composableBuilder(
        column: $table.intervalDays,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<double> get stability => $composableBuilder(
        column: $table.stability,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<double> get difficulty => $composableBuilder(
        column: $table.difficulty,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<int> get reps => $composableBuilder(
        column: $table.reps,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<int> get lapses => $composableBuilder(
        column: $table.lapses,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<DateTime> get due => $composableBuilder(
        column: $table.due,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<DateTime> get lastStudied => $composableBuilder(
        column: $table.lastStudied,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnOrderings(column),
      );

  $$DecksTableOrderingComposer get deckId {
    final $$DecksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder: (
        joinBuilder, {
        $addJoinBuilderToRootComposer,
        $removeJoinBuilderFromRootComposer,
      }) =>
          $$DecksTableOrderingComposer(
        $db: $db,
        $table: $db.decks,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$CardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get front =>
      $composableBuilder(column: $table.front, builder: (column) => column);

  GeneratedColumn<String> get back =>
      $composableBuilder(column: $table.back, builder: (column) => column);

  GeneratedColumn<String> get hint =>
      $composableBuilder(column: $table.hint, builder: (column) => column);

  GeneratedColumn<String> get noteType =>
      $composableBuilder(column: $table.noteType, builder: (column) => column);

  GeneratedColumn<int> get flag =>
      $composableBuilder(column: $table.flag, builder: (column) => column);

  GeneratedColumn<bool> get isSuspended => $composableBuilder(
        column: $table.isSuspended,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get isBuried =>
      $composableBuilder(column: $table.isBuried, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<int> get intervalDays => $composableBuilder(
        column: $table.intervalDays,
        builder: (column) => column,
      );

  GeneratedColumn<double> get stability =>
      $composableBuilder(column: $table.stability, builder: (column) => column);

  GeneratedColumn<double> get difficulty => $composableBuilder(
        column: $table.difficulty,
        builder: (column) => column,
      );

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get lapses =>
      $composableBuilder(column: $table.lapses, builder: (column) => column);

  GeneratedColumn<DateTime> get due =>
      $composableBuilder(column: $table.due, builder: (column) => column);

  GeneratedColumn<DateTime> get lastStudied => $composableBuilder(
        column: $table.lastStudied,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$DecksTableAnnotationComposer get deckId {
    final $$DecksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder: (
        joinBuilder, {
        $addJoinBuilderToRootComposer,
        $removeJoinBuilderFromRootComposer,
      }) =>
          $$DecksTableAnnotationComposer(
        $db: $db,
        $table: $db.decks,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }

  Expression<T> reviewLogsRefs<T extends Object>(
    Expression<T> Function($$ReviewLogsTableAnnotationComposer a) f,
  ) {
    final $$ReviewLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reviewLogs,
      getReferencedColumn: (t) => t.cardId,
      builder: (
        joinBuilder, {
        $addJoinBuilderToRootComposer,
        $removeJoinBuilderFromRootComposer,
      }) =>
          $$ReviewLogsTableAnnotationComposer(
        $db: $db,
        $table: $db.reviewLogs,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return f(composer);
  }
}

class $$CardsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CardsTable,
    Card,
    $$CardsTableFilterComposer,
    $$CardsTableOrderingComposer,
    $$CardsTableAnnotationComposer,
    $$CardsTableCreateCompanionBuilder,
    $$CardsTableUpdateCompanionBuilder,
    (Card, $$CardsTableReferences),
    Card,
    PrefetchHooks Function({bool deckId, bool reviewLogsRefs})> {
  $$CardsTableTableManager(_$AppDatabase db, $CardsTable table)
      : super(
          TableManagerState(
            db: db,
            table: table,
            createFilteringComposer: () =>
                $$CardsTableFilterComposer($db: db, $table: table),
            createOrderingComposer: () =>
                $$CardsTableOrderingComposer($db: db, $table: table),
            createComputedFieldComposer: () =>
                $$CardsTableAnnotationComposer($db: db, $table: table),
            updateCompanionCallback: ({
              Value<String> id = const Value.absent(),
              Value<String> deckId = const Value.absent(),
              Value<String> front = const Value.absent(),
              Value<String> back = const Value.absent(),
              Value<String?> hint = const Value.absent(),
              Value<String> noteType = const Value.absent(),
              Value<int> flag = const Value.absent(),
              Value<bool> isSuspended = const Value.absent(),
              Value<bool> isBuried = const Value.absent(),
              Value<String> tags = const Value.absent(),
              Value<int> intervalDays = const Value.absent(),
              Value<double> stability = const Value.absent(),
              Value<double> difficulty = const Value.absent(),
              Value<int> reps = const Value.absent(),
              Value<int> lapses = const Value.absent(),
              Value<DateTime?> due = const Value.absent(),
              Value<DateTime?> lastStudied = const Value.absent(),
              Value<DateTime?> createdAt = const Value.absent(),
              Value<int> rowid = const Value.absent(),
            }) =>
                CardsCompanion(
              id: id,
              deckId: deckId,
              front: front,
              back: back,
              hint: hint,
              noteType: noteType,
              flag: flag,
              isSuspended: isSuspended,
              isBuried: isBuried,
              tags: tags,
              intervalDays: intervalDays,
              stability: stability,
              difficulty: difficulty,
              reps: reps,
              lapses: lapses,
              due: due,
              lastStudied: lastStudied,
              createdAt: createdAt,
              rowid: rowid,
            ),
            createCompanionCallback: ({
              required String id,
              required String deckId,
              required String front,
              required String back,
              Value<String?> hint = const Value.absent(),
              Value<String> noteType = const Value.absent(),
              Value<int> flag = const Value.absent(),
              Value<bool> isSuspended = const Value.absent(),
              Value<bool> isBuried = const Value.absent(),
              Value<String> tags = const Value.absent(),
              Value<int> intervalDays = const Value.absent(),
              Value<double> stability = const Value.absent(),
              Value<double> difficulty = const Value.absent(),
              Value<int> reps = const Value.absent(),
              Value<int> lapses = const Value.absent(),
              Value<DateTime?> due = const Value.absent(),
              Value<DateTime?> lastStudied = const Value.absent(),
              Value<DateTime?> createdAt = const Value.absent(),
              Value<int> rowid = const Value.absent(),
            }) =>
                CardsCompanion.insert(
              id: id,
              deckId: deckId,
              front: front,
              back: back,
              hint: hint,
              noteType: noteType,
              flag: flag,
              isSuspended: isSuspended,
              isBuried: isBuried,
              tags: tags,
              intervalDays: intervalDays,
              stability: stability,
              difficulty: difficulty,
              reps: reps,
              lapses: lapses,
              due: due,
              lastStudied: lastStudied,
              createdAt: createdAt,
              rowid: rowid,
            ),
            withReferenceMapper: (p0) => p0
                .map(
                  (e) => (
                    e.readTable<$CardsTable, Card>(table),
                    $$CardsTableReferences(db, table, e),
                  ),
                )
                .toList(),
            prefetchHooksCallback: ({deckId = false, reviewLogsRefs = false}) {
              return PrefetchHooks(
                db: db,
                explicitlyWatchedTables: [if (reviewLogsRefs) db.reviewLogs],
                addJoins: <
                    T extends TableManagerState<
                        dynamic,
                        dynamic,
                        dynamic,
                        dynamic,
                        dynamic,
                        dynamic,
                        dynamic,
                        dynamic,
                        dynamic,
                        dynamic,
                        dynamic>>(state) {
                  if (deckId) {
                    state = state.withJoin(
                      currentTable: table,
                      currentColumn: table.deckId,
                      referencedTable: $$CardsTableReferences._deckIdTable(
                        db,
                      ),
                      referencedColumn:
                          $$CardsTableReferences._deckIdTable(db).id,
                    ) as T;
                  }

                  return state;
                },
                getPrefetchedDataCallback: (items) async {
                  return [
                    if (reviewLogsRefs)
                      await $_getPrefetchedData<Card, $CardsTable, ReviewLog>(
                        currentTable: table,
                        referencedTable:
                            $$CardsTableReferences._reviewLogsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CardsTableReferences(db, table, p0)
                                .reviewLogsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.cardId == item.id),
                        typedResults: items,
                      ),
                  ];
                },
              );
            },
          ),
        );
}

typedef $$CardsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CardsTable,
    Card,
    $$CardsTableFilterComposer,
    $$CardsTableOrderingComposer,
    $$CardsTableAnnotationComposer,
    $$CardsTableCreateCompanionBuilder,
    $$CardsTableUpdateCompanionBuilder,
    (Card, $$CardsTableReferences),
    Card,
    PrefetchHooks Function({bool deckId, bool reviewLogsRefs})>;
typedef $$ReviewLogsTableCreateCompanionBuilder = ReviewLogsCompanion Function({
  Value<int> id,
  required String cardId,
  required int rating,
  required DateTime reviewTime,
  Value<int> scheduledDays,
  Value<int> elapsedDays,
});
typedef $$ReviewLogsTableUpdateCompanionBuilder = ReviewLogsCompanion Function({
  Value<int> id,
  Value<String> cardId,
  Value<int> rating,
  Value<DateTime> reviewTime,
  Value<int> scheduledDays,
  Value<int> elapsedDays,
});

final class $$ReviewLogsTableReferences
    extends BaseReferences<_$AppDatabase, $ReviewLogsTable, ReviewLog> {
  $$ReviewLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CardsTable _cardIdTable(_$AppDatabase db) =>
      db.cards.createAlias('review_logs__card_id__cards__id');

  $$CardsTableProcessedTableManager get cardId {
    final $_column = $_itemColumn<String>('card_id')!;

    final manager = $$CardsTableTableManager(
      $_db,
      $_db.cards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReviewLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewLogsTable> {
  $$ReviewLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
        column: $table.id,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<int> get rating => $composableBuilder(
        column: $table.rating,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<DateTime> get reviewTime => $composableBuilder(
        column: $table.reviewTime,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<int> get scheduledDays => $composableBuilder(
        column: $table.scheduledDays,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<int> get elapsedDays => $composableBuilder(
        column: $table.elapsedDays,
        builder: (column) => ColumnFilters(column),
      );

  $$CardsTableFilterComposer get cardId {
    final $$CardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder: (
        joinBuilder, {
        $addJoinBuilderToRootComposer,
        $removeJoinBuilderFromRootComposer,
      }) =>
          $$CardsTableFilterComposer(
        $db: $db,
        $table: $db.cards,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$ReviewLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewLogsTable> {
  $$ReviewLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
        column: $table.id,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<int> get rating => $composableBuilder(
        column: $table.rating,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<DateTime> get reviewTime => $composableBuilder(
        column: $table.reviewTime,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<int> get scheduledDays => $composableBuilder(
        column: $table.scheduledDays,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<int> get elapsedDays => $composableBuilder(
        column: $table.elapsedDays,
        builder: (column) => ColumnOrderings(column),
      );

  $$CardsTableOrderingComposer get cardId {
    final $$CardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder: (
        joinBuilder, {
        $addJoinBuilderToRootComposer,
        $removeJoinBuilderFromRootComposer,
      }) =>
          $$CardsTableOrderingComposer(
        $db: $db,
        $table: $db.cards,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$ReviewLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewLogsTable> {
  $$ReviewLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<DateTime> get reviewTime => $composableBuilder(
        column: $table.reviewTime,
        builder: (column) => column,
      );

  GeneratedColumn<int> get scheduledDays => $composableBuilder(
        column: $table.scheduledDays,
        builder: (column) => column,
      );

  GeneratedColumn<int> get elapsedDays => $composableBuilder(
        column: $table.elapsedDays,
        builder: (column) => column,
      );

  $$CardsTableAnnotationComposer get cardId {
    final $$CardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder: (
        joinBuilder, {
        $addJoinBuilderToRootComposer,
        $removeJoinBuilderFromRootComposer,
      }) =>
          $$CardsTableAnnotationComposer(
        $db: $db,
        $table: $db.cards,
        $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
        joinBuilder: joinBuilder,
        $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
      ),
    );
    return composer;
  }
}

class $$ReviewLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReviewLogsTable,
    ReviewLog,
    $$ReviewLogsTableFilterComposer,
    $$ReviewLogsTableOrderingComposer,
    $$ReviewLogsTableAnnotationComposer,
    $$ReviewLogsTableCreateCompanionBuilder,
    $$ReviewLogsTableUpdateCompanionBuilder,
    (ReviewLog, $$ReviewLogsTableReferences),
    ReviewLog,
    PrefetchHooks Function({bool cardId})> {
  $$ReviewLogsTableTableManager(_$AppDatabase db, $ReviewLogsTable table)
      : super(
          TableManagerState(
            db: db,
            table: table,
            createFilteringComposer: () =>
                $$ReviewLogsTableFilterComposer($db: db, $table: table),
            createOrderingComposer: () =>
                $$ReviewLogsTableOrderingComposer($db: db, $table: table),
            createComputedFieldComposer: () =>
                $$ReviewLogsTableAnnotationComposer($db: db, $table: table),
            updateCompanionCallback: ({
              Value<int> id = const Value.absent(),
              Value<String> cardId = const Value.absent(),
              Value<int> rating = const Value.absent(),
              Value<DateTime> reviewTime = const Value.absent(),
              Value<int> scheduledDays = const Value.absent(),
              Value<int> elapsedDays = const Value.absent(),
            }) =>
                ReviewLogsCompanion(
              id: id,
              cardId: cardId,
              rating: rating,
              reviewTime: reviewTime,
              scheduledDays: scheduledDays,
              elapsedDays: elapsedDays,
            ),
            createCompanionCallback: ({
              Value<int> id = const Value.absent(),
              required String cardId,
              required int rating,
              required DateTime reviewTime,
              Value<int> scheduledDays = const Value.absent(),
              Value<int> elapsedDays = const Value.absent(),
            }) =>
                ReviewLogsCompanion.insert(
              id: id,
              cardId: cardId,
              rating: rating,
              reviewTime: reviewTime,
              scheduledDays: scheduledDays,
              elapsedDays: elapsedDays,
            ),
            withReferenceMapper: (p0) => p0
                .map(
                  (e) => (
                    e.readTable<$ReviewLogsTable, ReviewLog>(table),
                    $$ReviewLogsTableReferences(db, table, e),
                  ),
                )
                .toList(),
            prefetchHooksCallback: ({cardId = false}) {
              return PrefetchHooks(
                db: db,
                explicitlyWatchedTables: [],
                addJoins: <
                    T extends TableManagerState<
                        dynamic,
                        dynamic,
                        dynamic,
                        dynamic,
                        dynamic,
                        dynamic,
                        dynamic,
                        dynamic,
                        dynamic,
                        dynamic,
                        dynamic>>(state) {
                  if (cardId) {
                    state = state.withJoin(
                      currentTable: table,
                      currentColumn: table.cardId,
                      referencedTable:
                          $$ReviewLogsTableReferences._cardIdTable(db),
                      referencedColumn:
                          $$ReviewLogsTableReferences._cardIdTable(db).id,
                    ) as T;
                  }

                  return state;
                },
                getPrefetchedDataCallback: (items) async {
                  return [];
                },
              );
            },
          ),
        );
}

typedef $$ReviewLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReviewLogsTable,
    ReviewLog,
    $$ReviewLogsTableFilterComposer,
    $$ReviewLogsTableOrderingComposer,
    $$ReviewLogsTableAnnotationComposer,
    $$ReviewLogsTableCreateCompanionBuilder,
    $$ReviewLogsTableUpdateCompanionBuilder,
    (ReviewLog, $$ReviewLogsTableReferences),
    ReviewLog,
    PrefetchHooks Function({bool cardId})>;
typedef $$GrammarProgressEntriesTableCreateCompanionBuilder
    = GrammarProgressEntriesCompanion Function({
  required String unitId,
  required String exerciseId,
  Value<double> stability,
  Value<double> difficulty,
  Value<DateTime?> due,
  Value<DateTime?> lastStudied,
  Value<int> reps,
  Value<int> lapses,
  Value<CardState> state,
  Value<bool> isGhost,
  Value<bool> isCompleted,
  Value<String?> lastUserAnswer,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$GrammarProgressEntriesTableUpdateCompanionBuilder
    = GrammarProgressEntriesCompanion Function({
  Value<String> unitId,
  Value<String> exerciseId,
  Value<double> stability,
  Value<double> difficulty,
  Value<DateTime?> due,
  Value<DateTime?> lastStudied,
  Value<int> reps,
  Value<int> lapses,
  Value<CardState> state,
  Value<bool> isGhost,
  Value<bool> isCompleted,
  Value<String?> lastUserAnswer,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$GrammarProgressEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $GrammarProgressEntriesTable> {
  $$GrammarProgressEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get unitId => $composableBuilder(
        column: $table.unitId,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<String> get exerciseId => $composableBuilder(
        column: $table.exerciseId,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<double> get stability => $composableBuilder(
        column: $table.stability,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<double> get difficulty => $composableBuilder(
        column: $table.difficulty,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<DateTime> get due => $composableBuilder(
        column: $table.due,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<DateTime> get lastStudied => $composableBuilder(
        column: $table.lastStudied,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<int> get reps => $composableBuilder(
        column: $table.reps,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<int> get lapses => $composableBuilder(
        column: $table.lapses,
        builder: (column) => ColumnFilters(column),
      );

  ColumnWithTypeConverterFilters<CardState, CardState, int> get state =>
      $composableBuilder(
        column: $table.state,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get isGhost => $composableBuilder(
        column: $table.isGhost,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
        column: $table.isCompleted,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<String> get lastUserAnswer => $composableBuilder(
        column: $table.lastUserAnswer,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnFilters(column),
      );
}

class $$GrammarProgressEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $GrammarProgressEntriesTable> {
  $$GrammarProgressEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get unitId => $composableBuilder(
        column: $table.unitId,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<String> get exerciseId => $composableBuilder(
        column: $table.exerciseId,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<double> get stability => $composableBuilder(
        column: $table.stability,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<double> get difficulty => $composableBuilder(
        column: $table.difficulty,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<DateTime> get due => $composableBuilder(
        column: $table.due,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<DateTime> get lastStudied => $composableBuilder(
        column: $table.lastStudied,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<int> get reps => $composableBuilder(
        column: $table.reps,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<int> get lapses => $composableBuilder(
        column: $table.lapses,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<int> get state => $composableBuilder(
        column: $table.state,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<bool> get isGhost => $composableBuilder(
        column: $table.isGhost,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
        column: $table.isCompleted,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<String> get lastUserAnswer => $composableBuilder(
        column: $table.lastUserAnswer,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnOrderings(column),
      );
}

class $$GrammarProgressEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GrammarProgressEntriesTable> {
  $$GrammarProgressEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get unitId =>
      $composableBuilder(column: $table.unitId, builder: (column) => column);

  GeneratedColumn<String> get exerciseId => $composableBuilder(
        column: $table.exerciseId,
        builder: (column) => column,
      );

  GeneratedColumn<double> get stability =>
      $composableBuilder(column: $table.stability, builder: (column) => column);

  GeneratedColumn<double> get difficulty => $composableBuilder(
        column: $table.difficulty,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get due =>
      $composableBuilder(column: $table.due, builder: (column) => column);

  GeneratedColumn<DateTime> get lastStudied => $composableBuilder(
        column: $table.lastStudied,
        builder: (column) => column,
      );

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get lapses =>
      $composableBuilder(column: $table.lapses, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CardState, int> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<bool> get isGhost =>
      $composableBuilder(column: $table.isGhost, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
        column: $table.isCompleted,
        builder: (column) => column,
      );

  GeneratedColumn<String> get lastUserAnswer => $composableBuilder(
        column: $table.lastUserAnswer,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$GrammarProgressEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GrammarProgressEntriesTable,
    GrammarProgressEntry,
    $$GrammarProgressEntriesTableFilterComposer,
    $$GrammarProgressEntriesTableOrderingComposer,
    $$GrammarProgressEntriesTableAnnotationComposer,
    $$GrammarProgressEntriesTableCreateCompanionBuilder,
    $$GrammarProgressEntriesTableUpdateCompanionBuilder,
    (
      GrammarProgressEntry,
      BaseReferences<_$AppDatabase, $GrammarProgressEntriesTable,
          GrammarProgressEntry>,
    ),
    GrammarProgressEntry,
    PrefetchHooks Function()> {
  $$GrammarProgressEntriesTableTableManager(
    _$AppDatabase db,
    $GrammarProgressEntriesTable table,
  ) : super(
          TableManagerState(
            db: db,
            table: table,
            createFilteringComposer: () =>
                $$GrammarProgressEntriesTableFilterComposer(
              $db: db,
              $table: table,
            ),
            createOrderingComposer: () =>
                $$GrammarProgressEntriesTableOrderingComposer(
              $db: db,
              $table: table,
            ),
            createComputedFieldComposer: () =>
                $$GrammarProgressEntriesTableAnnotationComposer(
              $db: db,
              $table: table,
            ),
            updateCompanionCallback: ({
              Value<String> unitId = const Value.absent(),
              Value<String> exerciseId = const Value.absent(),
              Value<double> stability = const Value.absent(),
              Value<double> difficulty = const Value.absent(),
              Value<DateTime?> due = const Value.absent(),
              Value<DateTime?> lastStudied = const Value.absent(),
              Value<int> reps = const Value.absent(),
              Value<int> lapses = const Value.absent(),
              Value<CardState> state = const Value.absent(),
              Value<bool> isGhost = const Value.absent(),
              Value<bool> isCompleted = const Value.absent(),
              Value<String?> lastUserAnswer = const Value.absent(),
              Value<DateTime> updatedAt = const Value.absent(),
              Value<int> rowid = const Value.absent(),
            }) =>
                GrammarProgressEntriesCompanion(
              unitId: unitId,
              exerciseId: exerciseId,
              stability: stability,
              difficulty: difficulty,
              due: due,
              lastStudied: lastStudied,
              reps: reps,
              lapses: lapses,
              state: state,
              isGhost: isGhost,
              isCompleted: isCompleted,
              lastUserAnswer: lastUserAnswer,
              updatedAt: updatedAt,
              rowid: rowid,
            ),
            createCompanionCallback: ({
              required String unitId,
              required String exerciseId,
              Value<double> stability = const Value.absent(),
              Value<double> difficulty = const Value.absent(),
              Value<DateTime?> due = const Value.absent(),
              Value<DateTime?> lastStudied = const Value.absent(),
              Value<int> reps = const Value.absent(),
              Value<int> lapses = const Value.absent(),
              Value<CardState> state = const Value.absent(),
              Value<bool> isGhost = const Value.absent(),
              Value<bool> isCompleted = const Value.absent(),
              Value<String?> lastUserAnswer = const Value.absent(),
              Value<DateTime> updatedAt = const Value.absent(),
              Value<int> rowid = const Value.absent(),
            }) =>
                GrammarProgressEntriesCompanion.insert(
              unitId: unitId,
              exerciseId: exerciseId,
              stability: stability,
              difficulty: difficulty,
              due: due,
              lastStudied: lastStudied,
              reps: reps,
              lapses: lapses,
              state: state,
              isGhost: isGhost,
              isCompleted: isCompleted,
              lastUserAnswer: lastUserAnswer,
              updatedAt: updatedAt,
              rowid: rowid,
            ),
            withReferenceMapper: (p0) => p0
                .map(
                  (e) => (
                    e.readTable<$GrammarProgressEntriesTable,
                        GrammarProgressEntry>(table),
                    BaseReferences<_$AppDatabase, $GrammarProgressEntriesTable,
                        GrammarProgressEntry>(db, table, e),
                  ),
                )
                .toList(),
            prefetchHooksCallback: null,
          ),
        );
}

typedef $$GrammarProgressEntriesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $GrammarProgressEntriesTable,
        GrammarProgressEntry,
        $$GrammarProgressEntriesTableFilterComposer,
        $$GrammarProgressEntriesTableOrderingComposer,
        $$GrammarProgressEntriesTableAnnotationComposer,
        $$GrammarProgressEntriesTableCreateCompanionBuilder,
        $$GrammarProgressEntriesTableUpdateCompanionBuilder,
        (
          GrammarProgressEntry,
          BaseReferences<_$AppDatabase, $GrammarProgressEntriesTable,
              GrammarProgressEntry>,
        ),
        GrammarProgressEntry,
        PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DecksTableTableManager get decks =>
      $$DecksTableTableManager(_db, _db.decks);
  $$CardsTableTableManager get cards =>
      $$CardsTableTableManager(_db, _db.cards);
  $$ReviewLogsTableTableManager get reviewLogs =>
      $$ReviewLogsTableTableManager(_db, _db.reviewLogs);
  $$GrammarProgressEntriesTableTableManager get grammarProgressEntries =>
      $$GrammarProgressEntriesTableTableManager(
        _db,
        _db.grammarProgressEntries,
      );
}
