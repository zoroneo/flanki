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
  static const VerificationMeta _updatedAtHlcMeta = const VerificationMeta(
    'updatedAtHlc',
  );
  @override
  late final GeneratedColumn<String> updatedAtHlc = GeneratedColumn<String>(
    'updated_at_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    updatedAtHlc,
    isDeleted,
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
    if (data.containsKey('updated_at_hlc')) {
      context.handle(
        _updatedAtHlcMeta,
        updatedAtHlc.isAcceptableOrUnknown(
          data['updated_at_hlc']!,
          _updatedAtHlcMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
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
      updatedAtHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_hlc'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
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
  final String updatedAtHlc;
  final bool isDeleted;
  const Deck({
    required this.id,
    required this.title,
    required this.description,
    required this.dueCount,
    required this.newCount,
    required this.totalCount,
    this.lastStudied,
    required this.updatedAtHlc,
    required this.isDeleted,
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
    map['updated_at_hlc'] = Variable<String>(updatedAtHlc);
    map['is_deleted'] = Variable<bool>(isDeleted);
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
      updatedAtHlc: Value(updatedAtHlc),
      isDeleted: Value(isDeleted),
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
      updatedAtHlc: serializer.fromJson<String>(json['updatedAtHlc']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
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
      'updatedAtHlc': serializer.toJson<String>(updatedAtHlc),
      'isDeleted': serializer.toJson<bool>(isDeleted),
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
    String? updatedAtHlc,
    bool? isDeleted,
  }) => Deck(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    dueCount: dueCount ?? this.dueCount,
    newCount: newCount ?? this.newCount,
    totalCount: totalCount ?? this.totalCount,
    lastStudied: lastStudied.present ? lastStudied.value : this.lastStudied,
    updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  Deck copyWithCompanion(DecksCompanion data) {
    return Deck(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      dueCount: data.dueCount.present ? data.dueCount.value : this.dueCount,
      newCount: data.newCount.present ? data.newCount.value : this.newCount,
      totalCount: data.totalCount.present
          ? data.totalCount.value
          : this.totalCount,
      lastStudied: data.lastStudied.present
          ? data.lastStudied.value
          : this.lastStudied,
      updatedAtHlc: data.updatedAtHlc.present
          ? data.updatedAtHlc.value
          : this.updatedAtHlc,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
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
          ..write('lastStudied: $lastStudied, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('isDeleted: $isDeleted')
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
    updatedAtHlc,
    isDeleted,
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
          other.lastStudied == this.lastStudied &&
          other.updatedAtHlc == this.updatedAtHlc &&
          other.isDeleted == this.isDeleted);
}

class DecksCompanion extends UpdateCompanion<Deck> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<int> dueCount;
  final Value<int> newCount;
  final Value<int> totalCount;
  final Value<DateTime?> lastStudied;
  final Value<String> updatedAtHlc;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const DecksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.dueCount = const Value.absent(),
    this.newCount = const Value.absent(),
    this.totalCount = const Value.absent(),
    this.lastStudied = const Value.absent(),
    this.updatedAtHlc = const Value.absent(),
    this.isDeleted = const Value.absent(),
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
    this.updatedAtHlc = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
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
    Expression<String>? updatedAtHlc,
    Expression<bool>? isDeleted,
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
      if (updatedAtHlc != null) 'updated_at_hlc': updatedAtHlc,
      if (isDeleted != null) 'is_deleted': isDeleted,
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
    Value<String>? updatedAtHlc,
    Value<bool>? isDeleted,
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
      updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      isDeleted: isDeleted ?? this.isDeleted,
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
    if (updatedAtHlc.present) {
      map['updated_at_hlc'] = Variable<String>(updatedAtHlc.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
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
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('isDeleted: $isDeleted, ')
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
  static const VerificationMeta _updatedAtHlcMeta = const VerificationMeta(
    'updatedAtHlc',
  );
  @override
  late final GeneratedColumn<String> updatedAtHlc = GeneratedColumn<String>(
    'updated_at_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    updatedAtHlc,
    isDeleted,
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
    if (data.containsKey('updated_at_hlc')) {
      context.handle(
        _updatedAtHlcMeta,
        updatedAtHlc.isAcceptableOrUnknown(
          data['updated_at_hlc']!,
          _updatedAtHlcMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
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
      updatedAtHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_hlc'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
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
  final String updatedAtHlc;
  final bool isDeleted;
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
    required this.updatedAtHlc,
    required this.isDeleted,
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
    map['updated_at_hlc'] = Variable<String>(updatedAtHlc);
    map['is_deleted'] = Variable<bool>(isDeleted);
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
      updatedAtHlc: Value(updatedAtHlc),
      isDeleted: Value(isDeleted),
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
      updatedAtHlc: serializer.fromJson<String>(json['updatedAtHlc']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
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
      'updatedAtHlc': serializer.toJson<String>(updatedAtHlc),
      'isDeleted': serializer.toJson<bool>(isDeleted),
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
    String? updatedAtHlc,
    bool? isDeleted,
  }) => Card(
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
    updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
    isDeleted: isDeleted ?? this.isDeleted,
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
      isSuspended: data.isSuspended.present
          ? data.isSuspended.value
          : this.isSuspended,
      isBuried: data.isBuried.present ? data.isBuried.value : this.isBuried,
      tags: data.tags.present ? data.tags.value : this.tags,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      stability: data.stability.present ? data.stability.value : this.stability,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      reps: data.reps.present ? data.reps.value : this.reps,
      lapses: data.lapses.present ? data.lapses.value : this.lapses,
      due: data.due.present ? data.due.value : this.due,
      lastStudied: data.lastStudied.present
          ? data.lastStudied.value
          : this.lastStudied,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAtHlc: data.updatedAtHlc.present
          ? data.updatedAtHlc.value
          : this.updatedAtHlc,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
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
          ..write('createdAt: $createdAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('isDeleted: $isDeleted')
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
    updatedAtHlc,
    isDeleted,
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
          other.createdAt == this.createdAt &&
          other.updatedAtHlc == this.updatedAtHlc &&
          other.isDeleted == this.isDeleted);
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
  final Value<String> updatedAtHlc;
  final Value<bool> isDeleted;
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
    this.updatedAtHlc = const Value.absent(),
    this.isDeleted = const Value.absent(),
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
    this.updatedAtHlc = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
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
    Expression<String>? updatedAtHlc,
    Expression<bool>? isDeleted,
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
      if (updatedAtHlc != null) 'updated_at_hlc': updatedAtHlc,
      if (isDeleted != null) 'is_deleted': isDeleted,
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
    Value<String>? updatedAtHlc,
    Value<bool>? isDeleted,
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
      updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      isDeleted: isDeleted ?? this.isDeleted,
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
    if (updatedAtHlc.present) {
      map['updated_at_hlc'] = Variable<String>(updatedAtHlc.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
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
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('isDeleted: $isDeleted, ')
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
  static const VerificationMeta _clientLogIdMeta = const VerificationMeta(
    'clientLogId',
  );
  @override
  late final GeneratedColumn<String> clientLogId = GeneratedColumn<String>(
    'client_log_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardId,
    rating,
    reviewTime,
    scheduledDays,
    elapsedDays,
    clientLogId,
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
    if (data.containsKey('client_log_id')) {
      context.handle(
        _clientLogIdMeta,
        clientLogId.isAcceptableOrUnknown(
          data['client_log_id']!,
          _clientLogIdMeta,
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
      clientLogId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_log_id'],
      ),
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
  final String? clientLogId;
  const ReviewLog({
    required this.id,
    required this.cardId,
    required this.rating,
    required this.reviewTime,
    required this.scheduledDays,
    required this.elapsedDays,
    this.clientLogId,
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
    if (!nullToAbsent || clientLogId != null) {
      map['client_log_id'] = Variable<String>(clientLogId);
    }
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
      clientLogId: clientLogId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientLogId),
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
      clientLogId: serializer.fromJson<String?>(json['clientLogId']),
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
      'clientLogId': serializer.toJson<String?>(clientLogId),
    };
  }

  ReviewLog copyWith({
    int? id,
    String? cardId,
    int? rating,
    DateTime? reviewTime,
    int? scheduledDays,
    int? elapsedDays,
    Value<String?> clientLogId = const Value.absent(),
  }) => ReviewLog(
    id: id ?? this.id,
    cardId: cardId ?? this.cardId,
    rating: rating ?? this.rating,
    reviewTime: reviewTime ?? this.reviewTime,
    scheduledDays: scheduledDays ?? this.scheduledDays,
    elapsedDays: elapsedDays ?? this.elapsedDays,
    clientLogId: clientLogId.present ? clientLogId.value : this.clientLogId,
  );
  ReviewLog copyWithCompanion(ReviewLogsCompanion data) {
    return ReviewLog(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      rating: data.rating.present ? data.rating.value : this.rating,
      reviewTime: data.reviewTime.present
          ? data.reviewTime.value
          : this.reviewTime,
      scheduledDays: data.scheduledDays.present
          ? data.scheduledDays.value
          : this.scheduledDays,
      elapsedDays: data.elapsedDays.present
          ? data.elapsedDays.value
          : this.elapsedDays,
      clientLogId: data.clientLogId.present
          ? data.clientLogId.value
          : this.clientLogId,
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
          ..write('elapsedDays: $elapsedDays, ')
          ..write('clientLogId: $clientLogId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cardId,
    rating,
    reviewTime,
    scheduledDays,
    elapsedDays,
    clientLogId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewLog &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.rating == this.rating &&
          other.reviewTime == this.reviewTime &&
          other.scheduledDays == this.scheduledDays &&
          other.elapsedDays == this.elapsedDays &&
          other.clientLogId == this.clientLogId);
}

class ReviewLogsCompanion extends UpdateCompanion<ReviewLog> {
  final Value<int> id;
  final Value<String> cardId;
  final Value<int> rating;
  final Value<DateTime> reviewTime;
  final Value<int> scheduledDays;
  final Value<int> elapsedDays;
  final Value<String?> clientLogId;
  const ReviewLogsCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.rating = const Value.absent(),
    this.reviewTime = const Value.absent(),
    this.scheduledDays = const Value.absent(),
    this.elapsedDays = const Value.absent(),
    this.clientLogId = const Value.absent(),
  });
  ReviewLogsCompanion.insert({
    this.id = const Value.absent(),
    required String cardId,
    required int rating,
    required DateTime reviewTime,
    this.scheduledDays = const Value.absent(),
    this.elapsedDays = const Value.absent(),
    this.clientLogId = const Value.absent(),
  }) : cardId = Value(cardId),
       rating = Value(rating),
       reviewTime = Value(reviewTime);
  static Insertable<ReviewLog> custom({
    Expression<int>? id,
    Expression<String>? cardId,
    Expression<int>? rating,
    Expression<DateTime>? reviewTime,
    Expression<int>? scheduledDays,
    Expression<int>? elapsedDays,
    Expression<String>? clientLogId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (rating != null) 'rating': rating,
      if (reviewTime != null) 'review_time': reviewTime,
      if (scheduledDays != null) 'scheduled_days': scheduledDays,
      if (elapsedDays != null) 'elapsed_days': elapsedDays,
      if (clientLogId != null) 'client_log_id': clientLogId,
    });
  }

  ReviewLogsCompanion copyWith({
    Value<int>? id,
    Value<String>? cardId,
    Value<int>? rating,
    Value<DateTime>? reviewTime,
    Value<int>? scheduledDays,
    Value<int>? elapsedDays,
    Value<String?>? clientLogId,
  }) {
    return ReviewLogsCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      rating: rating ?? this.rating,
      reviewTime: reviewTime ?? this.reviewTime,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      elapsedDays: elapsedDays ?? this.elapsedDays,
      clientLogId: clientLogId ?? this.clientLogId,
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
    if (clientLogId.present) {
      map['client_log_id'] = Variable<String>(clientLogId.value);
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
          ..write('elapsedDays: $elapsedDays, ')
          ..write('clientLogId: $clientLogId')
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
  static const VerificationMeta _updatedAtHlcMeta = const VerificationMeta(
    'updatedAtHlc',
  );
  @override
  late final GeneratedColumn<String> updatedAtHlc = GeneratedColumn<String>(
    'updated_at_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    updatedAtHlc,
    isDeleted,
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
    if (data.containsKey('updated_at_hlc')) {
      context.handle(
        _updatedAtHlcMeta,
        updatedAtHlc.isAcceptableOrUnknown(
          data['updated_at_hlc']!,
          _updatedAtHlcMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
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
      updatedAtHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_hlc'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
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
  final String updatedAtHlc;
  final bool isDeleted;
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
    required this.updatedAtHlc,
    required this.isDeleted,
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
    map['updated_at_hlc'] = Variable<String>(updatedAtHlc);
    map['is_deleted'] = Variable<bool>(isDeleted);
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
      updatedAtHlc: Value(updatedAtHlc),
      isDeleted: Value(isDeleted),
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
      updatedAtHlc: serializer.fromJson<String>(json['updatedAtHlc']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
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
      'updatedAtHlc': serializer.toJson<String>(updatedAtHlc),
      'isDeleted': serializer.toJson<bool>(isDeleted),
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
    String? updatedAtHlc,
    bool? isDeleted,
  }) => GrammarProgressEntry(
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
    lastUserAnswer: lastUserAnswer.present
        ? lastUserAnswer.value
        : this.lastUserAnswer,
    updatedAt: updatedAt ?? this.updatedAt,
    updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  GrammarProgressEntry copyWithCompanion(GrammarProgressEntriesCompanion data) {
    return GrammarProgressEntry(
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      stability: data.stability.present ? data.stability.value : this.stability,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      due: data.due.present ? data.due.value : this.due,
      lastStudied: data.lastStudied.present
          ? data.lastStudied.value
          : this.lastStudied,
      reps: data.reps.present ? data.reps.value : this.reps,
      lapses: data.lapses.present ? data.lapses.value : this.lapses,
      state: data.state.present ? data.state.value : this.state,
      isGhost: data.isGhost.present ? data.isGhost.value : this.isGhost,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      lastUserAnswer: data.lastUserAnswer.present
          ? data.lastUserAnswer.value
          : this.lastUserAnswer,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedAtHlc: data.updatedAtHlc.present
          ? data.updatedAtHlc.value
          : this.updatedAtHlc,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
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
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('isDeleted: $isDeleted')
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
    updatedAtHlc,
    isDeleted,
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
          other.updatedAt == this.updatedAt &&
          other.updatedAtHlc == this.updatedAtHlc &&
          other.isDeleted == this.isDeleted);
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
  final Value<String> updatedAtHlc;
  final Value<bool> isDeleted;
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
    this.updatedAtHlc = const Value.absent(),
    this.isDeleted = const Value.absent(),
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
    this.updatedAtHlc = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : unitId = Value(unitId),
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
    Expression<String>? updatedAtHlc,
    Expression<bool>? isDeleted,
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
      if (updatedAtHlc != null) 'updated_at_hlc': updatedAtHlc,
      if (isDeleted != null) 'is_deleted': isDeleted,
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
    Value<String>? updatedAtHlc,
    Value<bool>? isDeleted,
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
      updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      isDeleted: isDeleted ?? this.isDeleted,
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
    if (updatedAtHlc.present) {
      map['updated_at_hlc'] = Variable<String>(updatedAtHlc.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
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
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxTable extends SyncOutbox
    with TableInfo<$SyncOutboxTable, SyncOutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMeta = const VerificationMeta('hlc');
  @override
  late final GeneratedColumn<String> hlc = GeneratedColumn<String>(
    'hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    operation,
    payloadJson,
    hlc,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('hlc')) {
      context.handle(
        _hlcMeta,
        hlc.isAcceptableOrUnknown(data['hlc']!, _hlcMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMeta);
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
  SyncOutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      hlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SyncOutboxTable createAlias(String alias) {
    return $SyncOutboxTable(attachedDatabase, alias);
  }
}

class SyncOutboxData extends DataClass implements Insertable<SyncOutboxData> {
  final String id;
  final String entityType;
  final String entityId;
  final String operation;
  final String payloadJson;
  final String hlc;
  final DateTime createdAt;
  const SyncOutboxData({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payloadJson,
    required this.hlc,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['payload_json'] = Variable<String>(payloadJson);
    map['hlc'] = Variable<String>(hlc);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      payloadJson: Value(payloadJson),
      hlc: Value(hlc),
      createdAt: Value(createdAt),
    );
  }

  factory SyncOutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxData(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      hlc: serializer.fromJson<String>(json['hlc']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'hlc': serializer.toJson<String>(hlc),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncOutboxData copyWith({
    String? id,
    String? entityType,
    String? entityId,
    String? operation,
    String? payloadJson,
    String? hlc,
    DateTime? createdAt,
  }) => SyncOutboxData(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    payloadJson: payloadJson ?? this.payloadJson,
    hlc: hlc ?? this.hlc,
    createdAt: createdAt ?? this.createdAt,
  );
  SyncOutboxData copyWithCompanion(SyncOutboxCompanion data) {
    return SyncOutboxData(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      hlc: data.hlc.present ? data.hlc.value : this.hlc,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxData(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('hlc: $hlc, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    operation,
    payloadJson,
    hlc,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxData &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payloadJson == this.payloadJson &&
          other.hlc == this.hlc &&
          other.createdAt == this.createdAt);
}

class SyncOutboxCompanion extends UpdateCompanion<SyncOutboxData> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> payloadJson;
  final Value<String> hlc;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SyncOutboxCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.hlc = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required String operation,
    required String payloadJson,
    required String hlc,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityType = Value(entityType),
       entityId = Value(entityId),
       operation = Value(operation),
       payloadJson = Value(payloadJson),
       hlc = Value(hlc);
  static Insertable<SyncOutboxData> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payloadJson,
    Expression<String>? hlc,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (hlc != null) 'hlc': hlc,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOutboxCompanion copyWith({
    Value<String>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? operation,
    Value<String>? payloadJson,
    Value<String>? hlc,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SyncOutboxCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payloadJson: payloadJson ?? this.payloadJson,
      hlc: hlc ?? this.hlc,
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
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (hlc.present) {
      map['hlc'] = Variable<String>(hlc.value);
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
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('hlc: $hlc, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorsTable extends SyncCursors
    with TableInfo<$SyncCursorsTable, SyncCursor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastServerHlcMeta = const VerificationMeta(
    'lastServerHlc',
  );
  @override
  late final GeneratedColumn<String> lastServerHlc = GeneratedColumn<String>(
    'last_server_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    entityType,
    lastServerHlc,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncCursor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('last_server_hlc')) {
      context.handle(
        _lastServerHlcMeta,
        lastServerHlc.isAcceptableOrUnknown(
          data['last_server_hlc']!,
          _lastServerHlcMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityType};
  @override
  SyncCursor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursor(
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      lastServerHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_server_hlc'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      )!,
    );
  }

  @override
  $SyncCursorsTable createAlias(String alias) {
    return $SyncCursorsTable(attachedDatabase, alias);
  }
}

class SyncCursor extends DataClass implements Insertable<SyncCursor> {
  final String entityType;
  final String lastServerHlc;
  final DateTime lastSyncedAt;
  const SyncCursor({
    required this.entityType,
    required this.lastServerHlc,
    required this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_type'] = Variable<String>(entityType);
    map['last_server_hlc'] = Variable<String>(lastServerHlc);
    map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    return map;
  }

  SyncCursorsCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorsCompanion(
      entityType: Value(entityType),
      lastServerHlc: Value(lastServerHlc),
      lastSyncedAt: Value(lastSyncedAt),
    );
  }

  factory SyncCursor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursor(
      entityType: serializer.fromJson<String>(json['entityType']),
      lastServerHlc: serializer.fromJson<String>(json['lastServerHlc']),
      lastSyncedAt: serializer.fromJson<DateTime>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityType': serializer.toJson<String>(entityType),
      'lastServerHlc': serializer.toJson<String>(lastServerHlc),
      'lastSyncedAt': serializer.toJson<DateTime>(lastSyncedAt),
    };
  }

  SyncCursor copyWith({
    String? entityType,
    String? lastServerHlc,
    DateTime? lastSyncedAt,
  }) => SyncCursor(
    entityType: entityType ?? this.entityType,
    lastServerHlc: lastServerHlc ?? this.lastServerHlc,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
  );
  SyncCursor copyWithCompanion(SyncCursorsCompanion data) {
    return SyncCursor(
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      lastServerHlc: data.lastServerHlc.present
          ? data.lastServerHlc.value
          : this.lastServerHlc,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursor(')
          ..write('entityType: $entityType, ')
          ..write('lastServerHlc: $lastServerHlc, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entityType, lastServerHlc, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursor &&
          other.entityType == this.entityType &&
          other.lastServerHlc == this.lastServerHlc &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class SyncCursorsCompanion extends UpdateCompanion<SyncCursor> {
  final Value<String> entityType;
  final Value<String> lastServerHlc;
  final Value<DateTime> lastSyncedAt;
  final Value<int> rowid;
  const SyncCursorsCompanion({
    this.entityType = const Value.absent(),
    this.lastServerHlc = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursorsCompanion.insert({
    required String entityType,
    this.lastServerHlc = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : entityType = Value(entityType);
  static Insertable<SyncCursor> custom({
    Expression<String>? entityType,
    Expression<String>? lastServerHlc,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityType != null) 'entity_type': entityType,
      if (lastServerHlc != null) 'last_server_hlc': lastServerHlc,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursorsCompanion copyWith({
    Value<String>? entityType,
    Value<String>? lastServerHlc,
    Value<DateTime>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return SyncCursorsCompanion(
      entityType: entityType ?? this.entityType,
      lastServerHlc: lastServerHlc ?? this.lastServerHlc,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (lastServerHlc.present) {
      map['last_server_hlc'] = Variable<String>(lastServerHlc.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsCompanion(')
          ..write('entityType: $entityType, ')
          ..write('lastServerHlc: $lastServerHlc, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExamPapersTable extends ExamPapers
    with TableInfo<$ExamPapersTable, ExamPaper> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExamPapersTable(this.attachedDatabase, [this._alias]);
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
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('JLPT'),
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('N3'),
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(60),
  );
  static const VerificationMeta _totalQuestionsMeta = const VerificationMeta(
    'totalQuestions',
  );
  @override
  late final GeneratedColumn<int> totalQuestions = GeneratedColumn<int>(
    'total_questions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(40),
  );
  static const VerificationMeta _passingScoreMeta = const VerificationMeta(
    'passingScore',
  );
  @override
  late final GeneratedColumn<int> passingScore = GeneratedColumn<int>(
    'passing_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(60),
  );
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('file-text'),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isPublishedMeta = const VerificationMeta(
    'isPublished',
  );
  @override
  late final GeneratedColumn<bool> isPublished = GeneratedColumn<bool>(
    'is_published',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_published" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isDownloadedMeta = const VerificationMeta(
    'isDownloaded',
  );
  @override
  late final GeneratedColumn<bool> isDownloaded = GeneratedColumn<bool>(
    'is_downloaded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_downloaded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    id,
    title,
    description,
    category,
    level,
    durationMinutes,
    totalQuestions,
    passingScore,
    iconName,
    version,
    isPublished,
    isDownloaded,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exam_papers';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExamPaper> instance, {
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
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    }
    if (data.containsKey('total_questions')) {
      context.handle(
        _totalQuestionsMeta,
        totalQuestions.isAcceptableOrUnknown(
          data['total_questions']!,
          _totalQuestionsMeta,
        ),
      );
    }
    if (data.containsKey('passing_score')) {
      context.handle(
        _passingScoreMeta,
        passingScore.isAcceptableOrUnknown(
          data['passing_score']!,
          _passingScoreMeta,
        ),
      );
    }
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('is_published')) {
      context.handle(
        _isPublishedMeta,
        isPublished.isAcceptableOrUnknown(
          data['is_published']!,
          _isPublishedMeta,
        ),
      );
    }
    if (data.containsKey('is_downloaded')) {
      context.handle(
        _isDownloadedMeta,
        isDownloaded.isAcceptableOrUnknown(
          data['is_downloaded']!,
          _isDownloadedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExamPaper map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExamPaper(
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
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      )!,
      totalQuestions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_questions'],
      )!,
      passingScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}passing_score'],
      )!,
      iconName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      isPublished: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_published'],
      )!,
      isDownloaded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_downloaded'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ExamPapersTable createAlias(String alias) {
    return $ExamPapersTable(attachedDatabase, alias);
  }
}

class ExamPaper extends DataClass implements Insertable<ExamPaper> {
  final String id;
  final String title;
  final String description;
  final String category;
  final String level;
  final int durationMinutes;
  final int totalQuestions;
  final int passingScore;
  final String iconName;
  final int version;
  final bool isPublished;
  final bool isDownloaded;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ExamPaper({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.level,
    required this.durationMinutes,
    required this.totalQuestions,
    required this.passingScore,
    required this.iconName,
    required this.version,
    required this.isPublished,
    required this.isDownloaded,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['category'] = Variable<String>(category);
    map['level'] = Variable<String>(level);
    map['duration_minutes'] = Variable<int>(durationMinutes);
    map['total_questions'] = Variable<int>(totalQuestions);
    map['passing_score'] = Variable<int>(passingScore);
    map['icon_name'] = Variable<String>(iconName);
    map['version'] = Variable<int>(version);
    map['is_published'] = Variable<bool>(isPublished);
    map['is_downloaded'] = Variable<bool>(isDownloaded);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ExamPapersCompanion toCompanion(bool nullToAbsent) {
    return ExamPapersCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      category: Value(category),
      level: Value(level),
      durationMinutes: Value(durationMinutes),
      totalQuestions: Value(totalQuestions),
      passingScore: Value(passingScore),
      iconName: Value(iconName),
      version: Value(version),
      isPublished: Value(isPublished),
      isDownloaded: Value(isDownloaded),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ExamPaper.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExamPaper(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      category: serializer.fromJson<String>(json['category']),
      level: serializer.fromJson<String>(json['level']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      totalQuestions: serializer.fromJson<int>(json['totalQuestions']),
      passingScore: serializer.fromJson<int>(json['passingScore']),
      iconName: serializer.fromJson<String>(json['iconName']),
      version: serializer.fromJson<int>(json['version']),
      isPublished: serializer.fromJson<bool>(json['isPublished']),
      isDownloaded: serializer.fromJson<bool>(json['isDownloaded']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'category': serializer.toJson<String>(category),
      'level': serializer.toJson<String>(level),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'totalQuestions': serializer.toJson<int>(totalQuestions),
      'passingScore': serializer.toJson<int>(passingScore),
      'iconName': serializer.toJson<String>(iconName),
      'version': serializer.toJson<int>(version),
      'isPublished': serializer.toJson<bool>(isPublished),
      'isDownloaded': serializer.toJson<bool>(isDownloaded),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ExamPaper copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? level,
    int? durationMinutes,
    int? totalQuestions,
    int? passingScore,
    String? iconName,
    int? version,
    bool? isPublished,
    bool? isDownloaded,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ExamPaper(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    category: category ?? this.category,
    level: level ?? this.level,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    totalQuestions: totalQuestions ?? this.totalQuestions,
    passingScore: passingScore ?? this.passingScore,
    iconName: iconName ?? this.iconName,
    version: version ?? this.version,
    isPublished: isPublished ?? this.isPublished,
    isDownloaded: isDownloaded ?? this.isDownloaded,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ExamPaper copyWithCompanion(ExamPapersCompanion data) {
    return ExamPaper(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      category: data.category.present ? data.category.value : this.category,
      level: data.level.present ? data.level.value : this.level,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      totalQuestions: data.totalQuestions.present
          ? data.totalQuestions.value
          : this.totalQuestions,
      passingScore: data.passingScore.present
          ? data.passingScore.value
          : this.passingScore,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      version: data.version.present ? data.version.value : this.version,
      isPublished: data.isPublished.present
          ? data.isPublished.value
          : this.isPublished,
      isDownloaded: data.isDownloaded.present
          ? data.isDownloaded.value
          : this.isDownloaded,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExamPaper(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('level: $level, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('passingScore: $passingScore, ')
          ..write('iconName: $iconName, ')
          ..write('version: $version, ')
          ..write('isPublished: $isPublished, ')
          ..write('isDownloaded: $isDownloaded, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    category,
    level,
    durationMinutes,
    totalQuestions,
    passingScore,
    iconName,
    version,
    isPublished,
    isDownloaded,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExamPaper &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.category == this.category &&
          other.level == this.level &&
          other.durationMinutes == this.durationMinutes &&
          other.totalQuestions == this.totalQuestions &&
          other.passingScore == this.passingScore &&
          other.iconName == this.iconName &&
          other.version == this.version &&
          other.isPublished == this.isPublished &&
          other.isDownloaded == this.isDownloaded &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ExamPapersCompanion extends UpdateCompanion<ExamPaper> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<String> category;
  final Value<String> level;
  final Value<int> durationMinutes;
  final Value<int> totalQuestions;
  final Value<int> passingScore;
  final Value<String> iconName;
  final Value<int> version;
  final Value<bool> isPublished;
  final Value<bool> isDownloaded;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ExamPapersCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.level = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.totalQuestions = const Value.absent(),
    this.passingScore = const Value.absent(),
    this.iconName = const Value.absent(),
    this.version = const Value.absent(),
    this.isPublished = const Value.absent(),
    this.isDownloaded = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExamPapersCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.level = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.totalQuestions = const Value.absent(),
    this.passingScore = const Value.absent(),
    this.iconName = const Value.absent(),
    this.version = const Value.absent(),
    this.isPublished = const Value.absent(),
    this.isDownloaded = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title);
  static Insertable<ExamPaper> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? category,
    Expression<String>? level,
    Expression<int>? durationMinutes,
    Expression<int>? totalQuestions,
    Expression<int>? passingScore,
    Expression<String>? iconName,
    Expression<int>? version,
    Expression<bool>? isPublished,
    Expression<bool>? isDownloaded,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (level != null) 'level': level,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (totalQuestions != null) 'total_questions': totalQuestions,
      if (passingScore != null) 'passing_score': passingScore,
      if (iconName != null) 'icon_name': iconName,
      if (version != null) 'version': version,
      if (isPublished != null) 'is_published': isPublished,
      if (isDownloaded != null) 'is_downloaded': isDownloaded,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExamPapersCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? description,
    Value<String>? category,
    Value<String>? level,
    Value<int>? durationMinutes,
    Value<int>? totalQuestions,
    Value<int>? passingScore,
    Value<String>? iconName,
    Value<int>? version,
    Value<bool>? isPublished,
    Value<bool>? isDownloaded,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ExamPapersCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      level: level ?? this.level,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      passingScore: passingScore ?? this.passingScore,
      iconName: iconName ?? this.iconName,
      version: version ?? this.version,
      isPublished: isPublished ?? this.isPublished,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (totalQuestions.present) {
      map['total_questions'] = Variable<int>(totalQuestions.value);
    }
    if (passingScore.present) {
      map['passing_score'] = Variable<int>(passingScore.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isPublished.present) {
      map['is_published'] = Variable<bool>(isPublished.value);
    }
    if (isDownloaded.present) {
      map['is_downloaded'] = Variable<bool>(isDownloaded.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('ExamPapersCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('level: $level, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('passingScore: $passingScore, ')
          ..write('iconName: $iconName, ')
          ..write('version: $version, ')
          ..write('isPublished: $isPublished, ')
          ..write('isDownloaded: $isDownloaded, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExamSectionsTable extends ExamSections
    with TableInfo<$ExamSectionsTable, ExamSection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExamSectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _examIdMeta = const VerificationMeta('examId');
  @override
  late final GeneratedColumn<String> examId = GeneratedColumn<String>(
    'exam_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exam_papers (id) ON DELETE CASCADE',
    ),
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
  static const VerificationMeta _sectionTypeMeta = const VerificationMeta(
    'sectionType',
  );
  @override
  late final GeneratedColumn<String> sectionType = GeneratedColumn<String>(
    'section_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('general'),
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _instructionMeta = const VerificationMeta(
    'instruction',
  );
  @override
  late final GeneratedColumn<String> instruction = GeneratedColumn<String>(
    'instruction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    examId,
    title,
    sectionType,
    orderIndex,
    instruction,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exam_sections';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExamSection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('exam_id')) {
      context.handle(
        _examIdMeta,
        examId.isAcceptableOrUnknown(data['exam_id']!, _examIdMeta),
      );
    } else if (isInserting) {
      context.missing(_examIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('section_type')) {
      context.handle(
        _sectionTypeMeta,
        sectionType.isAcceptableOrUnknown(
          data['section_type']!,
          _sectionTypeMeta,
        ),
      );
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    }
    if (data.containsKey('instruction')) {
      context.handle(
        _instructionMeta,
        instruction.isAcceptableOrUnknown(
          data['instruction']!,
          _instructionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExamSection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExamSection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      examId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exam_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      sectionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section_type'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      instruction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instruction'],
      )!,
    );
  }

  @override
  $ExamSectionsTable createAlias(String alias) {
    return $ExamSectionsTable(attachedDatabase, alias);
  }
}

class ExamSection extends DataClass implements Insertable<ExamSection> {
  final String id;
  final String examId;
  final String title;
  final String sectionType;
  final int orderIndex;
  final String instruction;
  const ExamSection({
    required this.id,
    required this.examId,
    required this.title,
    required this.sectionType,
    required this.orderIndex,
    required this.instruction,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['exam_id'] = Variable<String>(examId);
    map['title'] = Variable<String>(title);
    map['section_type'] = Variable<String>(sectionType);
    map['order_index'] = Variable<int>(orderIndex);
    map['instruction'] = Variable<String>(instruction);
    return map;
  }

  ExamSectionsCompanion toCompanion(bool nullToAbsent) {
    return ExamSectionsCompanion(
      id: Value(id),
      examId: Value(examId),
      title: Value(title),
      sectionType: Value(sectionType),
      orderIndex: Value(orderIndex),
      instruction: Value(instruction),
    );
  }

  factory ExamSection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExamSection(
      id: serializer.fromJson<String>(json['id']),
      examId: serializer.fromJson<String>(json['examId']),
      title: serializer.fromJson<String>(json['title']),
      sectionType: serializer.fromJson<String>(json['sectionType']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      instruction: serializer.fromJson<String>(json['instruction']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'examId': serializer.toJson<String>(examId),
      'title': serializer.toJson<String>(title),
      'sectionType': serializer.toJson<String>(sectionType),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'instruction': serializer.toJson<String>(instruction),
    };
  }

  ExamSection copyWith({
    String? id,
    String? examId,
    String? title,
    String? sectionType,
    int? orderIndex,
    String? instruction,
  }) => ExamSection(
    id: id ?? this.id,
    examId: examId ?? this.examId,
    title: title ?? this.title,
    sectionType: sectionType ?? this.sectionType,
    orderIndex: orderIndex ?? this.orderIndex,
    instruction: instruction ?? this.instruction,
  );
  ExamSection copyWithCompanion(ExamSectionsCompanion data) {
    return ExamSection(
      id: data.id.present ? data.id.value : this.id,
      examId: data.examId.present ? data.examId.value : this.examId,
      title: data.title.present ? data.title.value : this.title,
      sectionType: data.sectionType.present
          ? data.sectionType.value
          : this.sectionType,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      instruction: data.instruction.present
          ? data.instruction.value
          : this.instruction,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExamSection(')
          ..write('id: $id, ')
          ..write('examId: $examId, ')
          ..write('title: $title, ')
          ..write('sectionType: $sectionType, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('instruction: $instruction')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, examId, title, sectionType, orderIndex, instruction);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExamSection &&
          other.id == this.id &&
          other.examId == this.examId &&
          other.title == this.title &&
          other.sectionType == this.sectionType &&
          other.orderIndex == this.orderIndex &&
          other.instruction == this.instruction);
}

class ExamSectionsCompanion extends UpdateCompanion<ExamSection> {
  final Value<String> id;
  final Value<String> examId;
  final Value<String> title;
  final Value<String> sectionType;
  final Value<int> orderIndex;
  final Value<String> instruction;
  final Value<int> rowid;
  const ExamSectionsCompanion({
    this.id = const Value.absent(),
    this.examId = const Value.absent(),
    this.title = const Value.absent(),
    this.sectionType = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.instruction = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExamSectionsCompanion.insert({
    required String id,
    required String examId,
    required String title,
    this.sectionType = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.instruction = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       examId = Value(examId),
       title = Value(title);
  static Insertable<ExamSection> custom({
    Expression<String>? id,
    Expression<String>? examId,
    Expression<String>? title,
    Expression<String>? sectionType,
    Expression<int>? orderIndex,
    Expression<String>? instruction,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (examId != null) 'exam_id': examId,
      if (title != null) 'title': title,
      if (sectionType != null) 'section_type': sectionType,
      if (orderIndex != null) 'order_index': orderIndex,
      if (instruction != null) 'instruction': instruction,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExamSectionsCompanion copyWith({
    Value<String>? id,
    Value<String>? examId,
    Value<String>? title,
    Value<String>? sectionType,
    Value<int>? orderIndex,
    Value<String>? instruction,
    Value<int>? rowid,
  }) {
    return ExamSectionsCompanion(
      id: id ?? this.id,
      examId: examId ?? this.examId,
      title: title ?? this.title,
      sectionType: sectionType ?? this.sectionType,
      orderIndex: orderIndex ?? this.orderIndex,
      instruction: instruction ?? this.instruction,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (examId.present) {
      map['exam_id'] = Variable<String>(examId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (sectionType.present) {
      map['section_type'] = Variable<String>(sectionType.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (instruction.present) {
      map['instruction'] = Variable<String>(instruction.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExamSectionsCompanion(')
          ..write('id: $id, ')
          ..write('examId: $examId, ')
          ..write('title: $title, ')
          ..write('sectionType: $sectionType, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('instruction: $instruction, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExamQuestionsTable extends ExamQuestions
    with TableInfo<$ExamQuestionsTable, ExamQuestion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExamQuestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _examIdMeta = const VerificationMeta('examId');
  @override
  late final GeneratedColumn<String> examId = GeneratedColumn<String>(
    'exam_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exam_papers (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sectionIdMeta = const VerificationMeta(
    'sectionId',
  );
  @override
  late final GeneratedColumn<String> sectionId = GeneratedColumn<String>(
    'section_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exam_sections (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _questionNumberMeta = const VerificationMeta(
    'questionNumber',
  );
  @override
  late final GeneratedColumn<int> questionNumber = GeneratedColumn<int>(
    'question_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _questionTextMeta = const VerificationMeta(
    'questionText',
  );
  @override
  late final GeneratedColumn<String> questionText = GeneratedColumn<String>(
    'question_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contextPassageMeta = const VerificationMeta(
    'contextPassage',
  );
  @override
  late final GeneratedColumn<String> contextPassage = GeneratedColumn<String>(
    'context_passage',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioUrlMeta = const VerificationMeta(
    'audioUrl',
  );
  @override
  late final GeneratedColumn<String> audioUrl = GeneratedColumn<String>(
    'audio_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _optionsJsonMeta = const VerificationMeta(
    'optionsJson',
  );
  @override
  late final GeneratedColumn<String> optionsJson = GeneratedColumn<String>(
    'options_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _correctAnswerMeta = const VerificationMeta(
    'correctAnswer',
  );
  @override
  late final GeneratedColumn<String> correctAnswer = GeneratedColumn<String>(
    'correct_answer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _explanationMeta = const VerificationMeta(
    'explanation',
  );
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
    'explanation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _pointsMeta = const VerificationMeta('points');
  @override
  late final GeneratedColumn<int> points = GeneratedColumn<int>(
    'points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    examId,
    sectionId,
    questionNumber,
    questionText,
    contextPassage,
    audioUrl,
    optionsJson,
    correctAnswer,
    explanation,
    points,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exam_questions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExamQuestion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('exam_id')) {
      context.handle(
        _examIdMeta,
        examId.isAcceptableOrUnknown(data['exam_id']!, _examIdMeta),
      );
    } else if (isInserting) {
      context.missing(_examIdMeta);
    }
    if (data.containsKey('section_id')) {
      context.handle(
        _sectionIdMeta,
        sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectionIdMeta);
    }
    if (data.containsKey('question_number')) {
      context.handle(
        _questionNumberMeta,
        questionNumber.isAcceptableOrUnknown(
          data['question_number']!,
          _questionNumberMeta,
        ),
      );
    }
    if (data.containsKey('question_text')) {
      context.handle(
        _questionTextMeta,
        questionText.isAcceptableOrUnknown(
          data['question_text']!,
          _questionTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questionTextMeta);
    }
    if (data.containsKey('context_passage')) {
      context.handle(
        _contextPassageMeta,
        contextPassage.isAcceptableOrUnknown(
          data['context_passage']!,
          _contextPassageMeta,
        ),
      );
    }
    if (data.containsKey('audio_url')) {
      context.handle(
        _audioUrlMeta,
        audioUrl.isAcceptableOrUnknown(data['audio_url']!, _audioUrlMeta),
      );
    }
    if (data.containsKey('options_json')) {
      context.handle(
        _optionsJsonMeta,
        optionsJson.isAcceptableOrUnknown(
          data['options_json']!,
          _optionsJsonMeta,
        ),
      );
    }
    if (data.containsKey('correct_answer')) {
      context.handle(
        _correctAnswerMeta,
        correctAnswer.isAcceptableOrUnknown(
          data['correct_answer']!,
          _correctAnswerMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_correctAnswerMeta);
    }
    if (data.containsKey('explanation')) {
      context.handle(
        _explanationMeta,
        explanation.isAcceptableOrUnknown(
          data['explanation']!,
          _explanationMeta,
        ),
      );
    }
    if (data.containsKey('points')) {
      context.handle(
        _pointsMeta,
        points.isAcceptableOrUnknown(data['points']!, _pointsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExamQuestion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExamQuestion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      examId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exam_id'],
      )!,
      sectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section_id'],
      )!,
      questionNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}question_number'],
      )!,
      questionText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_text'],
      )!,
      contextPassage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_passage'],
      ),
      audioUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_url'],
      ),
      optionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}options_json'],
      )!,
      correctAnswer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}correct_answer'],
      )!,
      explanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation'],
      )!,
      points: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}points'],
      )!,
    );
  }

  @override
  $ExamQuestionsTable createAlias(String alias) {
    return $ExamQuestionsTable(attachedDatabase, alias);
  }
}

class ExamQuestion extends DataClass implements Insertable<ExamQuestion> {
  final String id;
  final String examId;
  final String sectionId;
  final int questionNumber;
  final String questionText;
  final String? contextPassage;
  final String? audioUrl;
  final String optionsJson;
  final String correctAnswer;
  final String explanation;
  final int points;
  const ExamQuestion({
    required this.id,
    required this.examId,
    required this.sectionId,
    required this.questionNumber,
    required this.questionText,
    this.contextPassage,
    this.audioUrl,
    required this.optionsJson,
    required this.correctAnswer,
    required this.explanation,
    required this.points,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['exam_id'] = Variable<String>(examId);
    map['section_id'] = Variable<String>(sectionId);
    map['question_number'] = Variable<int>(questionNumber);
    map['question_text'] = Variable<String>(questionText);
    if (!nullToAbsent || contextPassage != null) {
      map['context_passage'] = Variable<String>(contextPassage);
    }
    if (!nullToAbsent || audioUrl != null) {
      map['audio_url'] = Variable<String>(audioUrl);
    }
    map['options_json'] = Variable<String>(optionsJson);
    map['correct_answer'] = Variable<String>(correctAnswer);
    map['explanation'] = Variable<String>(explanation);
    map['points'] = Variable<int>(points);
    return map;
  }

  ExamQuestionsCompanion toCompanion(bool nullToAbsent) {
    return ExamQuestionsCompanion(
      id: Value(id),
      examId: Value(examId),
      sectionId: Value(sectionId),
      questionNumber: Value(questionNumber),
      questionText: Value(questionText),
      contextPassage: contextPassage == null && nullToAbsent
          ? const Value.absent()
          : Value(contextPassage),
      audioUrl: audioUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(audioUrl),
      optionsJson: Value(optionsJson),
      correctAnswer: Value(correctAnswer),
      explanation: Value(explanation),
      points: Value(points),
    );
  }

  factory ExamQuestion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExamQuestion(
      id: serializer.fromJson<String>(json['id']),
      examId: serializer.fromJson<String>(json['examId']),
      sectionId: serializer.fromJson<String>(json['sectionId']),
      questionNumber: serializer.fromJson<int>(json['questionNumber']),
      questionText: serializer.fromJson<String>(json['questionText']),
      contextPassage: serializer.fromJson<String?>(json['contextPassage']),
      audioUrl: serializer.fromJson<String?>(json['audioUrl']),
      optionsJson: serializer.fromJson<String>(json['optionsJson']),
      correctAnswer: serializer.fromJson<String>(json['correctAnswer']),
      explanation: serializer.fromJson<String>(json['explanation']),
      points: serializer.fromJson<int>(json['points']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'examId': serializer.toJson<String>(examId),
      'sectionId': serializer.toJson<String>(sectionId),
      'questionNumber': serializer.toJson<int>(questionNumber),
      'questionText': serializer.toJson<String>(questionText),
      'contextPassage': serializer.toJson<String?>(contextPassage),
      'audioUrl': serializer.toJson<String?>(audioUrl),
      'optionsJson': serializer.toJson<String>(optionsJson),
      'correctAnswer': serializer.toJson<String>(correctAnswer),
      'explanation': serializer.toJson<String>(explanation),
      'points': serializer.toJson<int>(points),
    };
  }

  ExamQuestion copyWith({
    String? id,
    String? examId,
    String? sectionId,
    int? questionNumber,
    String? questionText,
    Value<String?> contextPassage = const Value.absent(),
    Value<String?> audioUrl = const Value.absent(),
    String? optionsJson,
    String? correctAnswer,
    String? explanation,
    int? points,
  }) => ExamQuestion(
    id: id ?? this.id,
    examId: examId ?? this.examId,
    sectionId: sectionId ?? this.sectionId,
    questionNumber: questionNumber ?? this.questionNumber,
    questionText: questionText ?? this.questionText,
    contextPassage: contextPassage.present
        ? contextPassage.value
        : this.contextPassage,
    audioUrl: audioUrl.present ? audioUrl.value : this.audioUrl,
    optionsJson: optionsJson ?? this.optionsJson,
    correctAnswer: correctAnswer ?? this.correctAnswer,
    explanation: explanation ?? this.explanation,
    points: points ?? this.points,
  );
  ExamQuestion copyWithCompanion(ExamQuestionsCompanion data) {
    return ExamQuestion(
      id: data.id.present ? data.id.value : this.id,
      examId: data.examId.present ? data.examId.value : this.examId,
      sectionId: data.sectionId.present ? data.sectionId.value : this.sectionId,
      questionNumber: data.questionNumber.present
          ? data.questionNumber.value
          : this.questionNumber,
      questionText: data.questionText.present
          ? data.questionText.value
          : this.questionText,
      contextPassage: data.contextPassage.present
          ? data.contextPassage.value
          : this.contextPassage,
      audioUrl: data.audioUrl.present ? data.audioUrl.value : this.audioUrl,
      optionsJson: data.optionsJson.present
          ? data.optionsJson.value
          : this.optionsJson,
      correctAnswer: data.correctAnswer.present
          ? data.correctAnswer.value
          : this.correctAnswer,
      explanation: data.explanation.present
          ? data.explanation.value
          : this.explanation,
      points: data.points.present ? data.points.value : this.points,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExamQuestion(')
          ..write('id: $id, ')
          ..write('examId: $examId, ')
          ..write('sectionId: $sectionId, ')
          ..write('questionNumber: $questionNumber, ')
          ..write('questionText: $questionText, ')
          ..write('contextPassage: $contextPassage, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('correctAnswer: $correctAnswer, ')
          ..write('explanation: $explanation, ')
          ..write('points: $points')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    examId,
    sectionId,
    questionNumber,
    questionText,
    contextPassage,
    audioUrl,
    optionsJson,
    correctAnswer,
    explanation,
    points,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExamQuestion &&
          other.id == this.id &&
          other.examId == this.examId &&
          other.sectionId == this.sectionId &&
          other.questionNumber == this.questionNumber &&
          other.questionText == this.questionText &&
          other.contextPassage == this.contextPassage &&
          other.audioUrl == this.audioUrl &&
          other.optionsJson == this.optionsJson &&
          other.correctAnswer == this.correctAnswer &&
          other.explanation == this.explanation &&
          other.points == this.points);
}

class ExamQuestionsCompanion extends UpdateCompanion<ExamQuestion> {
  final Value<String> id;
  final Value<String> examId;
  final Value<String> sectionId;
  final Value<int> questionNumber;
  final Value<String> questionText;
  final Value<String?> contextPassage;
  final Value<String?> audioUrl;
  final Value<String> optionsJson;
  final Value<String> correctAnswer;
  final Value<String> explanation;
  final Value<int> points;
  final Value<int> rowid;
  const ExamQuestionsCompanion({
    this.id = const Value.absent(),
    this.examId = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.questionNumber = const Value.absent(),
    this.questionText = const Value.absent(),
    this.contextPassage = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.optionsJson = const Value.absent(),
    this.correctAnswer = const Value.absent(),
    this.explanation = const Value.absent(),
    this.points = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExamQuestionsCompanion.insert({
    required String id,
    required String examId,
    required String sectionId,
    this.questionNumber = const Value.absent(),
    required String questionText,
    this.contextPassage = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.optionsJson = const Value.absent(),
    required String correctAnswer,
    this.explanation = const Value.absent(),
    this.points = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       examId = Value(examId),
       sectionId = Value(sectionId),
       questionText = Value(questionText),
       correctAnswer = Value(correctAnswer);
  static Insertable<ExamQuestion> custom({
    Expression<String>? id,
    Expression<String>? examId,
    Expression<String>? sectionId,
    Expression<int>? questionNumber,
    Expression<String>? questionText,
    Expression<String>? contextPassage,
    Expression<String>? audioUrl,
    Expression<String>? optionsJson,
    Expression<String>? correctAnswer,
    Expression<String>? explanation,
    Expression<int>? points,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (examId != null) 'exam_id': examId,
      if (sectionId != null) 'section_id': sectionId,
      if (questionNumber != null) 'question_number': questionNumber,
      if (questionText != null) 'question_text': questionText,
      if (contextPassage != null) 'context_passage': contextPassage,
      if (audioUrl != null) 'audio_url': audioUrl,
      if (optionsJson != null) 'options_json': optionsJson,
      if (correctAnswer != null) 'correct_answer': correctAnswer,
      if (explanation != null) 'explanation': explanation,
      if (points != null) 'points': points,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExamQuestionsCompanion copyWith({
    Value<String>? id,
    Value<String>? examId,
    Value<String>? sectionId,
    Value<int>? questionNumber,
    Value<String>? questionText,
    Value<String?>? contextPassage,
    Value<String?>? audioUrl,
    Value<String>? optionsJson,
    Value<String>? correctAnswer,
    Value<String>? explanation,
    Value<int>? points,
    Value<int>? rowid,
  }) {
    return ExamQuestionsCompanion(
      id: id ?? this.id,
      examId: examId ?? this.examId,
      sectionId: sectionId ?? this.sectionId,
      questionNumber: questionNumber ?? this.questionNumber,
      questionText: questionText ?? this.questionText,
      contextPassage: contextPassage ?? this.contextPassage,
      audioUrl: audioUrl ?? this.audioUrl,
      optionsJson: optionsJson ?? this.optionsJson,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      points: points ?? this.points,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (examId.present) {
      map['exam_id'] = Variable<String>(examId.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<String>(sectionId.value);
    }
    if (questionNumber.present) {
      map['question_number'] = Variable<int>(questionNumber.value);
    }
    if (questionText.present) {
      map['question_text'] = Variable<String>(questionText.value);
    }
    if (contextPassage.present) {
      map['context_passage'] = Variable<String>(contextPassage.value);
    }
    if (audioUrl.present) {
      map['audio_url'] = Variable<String>(audioUrl.value);
    }
    if (optionsJson.present) {
      map['options_json'] = Variable<String>(optionsJson.value);
    }
    if (correctAnswer.present) {
      map['correct_answer'] = Variable<String>(correctAnswer.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (points.present) {
      map['points'] = Variable<int>(points.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExamQuestionsCompanion(')
          ..write('id: $id, ')
          ..write('examId: $examId, ')
          ..write('sectionId: $sectionId, ')
          ..write('questionNumber: $questionNumber, ')
          ..write('questionText: $questionText, ')
          ..write('contextPassage: $contextPassage, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('correctAnswer: $correctAnswer, ')
          ..write('explanation: $explanation, ')
          ..write('points: $points, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExamSubmissionsTable extends ExamSubmissions
    with TableInfo<$ExamSubmissionsTable, ExamSubmission> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExamSubmissionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _examIdMeta = const VerificationMeta('examId');
  @override
  late final GeneratedColumn<String> examId = GeneratedColumn<String>(
    'exam_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exam_papers (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalCorrectMeta = const VerificationMeta(
    'totalCorrect',
  );
  @override
  late final GeneratedColumn<int> totalCorrect = GeneratedColumn<int>(
    'total_correct',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalQuestionsMeta = const VerificationMeta(
    'totalQuestions',
  );
  @override
  late final GeneratedColumn<int> totalQuestions = GeneratedColumn<int>(
    'total_questions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _answersJsonMeta = const VerificationMeta(
    'answersJson',
  );
  @override
  late final GeneratedColumn<String> answersJson = GeneratedColumn<String>(
    'answers_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _submittedAtMeta = const VerificationMeta(
    'submittedAt',
  );
  @override
  late final GeneratedColumn<DateTime> submittedAt = GeneratedColumn<DateTime>(
    'submitted_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtHlcMeta = const VerificationMeta(
    'updatedAtHlc',
  );
  @override
  late final GeneratedColumn<String> updatedAtHlc = GeneratedColumn<String>(
    'updated_at_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    examId,
    score,
    totalCorrect,
    totalQuestions,
    durationSeconds,
    answersJson,
    submittedAt,
    updatedAtHlc,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exam_submissions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExamSubmission> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('exam_id')) {
      context.handle(
        _examIdMeta,
        examId.isAcceptableOrUnknown(data['exam_id']!, _examIdMeta),
      );
    } else if (isInserting) {
      context.missing(_examIdMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    }
    if (data.containsKey('total_correct')) {
      context.handle(
        _totalCorrectMeta,
        totalCorrect.isAcceptableOrUnknown(
          data['total_correct']!,
          _totalCorrectMeta,
        ),
      );
    }
    if (data.containsKey('total_questions')) {
      context.handle(
        _totalQuestionsMeta,
        totalQuestions.isAcceptableOrUnknown(
          data['total_questions']!,
          _totalQuestionsMeta,
        ),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('answers_json')) {
      context.handle(
        _answersJsonMeta,
        answersJson.isAcceptableOrUnknown(
          data['answers_json']!,
          _answersJsonMeta,
        ),
      );
    }
    if (data.containsKey('submitted_at')) {
      context.handle(
        _submittedAtMeta,
        submittedAt.isAcceptableOrUnknown(
          data['submitted_at']!,
          _submittedAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at_hlc')) {
      context.handle(
        _updatedAtHlcMeta,
        updatedAtHlc.isAcceptableOrUnknown(
          data['updated_at_hlc']!,
          _updatedAtHlcMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExamSubmission map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExamSubmission(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      examId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exam_id'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      totalCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_correct'],
      )!,
      totalQuestions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_questions'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      answersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answers_json'],
      )!,
      submittedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}submitted_at'],
      )!,
      updatedAtHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_hlc'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $ExamSubmissionsTable createAlias(String alias) {
    return $ExamSubmissionsTable(attachedDatabase, alias);
  }
}

class ExamSubmission extends DataClass implements Insertable<ExamSubmission> {
  final String id;
  final String examId;
  final int score;
  final int totalCorrect;
  final int totalQuestions;
  final int durationSeconds;
  final String answersJson;
  final DateTime submittedAt;
  final String updatedAtHlc;
  final bool isDeleted;
  const ExamSubmission({
    required this.id,
    required this.examId,
    required this.score,
    required this.totalCorrect,
    required this.totalQuestions,
    required this.durationSeconds,
    required this.answersJson,
    required this.submittedAt,
    required this.updatedAtHlc,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['exam_id'] = Variable<String>(examId);
    map['score'] = Variable<int>(score);
    map['total_correct'] = Variable<int>(totalCorrect);
    map['total_questions'] = Variable<int>(totalQuestions);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['answers_json'] = Variable<String>(answersJson);
    map['submitted_at'] = Variable<DateTime>(submittedAt);
    map['updated_at_hlc'] = Variable<String>(updatedAtHlc);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  ExamSubmissionsCompanion toCompanion(bool nullToAbsent) {
    return ExamSubmissionsCompanion(
      id: Value(id),
      examId: Value(examId),
      score: Value(score),
      totalCorrect: Value(totalCorrect),
      totalQuestions: Value(totalQuestions),
      durationSeconds: Value(durationSeconds),
      answersJson: Value(answersJson),
      submittedAt: Value(submittedAt),
      updatedAtHlc: Value(updatedAtHlc),
      isDeleted: Value(isDeleted),
    );
  }

  factory ExamSubmission.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExamSubmission(
      id: serializer.fromJson<String>(json['id']),
      examId: serializer.fromJson<String>(json['examId']),
      score: serializer.fromJson<int>(json['score']),
      totalCorrect: serializer.fromJson<int>(json['totalCorrect']),
      totalQuestions: serializer.fromJson<int>(json['totalQuestions']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      answersJson: serializer.fromJson<String>(json['answersJson']),
      submittedAt: serializer.fromJson<DateTime>(json['submittedAt']),
      updatedAtHlc: serializer.fromJson<String>(json['updatedAtHlc']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'examId': serializer.toJson<String>(examId),
      'score': serializer.toJson<int>(score),
      'totalCorrect': serializer.toJson<int>(totalCorrect),
      'totalQuestions': serializer.toJson<int>(totalQuestions),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'answersJson': serializer.toJson<String>(answersJson),
      'submittedAt': serializer.toJson<DateTime>(submittedAt),
      'updatedAtHlc': serializer.toJson<String>(updatedAtHlc),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  ExamSubmission copyWith({
    String? id,
    String? examId,
    int? score,
    int? totalCorrect,
    int? totalQuestions,
    int? durationSeconds,
    String? answersJson,
    DateTime? submittedAt,
    String? updatedAtHlc,
    bool? isDeleted,
  }) => ExamSubmission(
    id: id ?? this.id,
    examId: examId ?? this.examId,
    score: score ?? this.score,
    totalCorrect: totalCorrect ?? this.totalCorrect,
    totalQuestions: totalQuestions ?? this.totalQuestions,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    answersJson: answersJson ?? this.answersJson,
    submittedAt: submittedAt ?? this.submittedAt,
    updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  ExamSubmission copyWithCompanion(ExamSubmissionsCompanion data) {
    return ExamSubmission(
      id: data.id.present ? data.id.value : this.id,
      examId: data.examId.present ? data.examId.value : this.examId,
      score: data.score.present ? data.score.value : this.score,
      totalCorrect: data.totalCorrect.present
          ? data.totalCorrect.value
          : this.totalCorrect,
      totalQuestions: data.totalQuestions.present
          ? data.totalQuestions.value
          : this.totalQuestions,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      answersJson: data.answersJson.present
          ? data.answersJson.value
          : this.answersJson,
      submittedAt: data.submittedAt.present
          ? data.submittedAt.value
          : this.submittedAt,
      updatedAtHlc: data.updatedAtHlc.present
          ? data.updatedAtHlc.value
          : this.updatedAtHlc,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExamSubmission(')
          ..write('id: $id, ')
          ..write('examId: $examId, ')
          ..write('score: $score, ')
          ..write('totalCorrect: $totalCorrect, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('answersJson: $answersJson, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    examId,
    score,
    totalCorrect,
    totalQuestions,
    durationSeconds,
    answersJson,
    submittedAt,
    updatedAtHlc,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExamSubmission &&
          other.id == this.id &&
          other.examId == this.examId &&
          other.score == this.score &&
          other.totalCorrect == this.totalCorrect &&
          other.totalQuestions == this.totalQuestions &&
          other.durationSeconds == this.durationSeconds &&
          other.answersJson == this.answersJson &&
          other.submittedAt == this.submittedAt &&
          other.updatedAtHlc == this.updatedAtHlc &&
          other.isDeleted == this.isDeleted);
}

class ExamSubmissionsCompanion extends UpdateCompanion<ExamSubmission> {
  final Value<String> id;
  final Value<String> examId;
  final Value<int> score;
  final Value<int> totalCorrect;
  final Value<int> totalQuestions;
  final Value<int> durationSeconds;
  final Value<String> answersJson;
  final Value<DateTime> submittedAt;
  final Value<String> updatedAtHlc;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const ExamSubmissionsCompanion({
    this.id = const Value.absent(),
    this.examId = const Value.absent(),
    this.score = const Value.absent(),
    this.totalCorrect = const Value.absent(),
    this.totalQuestions = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.answersJson = const Value.absent(),
    this.submittedAt = const Value.absent(),
    this.updatedAtHlc = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExamSubmissionsCompanion.insert({
    required String id,
    required String examId,
    this.score = const Value.absent(),
    this.totalCorrect = const Value.absent(),
    this.totalQuestions = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.answersJson = const Value.absent(),
    this.submittedAt = const Value.absent(),
    this.updatedAtHlc = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       examId = Value(examId);
  static Insertable<ExamSubmission> custom({
    Expression<String>? id,
    Expression<String>? examId,
    Expression<int>? score,
    Expression<int>? totalCorrect,
    Expression<int>? totalQuestions,
    Expression<int>? durationSeconds,
    Expression<String>? answersJson,
    Expression<DateTime>? submittedAt,
    Expression<String>? updatedAtHlc,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (examId != null) 'exam_id': examId,
      if (score != null) 'score': score,
      if (totalCorrect != null) 'total_correct': totalCorrect,
      if (totalQuestions != null) 'total_questions': totalQuestions,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (answersJson != null) 'answers_json': answersJson,
      if (submittedAt != null) 'submitted_at': submittedAt,
      if (updatedAtHlc != null) 'updated_at_hlc': updatedAtHlc,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExamSubmissionsCompanion copyWith({
    Value<String>? id,
    Value<String>? examId,
    Value<int>? score,
    Value<int>? totalCorrect,
    Value<int>? totalQuestions,
    Value<int>? durationSeconds,
    Value<String>? answersJson,
    Value<DateTime>? submittedAt,
    Value<String>? updatedAtHlc,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return ExamSubmissionsCompanion(
      id: id ?? this.id,
      examId: examId ?? this.examId,
      score: score ?? this.score,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      answersJson: answersJson ?? this.answersJson,
      submittedAt: submittedAt ?? this.submittedAt,
      updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (examId.present) {
      map['exam_id'] = Variable<String>(examId.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (totalCorrect.present) {
      map['total_correct'] = Variable<int>(totalCorrect.value);
    }
    if (totalQuestions.present) {
      map['total_questions'] = Variable<int>(totalQuestions.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (answersJson.present) {
      map['answers_json'] = Variable<String>(answersJson.value);
    }
    if (submittedAt.present) {
      map['submitted_at'] = Variable<DateTime>(submittedAt.value);
    }
    if (updatedAtHlc.present) {
      map['updated_at_hlc'] = Variable<String>(updatedAtHlc.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExamSubmissionsCompanion(')
          ..write('id: $id, ')
          ..write('examId: $examId, ')
          ..write('score: $score, ')
          ..write('totalCorrect: $totalCorrect, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('answersJson: $answersJson, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WrongQuestionNotebookTable extends WrongQuestionNotebook
    with TableInfo<$WrongQuestionNotebookTable, WrongQuestionNotebookData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WrongQuestionNotebookTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _examIdMeta = const VerificationMeta('examId');
  @override
  late final GeneratedColumn<String> examId = GeneratedColumn<String>(
    'exam_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userAnswerMeta = const VerificationMeta(
    'userAnswer',
  );
  @override
  late final GeneratedColumn<String> userAnswer = GeneratedColumn<String>(
    'user_answer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _explanationMeta = const VerificationMeta(
    'explanation',
  );
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
    'explanation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('new'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
  static const VerificationMeta _updatedAtHlcMeta = const VerificationMeta(
    'updatedAtHlc',
  );
  @override
  late final GeneratedColumn<String> updatedAtHlc = GeneratedColumn<String>(
    'updated_at_hlc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    examId,
    questionId,
    userAnswer,
    explanation,
    notes,
    status,
    createdAt,
    updatedAt,
    updatedAtHlc,
    isDeleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wrong_question_notebook';
  @override
  VerificationContext validateIntegrity(
    Insertable<WrongQuestionNotebookData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('exam_id')) {
      context.handle(
        _examIdMeta,
        examId.isAcceptableOrUnknown(data['exam_id']!, _examIdMeta),
      );
    } else if (isInserting) {
      context.missing(_examIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('user_answer')) {
      context.handle(
        _userAnswerMeta,
        userAnswer.isAcceptableOrUnknown(data['user_answer']!, _userAnswerMeta),
      );
    } else if (isInserting) {
      context.missing(_userAnswerMeta);
    }
    if (data.containsKey('explanation')) {
      context.handle(
        _explanationMeta,
        explanation.isAcceptableOrUnknown(
          data['explanation']!,
          _explanationMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('updated_at_hlc')) {
      context.handle(
        _updatedAtHlcMeta,
        updatedAtHlc.isAcceptableOrUnknown(
          data['updated_at_hlc']!,
          _updatedAtHlcMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WrongQuestionNotebookData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WrongQuestionNotebookData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      examId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exam_id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      userAnswer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_answer'],
      )!,
      explanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      updatedAtHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at_hlc'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
    );
  }

  @override
  $WrongQuestionNotebookTable createAlias(String alias) {
    return $WrongQuestionNotebookTable(attachedDatabase, alias);
  }
}

class WrongQuestionNotebookData extends DataClass
    implements Insertable<WrongQuestionNotebookData> {
  final String id;
  final String examId;
  final String questionId;
  final String userAnswer;
  final String explanation;
  final String notes;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String updatedAtHlc;
  final bool isDeleted;
  const WrongQuestionNotebookData({
    required this.id,
    required this.examId,
    required this.questionId,
    required this.userAnswer,
    required this.explanation,
    required this.notes,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.updatedAtHlc,
    required this.isDeleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['exam_id'] = Variable<String>(examId);
    map['question_id'] = Variable<String>(questionId);
    map['user_answer'] = Variable<String>(userAnswer);
    map['explanation'] = Variable<String>(explanation);
    map['notes'] = Variable<String>(notes);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['updated_at_hlc'] = Variable<String>(updatedAtHlc);
    map['is_deleted'] = Variable<bool>(isDeleted);
    return map;
  }

  WrongQuestionNotebookCompanion toCompanion(bool nullToAbsent) {
    return WrongQuestionNotebookCompanion(
      id: Value(id),
      examId: Value(examId),
      questionId: Value(questionId),
      userAnswer: Value(userAnswer),
      explanation: Value(explanation),
      notes: Value(notes),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      updatedAtHlc: Value(updatedAtHlc),
      isDeleted: Value(isDeleted),
    );
  }

  factory WrongQuestionNotebookData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WrongQuestionNotebookData(
      id: serializer.fromJson<String>(json['id']),
      examId: serializer.fromJson<String>(json['examId']),
      questionId: serializer.fromJson<String>(json['questionId']),
      userAnswer: serializer.fromJson<String>(json['userAnswer']),
      explanation: serializer.fromJson<String>(json['explanation']),
      notes: serializer.fromJson<String>(json['notes']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      updatedAtHlc: serializer.fromJson<String>(json['updatedAtHlc']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'examId': serializer.toJson<String>(examId),
      'questionId': serializer.toJson<String>(questionId),
      'userAnswer': serializer.toJson<String>(userAnswer),
      'explanation': serializer.toJson<String>(explanation),
      'notes': serializer.toJson<String>(notes),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'updatedAtHlc': serializer.toJson<String>(updatedAtHlc),
      'isDeleted': serializer.toJson<bool>(isDeleted),
    };
  }

  WrongQuestionNotebookData copyWith({
    String? id,
    String? examId,
    String? questionId,
    String? userAnswer,
    String? explanation,
    String? notes,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? updatedAtHlc,
    bool? isDeleted,
  }) => WrongQuestionNotebookData(
    id: id ?? this.id,
    examId: examId ?? this.examId,
    questionId: questionId ?? this.questionId,
    userAnswer: userAnswer ?? this.userAnswer,
    explanation: explanation ?? this.explanation,
    notes: notes ?? this.notes,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
    isDeleted: isDeleted ?? this.isDeleted,
  );
  WrongQuestionNotebookData copyWithCompanion(
    WrongQuestionNotebookCompanion data,
  ) {
    return WrongQuestionNotebookData(
      id: data.id.present ? data.id.value : this.id,
      examId: data.examId.present ? data.examId.value : this.examId,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      userAnswer: data.userAnswer.present
          ? data.userAnswer.value
          : this.userAnswer,
      explanation: data.explanation.present
          ? data.explanation.value
          : this.explanation,
      notes: data.notes.present ? data.notes.value : this.notes,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedAtHlc: data.updatedAtHlc.present
          ? data.updatedAtHlc.value
          : this.updatedAtHlc,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WrongQuestionNotebookData(')
          ..write('id: $id, ')
          ..write('examId: $examId, ')
          ..write('questionId: $questionId, ')
          ..write('userAnswer: $userAnswer, ')
          ..write('explanation: $explanation, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('isDeleted: $isDeleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    examId,
    questionId,
    userAnswer,
    explanation,
    notes,
    status,
    createdAt,
    updatedAt,
    updatedAtHlc,
    isDeleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WrongQuestionNotebookData &&
          other.id == this.id &&
          other.examId == this.examId &&
          other.questionId == this.questionId &&
          other.userAnswer == this.userAnswer &&
          other.explanation == this.explanation &&
          other.notes == this.notes &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.updatedAtHlc == this.updatedAtHlc &&
          other.isDeleted == this.isDeleted);
}

class WrongQuestionNotebookCompanion
    extends UpdateCompanion<WrongQuestionNotebookData> {
  final Value<String> id;
  final Value<String> examId;
  final Value<String> questionId;
  final Value<String> userAnswer;
  final Value<String> explanation;
  final Value<String> notes;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> updatedAtHlc;
  final Value<bool> isDeleted;
  final Value<int> rowid;
  const WrongQuestionNotebookCompanion({
    this.id = const Value.absent(),
    this.examId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.userAnswer = const Value.absent(),
    this.explanation = const Value.absent(),
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedAtHlc = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WrongQuestionNotebookCompanion.insert({
    required String id,
    required String examId,
    required String questionId,
    required String userAnswer,
    this.explanation = const Value.absent(),
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedAtHlc = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       examId = Value(examId),
       questionId = Value(questionId),
       userAnswer = Value(userAnswer);
  static Insertable<WrongQuestionNotebookData> custom({
    Expression<String>? id,
    Expression<String>? examId,
    Expression<String>? questionId,
    Expression<String>? userAnswer,
    Expression<String>? explanation,
    Expression<String>? notes,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? updatedAtHlc,
    Expression<bool>? isDeleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (examId != null) 'exam_id': examId,
      if (questionId != null) 'question_id': questionId,
      if (userAnswer != null) 'user_answer': userAnswer,
      if (explanation != null) 'explanation': explanation,
      if (notes != null) 'notes': notes,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedAtHlc != null) 'updated_at_hlc': updatedAtHlc,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WrongQuestionNotebookCompanion copyWith({
    Value<String>? id,
    Value<String>? examId,
    Value<String>? questionId,
    Value<String>? userAnswer,
    Value<String>? explanation,
    Value<String>? notes,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? updatedAtHlc,
    Value<bool>? isDeleted,
    Value<int>? rowid,
  }) {
    return WrongQuestionNotebookCompanion(
      id: id ?? this.id,
      examId: examId ?? this.examId,
      questionId: questionId ?? this.questionId,
      userAnswer: userAnswer ?? this.userAnswer,
      explanation: explanation ?? this.explanation,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
      isDeleted: isDeleted ?? this.isDeleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (examId.present) {
      map['exam_id'] = Variable<String>(examId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (userAnswer.present) {
      map['user_answer'] = Variable<String>(userAnswer.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (updatedAtHlc.present) {
      map['updated_at_hlc'] = Variable<String>(updatedAtHlc.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WrongQuestionNotebookCompanion(')
          ..write('id: $id, ')
          ..write('examId: $examId, ')
          ..write('questionId: $questionId, ')
          ..write('userAnswer: $userAnswer, ')
          ..write('explanation: $explanation, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedAtHlc: $updatedAtHlc, ')
          ..write('isDeleted: $isDeleted, ')
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
  late final $SyncOutboxTable syncOutbox = $SyncOutboxTable(this);
  late final $SyncCursorsTable syncCursors = $SyncCursorsTable(this);
  late final $ExamPapersTable examPapers = $ExamPapersTable(this);
  late final $ExamSectionsTable examSections = $ExamSectionsTable(this);
  late final $ExamQuestionsTable examQuestions = $ExamQuestionsTable(this);
  late final $ExamSubmissionsTable examSubmissions = $ExamSubmissionsTable(
    this,
  );
  late final $WrongQuestionNotebookTable wrongQuestionNotebook =
      $WrongQuestionNotebookTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    decks,
    cards,
    reviewLogs,
    grammarProgressEntries,
    syncOutbox,
    syncCursors,
    examPapers,
    examSections,
    examQuestions,
    examSubmissions,
    wrongQuestionNotebook,
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
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exam_papers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('exam_sections', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exam_papers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('exam_questions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exam_sections',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('exam_questions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exam_papers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('exam_submissions', kind: UpdateKind.delete)],
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
  Value<String> updatedAtHlc,
  Value<bool> isDeleted,
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
  Value<String> updatedAtHlc,
  Value<bool> isDeleted,
  Value<int> rowid,
});

final class $$DecksTableReferences
    extends BaseReferences<_$AppDatabase, $DecksTable, Deck> {
  $$DecksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CardsTable, List<Card>> _cardsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
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

  ColumnFilters<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
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
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableFilterComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
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

  ColumnOrderings<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
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

  GeneratedColumn<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  Expression<T> cardsRefs<T extends Object>(
    Expression<T> Function($$CardsTableAnnotationComposer a) f,
  ) {
    final $$CardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableAnnotationComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DecksTableTableManager
    extends
        RootTableManager<
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
          PrefetchHooks Function({bool cardsRefs})
        > {
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
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> dueCount = const Value.absent(),
                Value<int> newCount = const Value.absent(),
                Value<int> totalCount = const Value.absent(),
                Value<DateTime?> lastStudied = const Value.absent(),
                Value<String> updatedAtHlc = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DecksCompanion(
                id: id,
                title: title,
                description: description,
                dueCount: dueCount,
                newCount: newCount,
                totalCount: totalCount,
                lastStudied: lastStudied,
                updatedAtHlc: updatedAtHlc,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String description,
                Value<int> dueCount = const Value.absent(),
                Value<int> newCount = const Value.absent(),
                Value<int> totalCount = const Value.absent(),
                Value<DateTime?> lastStudied = const Value.absent(),
                Value<String> updatedAtHlc = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DecksCompanion.insert(
                id: id,
                title: title,
                description: description,
                dueCount: dueCount,
                newCount: newCount,
                totalCount: totalCount,
                lastStudied: lastStudied,
                updatedAtHlc: updatedAtHlc,
                isDeleted: isDeleted,
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
                      referencedItemsForCurrentItem: (item, referencedItems) =>
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

typedef $$DecksTableProcessedTableManager =
    ProcessedTableManager<
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
      PrefetchHooks Function({bool cardsRefs})
    >;
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
  Value<String> updatedAtHlc,
  Value<bool> isDeleted,
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
  Value<String> updatedAtHlc,
  Value<bool> isDeleted,
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

  ColumnFilters<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  $$DecksTableFilterComposer get deckId {
    final $$DecksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableFilterComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
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
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewLogsTableFilterComposer(
            $db: $db,
            $table: $db.reviewLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
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

  ColumnOrderings<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  $$DecksTableOrderingComposer get deckId {
    final $$DecksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableOrderingComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
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

  GeneratedColumn<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  $$DecksTableAnnotationComposer get deckId {
    final $$DecksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableAnnotationComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
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
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReviewLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.reviewLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardsTableTableManager
    extends
        RootTableManager<
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
          PrefetchHooks Function({bool deckId, bool reviewLogsRefs})
        > {
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
          updateCompanionCallback:
              ({
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
                Value<String> updatedAtHlc = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardsCompanion(
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
                updatedAtHlc: updatedAtHlc,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
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
                Value<String> updatedAtHlc = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardsCompanion.insert(
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
                updatedAtHlc: updatedAtHlc,
                isDeleted: isDeleted,
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
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (deckId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.deckId,
                        referencedTable: $$CardsTableReferences._deckIdTable(
                          db,
                        ),
                        referencedColumn: $$CardsTableReferences
                            ._deckIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (reviewLogsRefs)
                    await $_getPrefetchedData<Card, $CardsTable, ReviewLog>(
                      currentTable: table,
                      referencedTable: $$CardsTableReferences
                          ._reviewLogsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CardsTableReferences(db, table, p0).reviewLogsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
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

typedef $$CardsTableProcessedTableManager =
    ProcessedTableManager<
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
      PrefetchHooks Function({bool deckId, bool reviewLogsRefs})
    >;
typedef $$ReviewLogsTableCreateCompanionBuilder = ReviewLogsCompanion Function({
  Value<int> id,
  required String cardId,
  required int rating,
  required DateTime reviewTime,
  Value<int> scheduledDays,
  Value<int> elapsedDays,
  Value<String?> clientLogId,
});
typedef $$ReviewLogsTableUpdateCompanionBuilder = ReviewLogsCompanion Function({
  Value<int> id,
  Value<String> cardId,
  Value<int> rating,
  Value<DateTime> reviewTime,
  Value<int> scheduledDays,
  Value<int> elapsedDays,
  Value<String?> clientLogId,
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

  ColumnFilters<String> get clientLogId => $composableBuilder(
    column: $table.clientLogId,
    builder: (column) => ColumnFilters(column),
  );

  $$CardsTableFilterComposer get cardId {
    final $$CardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableFilterComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
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

  ColumnOrderings<String> get clientLogId => $composableBuilder(
    column: $table.clientLogId,
    builder: (column) => ColumnOrderings(column),
  );

  $$CardsTableOrderingComposer get cardId {
    final $$CardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableOrderingComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
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

  GeneratedColumn<String> get clientLogId => $composableBuilder(
    column: $table.clientLogId,
    builder: (column) => column,
  );

  $$CardsTableAnnotationComposer get cardId {
    final $$CardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableAnnotationComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReviewLogsTableTableManager
    extends
        RootTableManager<
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
          PrefetchHooks Function({bool cardId})
        > {
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
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> cardId = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<DateTime> reviewTime = const Value.absent(),
                Value<int> scheduledDays = const Value.absent(),
                Value<int> elapsedDays = const Value.absent(),
                Value<String?> clientLogId = const Value.absent(),
              }) => ReviewLogsCompanion(
                id: id,
                cardId: cardId,
                rating: rating,
                reviewTime: reviewTime,
                scheduledDays: scheduledDays,
                elapsedDays: elapsedDays,
                clientLogId: clientLogId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String cardId,
                required int rating,
                required DateTime reviewTime,
                Value<int> scheduledDays = const Value.absent(),
                Value<int> elapsedDays = const Value.absent(),
                Value<String?> clientLogId = const Value.absent(),
              }) => ReviewLogsCompanion.insert(
                id: id,
                cardId: cardId,
                rating: rating,
                reviewTime: reviewTime,
                scheduledDays: scheduledDays,
                elapsedDays: elapsedDays,
                clientLogId: clientLogId,
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
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (cardId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.cardId,
                        referencedTable: $$ReviewLogsTableReferences
                            ._cardIdTable(db),
                        referencedColumn: $$ReviewLogsTableReferences
                            ._cardIdTable(db)
                            .id,
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

typedef $$ReviewLogsTableProcessedTableManager =
    ProcessedTableManager<
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
      PrefetchHooks Function({bool cardId})
    >;
typedef $$GrammarProgressEntriesTableCreateCompanionBuilder =
    GrammarProgressEntriesCompanion Function({
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
      Value<String> updatedAtHlc,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$GrammarProgressEntriesTableUpdateCompanionBuilder =
    GrammarProgressEntriesCompanion Function({
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
      Value<String> updatedAtHlc,
      Value<bool> isDeleted,
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

  ColumnFilters<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
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

  ColumnOrderings<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
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

  GeneratedColumn<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$GrammarProgressEntriesTableTableManager
    extends
        RootTableManager<
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
            BaseReferences<
              _$AppDatabase,
              $GrammarProgressEntriesTable,
              GrammarProgressEntry
            >,
          ),
          GrammarProgressEntry,
          PrefetchHooks Function()
        > {
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
          updateCompanionCallback:
              ({
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
                Value<String> updatedAtHlc = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GrammarProgressEntriesCompanion(
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
                updatedAtHlc: updatedAtHlc,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
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
                Value<String> updatedAtHlc = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GrammarProgressEntriesCompanion.insert(
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
                updatedAtHlc: updatedAtHlc,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $GrammarProgressEntriesTable,
                    GrammarProgressEntry
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $GrammarProgressEntriesTable,
                    GrammarProgressEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GrammarProgressEntriesTableProcessedTableManager =
    ProcessedTableManager<
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
        BaseReferences<
          _$AppDatabase,
          $GrammarProgressEntriesTable,
          GrammarProgressEntry
        >,
      ),
      GrammarProgressEntry,
      PrefetchHooks Function()
    >;
typedef $$SyncOutboxTableCreateCompanionBuilder = SyncOutboxCompanion Function({
  required String id,
  required String entityType,
  required String entityId,
  required String operation,
  required String payloadJson,
  required String hlc,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$SyncOutboxTableUpdateCompanionBuilder = SyncOutboxCompanion Function({
  Value<String> id,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> operation,
  Value<String> payloadJson,
  Value<String> hlc,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$SyncOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableFilterComposer({
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

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableOrderingComposer({
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

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlc => $composableBuilder(
    column: $table.hlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hlc =>
      $composableBuilder(column: $table.hlc, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncOutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncOutboxTable,
          SyncOutboxData,
          $$SyncOutboxTableFilterComposer,
          $$SyncOutboxTableOrderingComposer,
          $$SyncOutboxTableAnnotationComposer,
          $$SyncOutboxTableCreateCompanionBuilder,
          $$SyncOutboxTableUpdateCompanionBuilder,
          (
            SyncOutboxData,
            BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxData>,
          ),
          SyncOutboxData,
          PrefetchHooks Function()
        > {
  $$SyncOutboxTableTableManager(_$AppDatabase db, $SyncOutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> hlc = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payloadJson: payloadJson,
                hlc: hlc,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityType,
                required String entityId,
                required String operation,
                required String payloadJson,
                required String hlc,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payloadJson: payloadJson,
                hlc: hlc,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncOutboxTable, SyncOutboxData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SyncOutboxTable,
                    SyncOutboxData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncOutboxTable,
      SyncOutboxData,
      $$SyncOutboxTableFilterComposer,
      $$SyncOutboxTableOrderingComposer,
      $$SyncOutboxTableAnnotationComposer,
      $$SyncOutboxTableCreateCompanionBuilder,
      $$SyncOutboxTableUpdateCompanionBuilder,
      (
        SyncOutboxData,
        BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxData>,
      ),
      SyncOutboxData,
      PrefetchHooks Function()
    >;
typedef $$SyncCursorsTableCreateCompanionBuilder =
    SyncCursorsCompanion Function({
      required String entityType,
      Value<String> lastServerHlc,
      Value<DateTime> lastSyncedAt,
      Value<int> rowid,
    });
typedef $$SyncCursorsTableUpdateCompanionBuilder =
    SyncCursorsCompanion Function({
      Value<String> entityType,
      Value<String> lastServerHlc,
      Value<DateTime> lastSyncedAt,
      Value<int> rowid,
    });

class $$SyncCursorsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastServerHlc => $composableBuilder(
    column: $table.lastServerHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncCursorsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastServerHlc => $composableBuilder(
    column: $table.lastServerHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncCursorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastServerHlc => $composableBuilder(
    column: $table.lastServerHlc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $$SyncCursorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncCursorsTable,
          SyncCursor,
          $$SyncCursorsTableFilterComposer,
          $$SyncCursorsTableOrderingComposer,
          $$SyncCursorsTableAnnotationComposer,
          $$SyncCursorsTableCreateCompanionBuilder,
          $$SyncCursorsTableUpdateCompanionBuilder,
          (
            SyncCursor,
            BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>,
          ),
          SyncCursor,
          PrefetchHooks Function()
        > {
  $$SyncCursorsTableTableManager(_$AppDatabase db, $SyncCursorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entityType = const Value.absent(),
                Value<String> lastServerHlc = const Value.absent(),
                Value<DateTime> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion(
                entityType: entityType,
                lastServerHlc: lastServerHlc,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entityType,
                Value<String> lastServerHlc = const Value.absent(),
                Value<DateTime> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncCursorsCompanion.insert(
                entityType: entityType,
                lastServerHlc: lastServerHlc,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncCursorsTable, SyncCursor>(table),
                  BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncCursorsTable,
      SyncCursor,
      $$SyncCursorsTableFilterComposer,
      $$SyncCursorsTableOrderingComposer,
      $$SyncCursorsTableAnnotationComposer,
      $$SyncCursorsTableCreateCompanionBuilder,
      $$SyncCursorsTableUpdateCompanionBuilder,
      (
        SyncCursor,
        BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>,
      ),
      SyncCursor,
      PrefetchHooks Function()
    >;
typedef $$ExamPapersTableCreateCompanionBuilder = ExamPapersCompanion Function({
  required String id,
  required String title,
  Value<String> description,
  Value<String> category,
  Value<String> level,
  Value<int> durationMinutes,
  Value<int> totalQuestions,
  Value<int> passingScore,
  Value<String> iconName,
  Value<int> version,
  Value<bool> isPublished,
  Value<bool> isDownloaded,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});
typedef $$ExamPapersTableUpdateCompanionBuilder = ExamPapersCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> description,
  Value<String> category,
  Value<String> level,
  Value<int> durationMinutes,
  Value<int> totalQuestions,
  Value<int> passingScore,
  Value<String> iconName,
  Value<int> version,
  Value<bool> isPublished,
  Value<bool> isDownloaded,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$ExamPapersTableReferences
    extends BaseReferences<_$AppDatabase, $ExamPapersTable, ExamPaper> {
  $$ExamPapersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExamSectionsTable, List<ExamSection>>
  _examSectionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.examSections,
    aliasName: 'exam_papers__id__exam_sections__exam_id',
  );

  $$ExamSectionsTableProcessedTableManager get examSectionsRefs {
    final manager = $$ExamSectionsTableTableManager(
      $_db,
      $_db.examSections,
    ).filter((f) => f.examId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_examSectionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExamQuestionsTable, List<ExamQuestion>>
  _examQuestionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.examQuestions,
    aliasName: 'exam_papers__id__exam_questions__exam_id',
  );

  $$ExamQuestionsTableProcessedTableManager get examQuestionsRefs {
    final manager = $$ExamQuestionsTableTableManager(
      $_db,
      $_db.examQuestions,
    ).filter((f) => f.examId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_examQuestionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExamSubmissionsTable, List<ExamSubmission>>
  _examSubmissionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.examSubmissions,
    aliasName: 'exam_papers__id__exam_submissions__exam_id',
  );

  $$ExamSubmissionsTableProcessedTableManager get examSubmissionsRefs {
    final manager = $$ExamSubmissionsTableTableManager(
      $_db,
      $_db.examSubmissions,
    ).filter((f) => f.examId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _examSubmissionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExamPapersTableFilterComposer
    extends Composer<_$AppDatabase, $ExamPapersTable> {
  $$ExamPapersTableFilterComposer({
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

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get passingScore => $composableBuilder(
    column: $table.passingScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPublished => $composableBuilder(
    column: $table.isPublished,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDownloaded => $composableBuilder(
    column: $table.isDownloaded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> examSectionsRefs(
    Expression<bool> Function($$ExamSectionsTableFilterComposer f) f,
  ) {
    final $$ExamSectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.examSections,
      getReferencedColumn: (t) => t.examId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamSectionsTableFilterComposer(
            $db: $db,
            $table: $db.examSections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> examQuestionsRefs(
    Expression<bool> Function($$ExamQuestionsTableFilterComposer f) f,
  ) {
    final $$ExamQuestionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.examQuestions,
      getReferencedColumn: (t) => t.examId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamQuestionsTableFilterComposer(
            $db: $db,
            $table: $db.examQuestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> examSubmissionsRefs(
    Expression<bool> Function($$ExamSubmissionsTableFilterComposer f) f,
  ) {
    final $$ExamSubmissionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.examSubmissions,
      getReferencedColumn: (t) => t.examId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamSubmissionsTableFilterComposer(
            $db: $db,
            $table: $db.examSubmissions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExamPapersTableOrderingComposer
    extends Composer<_$AppDatabase, $ExamPapersTable> {
  $$ExamPapersTableOrderingComposer({
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

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get passingScore => $composableBuilder(
    column: $table.passingScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPublished => $composableBuilder(
    column: $table.isPublished,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDownloaded => $composableBuilder(
    column: $table.isDownloaded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExamPapersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExamPapersTable> {
  $$ExamPapersTableAnnotationComposer({
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

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get passingScore => $composableBuilder(
    column: $table.passingScore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isPublished => $composableBuilder(
    column: $table.isPublished,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDownloaded => $composableBuilder(
    column: $table.isDownloaded,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> examSectionsRefs<T extends Object>(
    Expression<T> Function($$ExamSectionsTableAnnotationComposer a) f,
  ) {
    final $$ExamSectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.examSections,
      getReferencedColumn: (t) => t.examId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamSectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.examSections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> examQuestionsRefs<T extends Object>(
    Expression<T> Function($$ExamQuestionsTableAnnotationComposer a) f,
  ) {
    final $$ExamQuestionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.examQuestions,
      getReferencedColumn: (t) => t.examId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamQuestionsTableAnnotationComposer(
            $db: $db,
            $table: $db.examQuestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> examSubmissionsRefs<T extends Object>(
    Expression<T> Function($$ExamSubmissionsTableAnnotationComposer a) f,
  ) {
    final $$ExamSubmissionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.examSubmissions,
      getReferencedColumn: (t) => t.examId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamSubmissionsTableAnnotationComposer(
            $db: $db,
            $table: $db.examSubmissions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExamPapersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExamPapersTable,
          ExamPaper,
          $$ExamPapersTableFilterComposer,
          $$ExamPapersTableOrderingComposer,
          $$ExamPapersTableAnnotationComposer,
          $$ExamPapersTableCreateCompanionBuilder,
          $$ExamPapersTableUpdateCompanionBuilder,
          (ExamPaper, $$ExamPapersTableReferences),
          ExamPaper,
          PrefetchHooks Function({
            bool examSectionsRefs,
            bool examQuestionsRefs,
            bool examSubmissionsRefs,
          })
        > {
  $$ExamPapersTableTableManager(_$AppDatabase db, $ExamPapersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExamPapersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExamPapersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExamPapersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<int> durationMinutes = const Value.absent(),
                Value<int> totalQuestions = const Value.absent(),
                Value<int> passingScore = const Value.absent(),
                Value<String> iconName = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<bool> isPublished = const Value.absent(),
                Value<bool> isDownloaded = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExamPapersCompanion(
                id: id,
                title: title,
                description: description,
                category: category,
                level: level,
                durationMinutes: durationMinutes,
                totalQuestions: totalQuestions,
                passingScore: passingScore,
                iconName: iconName,
                version: version,
                isPublished: isPublished,
                isDownloaded: isDownloaded,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String> description = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<int> durationMinutes = const Value.absent(),
                Value<int> totalQuestions = const Value.absent(),
                Value<int> passingScore = const Value.absent(),
                Value<String> iconName = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<bool> isPublished = const Value.absent(),
                Value<bool> isDownloaded = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExamPapersCompanion.insert(
                id: id,
                title: title,
                description: description,
                category: category,
                level: level,
                durationMinutes: durationMinutes,
                totalQuestions: totalQuestions,
                passingScore: passingScore,
                iconName: iconName,
                version: version,
                isPublished: isPublished,
                isDownloaded: isDownloaded,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExamPapersTable, ExamPaper>(table),
                  $$ExamPapersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                examSectionsRefs = false,
                examQuestionsRefs = false,
                examSubmissionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (examSectionsRefs) db.examSections,
                    if (examQuestionsRefs) db.examQuestions,
                    if (examSubmissionsRefs) db.examSubmissions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (examSectionsRefs)
                        await $_getPrefetchedData<
                          ExamPaper,
                          $ExamPapersTable,
                          ExamSection
                        >(
                          currentTable: table,
                          referencedTable: $$ExamPapersTableReferences
                              ._examSectionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExamPapersTableReferences(
                                db,
                                table,
                                p0,
                              ).examSectionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.examId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (examQuestionsRefs)
                        await $_getPrefetchedData<
                          ExamPaper,
                          $ExamPapersTable,
                          ExamQuestion
                        >(
                          currentTable: table,
                          referencedTable: $$ExamPapersTableReferences
                              ._examQuestionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExamPapersTableReferences(
                                db,
                                table,
                                p0,
                              ).examQuestionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.examId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (examSubmissionsRefs)
                        await $_getPrefetchedData<
                          ExamPaper,
                          $ExamPapersTable,
                          ExamSubmission
                        >(
                          currentTable: table,
                          referencedTable: $$ExamPapersTableReferences
                              ._examSubmissionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExamPapersTableReferences(
                                db,
                                table,
                                p0,
                              ).examSubmissionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.examId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ExamPapersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExamPapersTable,
      ExamPaper,
      $$ExamPapersTableFilterComposer,
      $$ExamPapersTableOrderingComposer,
      $$ExamPapersTableAnnotationComposer,
      $$ExamPapersTableCreateCompanionBuilder,
      $$ExamPapersTableUpdateCompanionBuilder,
      (ExamPaper, $$ExamPapersTableReferences),
      ExamPaper,
      PrefetchHooks Function({
        bool examSectionsRefs,
        bool examQuestionsRefs,
        bool examSubmissionsRefs,
      })
    >;
typedef $$ExamSectionsTableCreateCompanionBuilder =
    ExamSectionsCompanion Function({
      required String id,
      required String examId,
      required String title,
      Value<String> sectionType,
      Value<int> orderIndex,
      Value<String> instruction,
      Value<int> rowid,
    });
typedef $$ExamSectionsTableUpdateCompanionBuilder =
    ExamSectionsCompanion Function({
      Value<String> id,
      Value<String> examId,
      Value<String> title,
      Value<String> sectionType,
      Value<int> orderIndex,
      Value<String> instruction,
      Value<int> rowid,
    });

final class $$ExamSectionsTableReferences
    extends BaseReferences<_$AppDatabase, $ExamSectionsTable, ExamSection> {
  $$ExamSectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExamPapersTable _examIdTable(_$AppDatabase db) =>
      db.examPapers.createAlias('exam_sections__exam_id__exam_papers__id');

  $$ExamPapersTableProcessedTableManager get examId {
    final $_column = $_itemColumn<String>('exam_id')!;

    final manager = $$ExamPapersTableTableManager(
      $_db,
      $_db.examPapers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_examIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ExamQuestionsTable, List<ExamQuestion>>
  _examQuestionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.examQuestions,
    aliasName: 'exam_sections__id__exam_questions__section_id',
  );

  $$ExamQuestionsTableProcessedTableManager get examQuestionsRefs {
    final manager = $$ExamQuestionsTableTableManager(
      $_db,
      $_db.examQuestions,
    ).filter((f) => f.sectionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_examQuestionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExamSectionsTableFilterComposer
    extends Composer<_$AppDatabase, $ExamSectionsTable> {
  $$ExamSectionsTableFilterComposer({
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

  ColumnFilters<String> get sectionType => $composableBuilder(
    column: $table.sectionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instruction => $composableBuilder(
    column: $table.instruction,
    builder: (column) => ColumnFilters(column),
  );

  $$ExamPapersTableFilterComposer get examId {
    final $$ExamPapersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examId,
      referencedTable: $db.examPapers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamPapersTableFilterComposer(
            $db: $db,
            $table: $db.examPapers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> examQuestionsRefs(
    Expression<bool> Function($$ExamQuestionsTableFilterComposer f) f,
  ) {
    final $$ExamQuestionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.examQuestions,
      getReferencedColumn: (t) => t.sectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamQuestionsTableFilterComposer(
            $db: $db,
            $table: $db.examQuestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExamSectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExamSectionsTable> {
  $$ExamSectionsTableOrderingComposer({
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

  ColumnOrderings<String> get sectionType => $composableBuilder(
    column: $table.sectionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instruction => $composableBuilder(
    column: $table.instruction,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExamPapersTableOrderingComposer get examId {
    final $$ExamPapersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examId,
      referencedTable: $db.examPapers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamPapersTableOrderingComposer(
            $db: $db,
            $table: $db.examPapers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExamSectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExamSectionsTable> {
  $$ExamSectionsTableAnnotationComposer({
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

  GeneratedColumn<String> get sectionType => $composableBuilder(
    column: $table.sectionType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get instruction => $composableBuilder(
    column: $table.instruction,
    builder: (column) => column,
  );

  $$ExamPapersTableAnnotationComposer get examId {
    final $$ExamPapersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examId,
      referencedTable: $db.examPapers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamPapersTableAnnotationComposer(
            $db: $db,
            $table: $db.examPapers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> examQuestionsRefs<T extends Object>(
    Expression<T> Function($$ExamQuestionsTableAnnotationComposer a) f,
  ) {
    final $$ExamQuestionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.examQuestions,
      getReferencedColumn: (t) => t.sectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamQuestionsTableAnnotationComposer(
            $db: $db,
            $table: $db.examQuestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExamSectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExamSectionsTable,
          ExamSection,
          $$ExamSectionsTableFilterComposer,
          $$ExamSectionsTableOrderingComposer,
          $$ExamSectionsTableAnnotationComposer,
          $$ExamSectionsTableCreateCompanionBuilder,
          $$ExamSectionsTableUpdateCompanionBuilder,
          (ExamSection, $$ExamSectionsTableReferences),
          ExamSection,
          PrefetchHooks Function({bool examId, bool examQuestionsRefs})
        > {
  $$ExamSectionsTableTableManager(_$AppDatabase db, $ExamSectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExamSectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExamSectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExamSectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> examId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> sectionType = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<String> instruction = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExamSectionsCompanion(
                id: id,
                examId: examId,
                title: title,
                sectionType: sectionType,
                orderIndex: orderIndex,
                instruction: instruction,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String examId,
                required String title,
                Value<String> sectionType = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<String> instruction = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExamSectionsCompanion.insert(
                id: id,
                examId: examId,
                title: title,
                sectionType: sectionType,
                orderIndex: orderIndex,
                instruction: instruction,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExamSectionsTable, ExamSection>(table),
                  $$ExamSectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({examId = false, examQuestionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (examQuestionsRefs) db.examQuestions,
              ],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (examId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.examId,
                        referencedTable: $$ExamSectionsTableReferences
                            ._examIdTable(db),
                        referencedColumn: $$ExamSectionsTableReferences
                            ._examIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (examQuestionsRefs)
                    await $_getPrefetchedData<
                      ExamSection,
                      $ExamSectionsTable,
                      ExamQuestion
                    >(
                      currentTable: table,
                      referencedTable: $$ExamSectionsTableReferences
                          ._examQuestionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ExamSectionsTableReferences(
                            db,
                            table,
                            p0,
                          ).examQuestionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sectionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ExamSectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExamSectionsTable,
      ExamSection,
      $$ExamSectionsTableFilterComposer,
      $$ExamSectionsTableOrderingComposer,
      $$ExamSectionsTableAnnotationComposer,
      $$ExamSectionsTableCreateCompanionBuilder,
      $$ExamSectionsTableUpdateCompanionBuilder,
      (ExamSection, $$ExamSectionsTableReferences),
      ExamSection,
      PrefetchHooks Function({bool examId, bool examQuestionsRefs})
    >;
typedef $$ExamQuestionsTableCreateCompanionBuilder =
    ExamQuestionsCompanion Function({
      required String id,
      required String examId,
      required String sectionId,
      Value<int> questionNumber,
      required String questionText,
      Value<String?> contextPassage,
      Value<String?> audioUrl,
      Value<String> optionsJson,
      required String correctAnswer,
      Value<String> explanation,
      Value<int> points,
      Value<int> rowid,
    });
typedef $$ExamQuestionsTableUpdateCompanionBuilder =
    ExamQuestionsCompanion Function({
      Value<String> id,
      Value<String> examId,
      Value<String> sectionId,
      Value<int> questionNumber,
      Value<String> questionText,
      Value<String?> contextPassage,
      Value<String?> audioUrl,
      Value<String> optionsJson,
      Value<String> correctAnswer,
      Value<String> explanation,
      Value<int> points,
      Value<int> rowid,
    });

final class $$ExamQuestionsTableReferences
    extends BaseReferences<_$AppDatabase, $ExamQuestionsTable, ExamQuestion> {
  $$ExamQuestionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExamPapersTable _examIdTable(_$AppDatabase db) =>
      db.examPapers.createAlias('exam_questions__exam_id__exam_papers__id');

  $$ExamPapersTableProcessedTableManager get examId {
    final $_column = $_itemColumn<String>('exam_id')!;

    final manager = $$ExamPapersTableTableManager(
      $_db,
      $_db.examPapers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_examIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExamSectionsTable _sectionIdTable(_$AppDatabase db) => db.examSections
      .createAlias('exam_questions__section_id__exam_sections__id');

  $$ExamSectionsTableProcessedTableManager get sectionId {
    final $_column = $_itemColumn<String>('section_id')!;

    final manager = $$ExamSectionsTableTableManager(
      $_db,
      $_db.examSections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExamQuestionsTableFilterComposer
    extends Composer<_$AppDatabase, $ExamQuestionsTable> {
  $$ExamQuestionsTableFilterComposer({
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

  ColumnFilters<int> get questionNumber => $composableBuilder(
    column: $table.questionNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionText => $composableBuilder(
    column: $table.questionText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextPassage => $composableBuilder(
    column: $table.contextPassage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get optionsJson => $composableBuilder(
    column: $table.optionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get correctAnswer => $composableBuilder(
    column: $table.correctAnswer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnFilters(column),
  );

  $$ExamPapersTableFilterComposer get examId {
    final $$ExamPapersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examId,
      referencedTable: $db.examPapers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamPapersTableFilterComposer(
            $db: $db,
            $table: $db.examPapers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExamSectionsTableFilterComposer get sectionId {
    final $$ExamSectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.examSections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamSectionsTableFilterComposer(
            $db: $db,
            $table: $db.examSections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExamQuestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExamQuestionsTable> {
  $$ExamQuestionsTableOrderingComposer({
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

  ColumnOrderings<int> get questionNumber => $composableBuilder(
    column: $table.questionNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionText => $composableBuilder(
    column: $table.questionText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextPassage => $composableBuilder(
    column: $table.contextPassage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get optionsJson => $composableBuilder(
    column: $table.optionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get correctAnswer => $composableBuilder(
    column: $table.correctAnswer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExamPapersTableOrderingComposer get examId {
    final $$ExamPapersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examId,
      referencedTable: $db.examPapers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamPapersTableOrderingComposer(
            $db: $db,
            $table: $db.examPapers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExamSectionsTableOrderingComposer get sectionId {
    final $$ExamSectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.examSections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamSectionsTableOrderingComposer(
            $db: $db,
            $table: $db.examSections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExamQuestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExamQuestionsTable> {
  $$ExamQuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get questionNumber => $composableBuilder(
    column: $table.questionNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get questionText => $composableBuilder(
    column: $table.questionText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contextPassage => $composableBuilder(
    column: $table.contextPassage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audioUrl =>
      $composableBuilder(column: $table.audioUrl, builder: (column) => column);

  GeneratedColumn<String> get optionsJson => $composableBuilder(
    column: $table.optionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get correctAnswer => $composableBuilder(
    column: $table.correctAnswer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get points =>
      $composableBuilder(column: $table.points, builder: (column) => column);

  $$ExamPapersTableAnnotationComposer get examId {
    final $$ExamPapersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examId,
      referencedTable: $db.examPapers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamPapersTableAnnotationComposer(
            $db: $db,
            $table: $db.examPapers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExamSectionsTableAnnotationComposer get sectionId {
    final $$ExamSectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.examSections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamSectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.examSections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExamQuestionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExamQuestionsTable,
          ExamQuestion,
          $$ExamQuestionsTableFilterComposer,
          $$ExamQuestionsTableOrderingComposer,
          $$ExamQuestionsTableAnnotationComposer,
          $$ExamQuestionsTableCreateCompanionBuilder,
          $$ExamQuestionsTableUpdateCompanionBuilder,
          (ExamQuestion, $$ExamQuestionsTableReferences),
          ExamQuestion,
          PrefetchHooks Function({bool examId, bool sectionId})
        > {
  $$ExamQuestionsTableTableManager(_$AppDatabase db, $ExamQuestionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExamQuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExamQuestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExamQuestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> examId = const Value.absent(),
                Value<String> sectionId = const Value.absent(),
                Value<int> questionNumber = const Value.absent(),
                Value<String> questionText = const Value.absent(),
                Value<String?> contextPassage = const Value.absent(),
                Value<String?> audioUrl = const Value.absent(),
                Value<String> optionsJson = const Value.absent(),
                Value<String> correctAnswer = const Value.absent(),
                Value<String> explanation = const Value.absent(),
                Value<int> points = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExamQuestionsCompanion(
                id: id,
                examId: examId,
                sectionId: sectionId,
                questionNumber: questionNumber,
                questionText: questionText,
                contextPassage: contextPassage,
                audioUrl: audioUrl,
                optionsJson: optionsJson,
                correctAnswer: correctAnswer,
                explanation: explanation,
                points: points,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String examId,
                required String sectionId,
                Value<int> questionNumber = const Value.absent(),
                required String questionText,
                Value<String?> contextPassage = const Value.absent(),
                Value<String?> audioUrl = const Value.absent(),
                Value<String> optionsJson = const Value.absent(),
                required String correctAnswer,
                Value<String> explanation = const Value.absent(),
                Value<int> points = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExamQuestionsCompanion.insert(
                id: id,
                examId: examId,
                sectionId: sectionId,
                questionNumber: questionNumber,
                questionText: questionText,
                contextPassage: contextPassage,
                audioUrl: audioUrl,
                optionsJson: optionsJson,
                correctAnswer: correctAnswer,
                explanation: explanation,
                points: points,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExamQuestionsTable, ExamQuestion>(table),
                  $$ExamQuestionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({examId = false, sectionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (examId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.examId,
                        referencedTable: $$ExamQuestionsTableReferences
                            ._examIdTable(db),
                        referencedColumn: $$ExamQuestionsTableReferences
                            ._examIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (sectionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sectionId,
                        referencedTable: $$ExamQuestionsTableReferences
                            ._sectionIdTable(db),
                        referencedColumn: $$ExamQuestionsTableReferences
                            ._sectionIdTable(db)
                            .id,
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

typedef $$ExamQuestionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExamQuestionsTable,
      ExamQuestion,
      $$ExamQuestionsTableFilterComposer,
      $$ExamQuestionsTableOrderingComposer,
      $$ExamQuestionsTableAnnotationComposer,
      $$ExamQuestionsTableCreateCompanionBuilder,
      $$ExamQuestionsTableUpdateCompanionBuilder,
      (ExamQuestion, $$ExamQuestionsTableReferences),
      ExamQuestion,
      PrefetchHooks Function({bool examId, bool sectionId})
    >;
typedef $$ExamSubmissionsTableCreateCompanionBuilder =
    ExamSubmissionsCompanion Function({
      required String id,
      required String examId,
      Value<int> score,
      Value<int> totalCorrect,
      Value<int> totalQuestions,
      Value<int> durationSeconds,
      Value<String> answersJson,
      Value<DateTime> submittedAt,
      Value<String> updatedAtHlc,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$ExamSubmissionsTableUpdateCompanionBuilder =
    ExamSubmissionsCompanion Function({
      Value<String> id,
      Value<String> examId,
      Value<int> score,
      Value<int> totalCorrect,
      Value<int> totalQuestions,
      Value<int> durationSeconds,
      Value<String> answersJson,
      Value<DateTime> submittedAt,
      Value<String> updatedAtHlc,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

final class $$ExamSubmissionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ExamSubmissionsTable, ExamSubmission> {
  $$ExamSubmissionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExamPapersTable _examIdTable(_$AppDatabase db) =>
      db.examPapers.createAlias('exam_submissions__exam_id__exam_papers__id');

  $$ExamPapersTableProcessedTableManager get examId {
    final $_column = $_itemColumn<String>('exam_id')!;

    final manager = $$ExamPapersTableTableManager(
      $_db,
      $_db.examPapers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_examIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExamSubmissionsTableFilterComposer
    extends Composer<_$AppDatabase, $ExamSubmissionsTable> {
  $$ExamSubmissionsTableFilterComposer({
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

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCorrect => $composableBuilder(
    column: $table.totalCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answersJson => $composableBuilder(
    column: $table.answersJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  $$ExamPapersTableFilterComposer get examId {
    final $$ExamPapersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examId,
      referencedTable: $db.examPapers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamPapersTableFilterComposer(
            $db: $db,
            $table: $db.examPapers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExamSubmissionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExamSubmissionsTable> {
  $$ExamSubmissionsTableOrderingComposer({
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

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCorrect => $composableBuilder(
    column: $table.totalCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answersJson => $composableBuilder(
    column: $table.answersJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExamPapersTableOrderingComposer get examId {
    final $$ExamPapersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examId,
      referencedTable: $db.examPapers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamPapersTableOrderingComposer(
            $db: $db,
            $table: $db.examPapers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExamSubmissionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExamSubmissionsTable> {
  $$ExamSubmissionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get totalCorrect => $composableBuilder(
    column: $table.totalCorrect,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get answersJson => $composableBuilder(
    column: $table.answersJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  $$ExamPapersTableAnnotationComposer get examId {
    final $$ExamPapersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examId,
      referencedTable: $db.examPapers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamPapersTableAnnotationComposer(
            $db: $db,
            $table: $db.examPapers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExamSubmissionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExamSubmissionsTable,
          ExamSubmission,
          $$ExamSubmissionsTableFilterComposer,
          $$ExamSubmissionsTableOrderingComposer,
          $$ExamSubmissionsTableAnnotationComposer,
          $$ExamSubmissionsTableCreateCompanionBuilder,
          $$ExamSubmissionsTableUpdateCompanionBuilder,
          (ExamSubmission, $$ExamSubmissionsTableReferences),
          ExamSubmission,
          PrefetchHooks Function({bool examId})
        > {
  $$ExamSubmissionsTableTableManager(
    _$AppDatabase db,
    $ExamSubmissionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExamSubmissionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExamSubmissionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExamSubmissionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> examId = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<int> totalCorrect = const Value.absent(),
                Value<int> totalQuestions = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<String> answersJson = const Value.absent(),
                Value<DateTime> submittedAt = const Value.absent(),
                Value<String> updatedAtHlc = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExamSubmissionsCompanion(
                id: id,
                examId: examId,
                score: score,
                totalCorrect: totalCorrect,
                totalQuestions: totalQuestions,
                durationSeconds: durationSeconds,
                answersJson: answersJson,
                submittedAt: submittedAt,
                updatedAtHlc: updatedAtHlc,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String examId,
                Value<int> score = const Value.absent(),
                Value<int> totalCorrect = const Value.absent(),
                Value<int> totalQuestions = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<String> answersJson = const Value.absent(),
                Value<DateTime> submittedAt = const Value.absent(),
                Value<String> updatedAtHlc = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExamSubmissionsCompanion.insert(
                id: id,
                examId: examId,
                score: score,
                totalCorrect: totalCorrect,
                totalQuestions: totalQuestions,
                durationSeconds: durationSeconds,
                answersJson: answersJson,
                submittedAt: submittedAt,
                updatedAtHlc: updatedAtHlc,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExamSubmissionsTable, ExamSubmission>(table),
                  $$ExamSubmissionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({examId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (examId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.examId,
                        referencedTable: $$ExamSubmissionsTableReferences
                            ._examIdTable(db),
                        referencedColumn: $$ExamSubmissionsTableReferences
                            ._examIdTable(db)
                            .id,
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

typedef $$ExamSubmissionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExamSubmissionsTable,
      ExamSubmission,
      $$ExamSubmissionsTableFilterComposer,
      $$ExamSubmissionsTableOrderingComposer,
      $$ExamSubmissionsTableAnnotationComposer,
      $$ExamSubmissionsTableCreateCompanionBuilder,
      $$ExamSubmissionsTableUpdateCompanionBuilder,
      (ExamSubmission, $$ExamSubmissionsTableReferences),
      ExamSubmission,
      PrefetchHooks Function({bool examId})
    >;
typedef $$WrongQuestionNotebookTableCreateCompanionBuilder =
    WrongQuestionNotebookCompanion Function({
      required String id,
      required String examId,
      required String questionId,
      required String userAnswer,
      Value<String> explanation,
      Value<String> notes,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> updatedAtHlc,
      Value<bool> isDeleted,
      Value<int> rowid,
    });
typedef $$WrongQuestionNotebookTableUpdateCompanionBuilder =
    WrongQuestionNotebookCompanion Function({
      Value<String> id,
      Value<String> examId,
      Value<String> questionId,
      Value<String> userAnswer,
      Value<String> explanation,
      Value<String> notes,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> updatedAtHlc,
      Value<bool> isDeleted,
      Value<int> rowid,
    });

class $$WrongQuestionNotebookTableFilterComposer
    extends Composer<_$AppDatabase, $WrongQuestionNotebookTable> {
  $$WrongQuestionNotebookTableFilterComposer({
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

  ColumnFilters<String> get examId => $composableBuilder(
    column: $table.examId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userAnswer => $composableBuilder(
    column: $table.userAnswer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WrongQuestionNotebookTableOrderingComposer
    extends Composer<_$AppDatabase, $WrongQuestionNotebookTable> {
  $$WrongQuestionNotebookTableOrderingComposer({
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

  ColumnOrderings<String> get examId => $composableBuilder(
    column: $table.examId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userAnswer => $composableBuilder(
    column: $table.userAnswer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WrongQuestionNotebookTableAnnotationComposer
    extends Composer<_$AppDatabase, $WrongQuestionNotebookTable> {
  $$WrongQuestionNotebookTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get examId =>
      $composableBuilder(column: $table.examId, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userAnswer => $composableBuilder(
    column: $table.userAnswer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAtHlc => $composableBuilder(
    column: $table.updatedAtHlc,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);
}

class $$WrongQuestionNotebookTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WrongQuestionNotebookTable,
          WrongQuestionNotebookData,
          $$WrongQuestionNotebookTableFilterComposer,
          $$WrongQuestionNotebookTableOrderingComposer,
          $$WrongQuestionNotebookTableAnnotationComposer,
          $$WrongQuestionNotebookTableCreateCompanionBuilder,
          $$WrongQuestionNotebookTableUpdateCompanionBuilder,
          (
            WrongQuestionNotebookData,
            BaseReferences<
              _$AppDatabase,
              $WrongQuestionNotebookTable,
              WrongQuestionNotebookData
            >,
          ),
          WrongQuestionNotebookData,
          PrefetchHooks Function()
        > {
  $$WrongQuestionNotebookTableTableManager(
    _$AppDatabase db,
    $WrongQuestionNotebookTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WrongQuestionNotebookTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$WrongQuestionNotebookTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WrongQuestionNotebookTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> examId = const Value.absent(),
                Value<String> questionId = const Value.absent(),
                Value<String> userAnswer = const Value.absent(),
                Value<String> explanation = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> updatedAtHlc = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WrongQuestionNotebookCompanion(
                id: id,
                examId: examId,
                questionId: questionId,
                userAnswer: userAnswer,
                explanation: explanation,
                notes: notes,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                updatedAtHlc: updatedAtHlc,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String examId,
                required String questionId,
                required String userAnswer,
                Value<String> explanation = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> updatedAtHlc = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WrongQuestionNotebookCompanion.insert(
                id: id,
                examId: examId,
                questionId: questionId,
                userAnswer: userAnswer,
                explanation: explanation,
                notes: notes,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                updatedAtHlc: updatedAtHlc,
                isDeleted: isDeleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $WrongQuestionNotebookTable,
                    WrongQuestionNotebookData
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $WrongQuestionNotebookTable,
                    WrongQuestionNotebookData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WrongQuestionNotebookTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WrongQuestionNotebookTable,
      WrongQuestionNotebookData,
      $$WrongQuestionNotebookTableFilterComposer,
      $$WrongQuestionNotebookTableOrderingComposer,
      $$WrongQuestionNotebookTableAnnotationComposer,
      $$WrongQuestionNotebookTableCreateCompanionBuilder,
      $$WrongQuestionNotebookTableUpdateCompanionBuilder,
      (
        WrongQuestionNotebookData,
        BaseReferences<
          _$AppDatabase,
          $WrongQuestionNotebookTable,
          WrongQuestionNotebookData
        >,
      ),
      WrongQuestionNotebookData,
      PrefetchHooks Function()
    >;

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
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db, _db.syncOutbox);
  $$SyncCursorsTableTableManager get syncCursors =>
      $$SyncCursorsTableTableManager(_db, _db.syncCursors);
  $$ExamPapersTableTableManager get examPapers =>
      $$ExamPapersTableTableManager(_db, _db.examPapers);
  $$ExamSectionsTableTableManager get examSections =>
      $$ExamSectionsTableTableManager(_db, _db.examSections);
  $$ExamQuestionsTableTableManager get examQuestions =>
      $$ExamQuestionsTableTableManager(_db, _db.examQuestions);
  $$ExamSubmissionsTableTableManager get examSubmissions =>
      $$ExamSubmissionsTableTableManager(_db, _db.examSubmissions);
  $$WrongQuestionNotebookTableTableManager get wrongQuestionNotebook =>
      $$WrongQuestionNotebookTableTableManager(_db, _db.wrongQuestionNotebook);
}
