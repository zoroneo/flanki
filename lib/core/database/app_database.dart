import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/card.dart';

part 'app_database.g.dart';

class Decks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  IntColumn get dueCount => integer().withDefault(const Constant(0))();
  IntColumn get newCount => integer().withDefault(const Constant(0))();
  IntColumn get totalCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastStudied => dateTime().nullable()();

  // Sync Metadata
  TextColumn get updatedAtHlc => text().withDefault(const Constant(''))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

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

  // Sync Metadata
  TextColumn get updatedAtHlc => text().withDefault(const Constant(''))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

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

  // Sync Idempotency Key
  TextColumn get clientLogId => text().nullable()();
}

class GrammarProgressEntries extends Table {
  TextColumn get unitId => text()();
  TextColumn get exerciseId => text()();
  RealColumn get stability => real().withDefault(const Constant(0.0))();
  RealColumn get difficulty => real().withDefault(const Constant(0.0))();
  DateTimeColumn get due => dateTime().nullable()();
  DateTimeColumn get lastStudied => dateTime().nullable()();
  IntColumn get reps => integer().withDefault(const Constant(0))();
  IntColumn get lapses => integer().withDefault(const Constant(0))();
  IntColumn get state => intEnum<CardState>().withDefault(const Constant(0))();
  BoolColumn get isGhost => boolean().withDefault(const Constant(false))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  TextColumn get lastUserAnswer => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  // Sync Metadata
  TextColumn get updatedAtHlc => text().withDefault(const Constant(''))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {unitId, exerciseId};
}

/// Transactional Outbox for local mutations waiting to be synced to cloud.
class SyncOutbox extends Table {
  TextColumn get id => text()(); // Mutation UUID
  TextColumn get entityType =>
      text()(); // 'deck', 'card', 'review_log', 'grammar_progress'
  TextColumn get entityId => text()();
  TextColumn get operation => text()(); // 'UPSERT', 'DELETE'
  TextColumn get payloadJson => text()();
  TextColumn get hlc => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Sync Cursors tracking the last acknowledged server HLC per entity table.
class SyncCursors extends Table {
  TextColumn get entityType => text()();
  TextColumn get lastServerHlc => text().withDefault(const Constant(''))();
  DateTimeColumn get lastSyncedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {entityType};
}

/// Local cached catalog of Exam Papers.
class ExamPapers extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get category => text().withDefault(const Constant('JLPT'))();
  TextColumn get level => text().withDefault(const Constant('N3'))();
  IntColumn get durationMinutes => integer().withDefault(const Constant(60))();
  IntColumn get totalQuestions => integer().withDefault(const Constant(40))();
  IntColumn get passingScore => integer().withDefault(const Constant(60))();
  TextColumn get iconName => text().withDefault(const Constant('file-text'))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get isPublished => boolean().withDefault(const Constant(true))();
  BoolColumn get isDownloaded => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Sections within an Exam Paper.
class ExamSections extends Table {
  TextColumn get id => text()();
  TextColumn get examId =>
      text().references(ExamPapers, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text()();
  TextColumn get sectionType => text().withDefault(const Constant('general'))();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
  TextColumn get instruction => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Detailed questions belonging to an Exam Section.
class ExamQuestions extends Table {
  TextColumn get id => text()();
  TextColumn get examId =>
      text().references(ExamPapers, #id, onDelete: KeyAction.cascade)();
  TextColumn get sectionId =>
      text().references(ExamSections, #id, onDelete: KeyAction.cascade)();
  IntColumn get questionNumber => integer().withDefault(const Constant(1))();
  TextColumn get questionText => text()();
  TextColumn get contextPassage => text().nullable()();
  TextColumn get audioUrl => text().nullable()();
  TextColumn get optionsJson => text().withDefault(const Constant('[]'))();
  TextColumn get correctAnswer => text()();
  TextColumn get explanation => text().withDefault(const Constant(''))();
  IntColumn get points => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Personal Exam Submission record synchronized with Supabase.
class ExamSubmissions extends Table {
  TextColumn get id => text()();
  TextColumn get examId =>
      text().references(ExamPapers, #id, onDelete: KeyAction.cascade)();
  IntColumn get score => integer().withDefault(const Constant(0))();
  IntColumn get totalCorrect => integer().withDefault(const Constant(0))();
  IntColumn get totalQuestions => integer().withDefault(const Constant(0))();
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();
  TextColumn get answersJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get submittedAt =>
      dateTime().withDefault(currentDateAndTime)();

  // Sync Metadata
  TextColumn get updatedAtHlc => text().withDefault(const Constant(''))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Personal Wrong Question Notebook for reviewing mistakes across exams.
class WrongQuestionNotebook extends Table {
  TextColumn get id => text()();
  TextColumn get examId => text()();
  TextColumn get questionId => text()();
  TextColumn get userAnswer => text()();
  TextColumn get explanation => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get status =>
      text().withDefault(const Constant('new'))(); // new, reviewing, mastered
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  // Sync Metadata
  TextColumn get updatedAtHlc => text().withDefault(const Constant(''))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Decks,
    Cards,
    ReviewLogs,
    GrammarProgressEntries,
    SyncOutbox,
    SyncCursors,
    ExamPapers,
    ExamSections,
    ExamQuestions,
    ExamSubmissions,
    WrongQuestionNotebook,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? driftDatabase(name: 'flanki'));

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(grammarProgressEntries);
      }
      if (from < 3) {
        await m.createTable(syncOutbox);
        await m.createTable(syncCursors);
        await m.addColumn(decks, decks.updatedAtHlc);
        await m.addColumn(decks, decks.isDeleted);
        await m.addColumn(cards, cards.updatedAtHlc);
        await m.addColumn(cards, cards.isDeleted);
        await m.addColumn(reviewLogs, reviewLogs.clientLogId);
        await m.addColumn(
          grammarProgressEntries,
          grammarProgressEntries.updatedAtHlc,
        );
        await m.addColumn(
          grammarProgressEntries,
          grammarProgressEntries.isDeleted,
        );
      }
      if (from < 4) {
        await m.createTable(examPapers);
        await m.createTable(examSections);
        await m.createTable(examQuestions);
        await m.createTable(examSubmissions);
        await m.createTable(wrongQuestionNotebook);
      }
    },
  );
}
