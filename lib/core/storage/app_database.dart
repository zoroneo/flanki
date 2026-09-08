import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Decks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  IntColumn get dueCount => integer().withDefault(const Constant(0))();
  IntColumn get newCount => integer().withDefault(const Constant(0))();
  IntColumn get totalCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastStudied => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Cards extends Table {
  TextColumn get id => text()();
  TextColumn get deckId =>
      text().references(Decks, #id, onDelete: KeyAction.cascade)();
  TextColumn get front => text()();
  TextColumn get back => text()();
  TextColumn get hint => text().nullable()();
  TextColumn get noteType => text().withDefault(const Constant('basic'))();
  IntColumn get flag => integer().withDefault(const Constant(0))();
  BoolColumn get isSuspended => boolean().withDefault(const Constant(false))();
  BoolColumn get isBuried => boolean().withDefault(const Constant(false))();
  TextColumn get tags => text().withDefault(const Constant(''))();
  IntColumn get intervalDays => integer().withDefault(const Constant(0))();
  RealColumn get stability => real().withDefault(const Constant(0.0))();
  RealColumn get difficulty => real().withDefault(const Constant(0.0))();
  IntColumn get reps => integer().withDefault(const Constant(0))();
  IntColumn get lapses => integer().withDefault(const Constant(0))();
  DateTimeColumn get due => dateTime().nullable()();
  DateTimeColumn get lastStudied => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ReviewLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get cardId =>
      text().references(Cards, #id, onDelete: KeyAction.cascade)();
  IntColumn get rating => integer()();
  DateTimeColumn get reviewTime => dateTime()();
  IntColumn get scheduledDays => integer().withDefault(const Constant(0))();
  IntColumn get elapsedDays => integer().withDefault(const Constant(0))();
}

@DriftDatabase(tables: [Decks, Cards, ReviewLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? driftDatabase(name: 'flanki'));

  @override
  int get schemaVersion => 1;
}
