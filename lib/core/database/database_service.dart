import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../config/app_config.dart';
import '../models/card.dart';
import '../models/custom_study_mode.dart';
import '../models/deck.dart';
import '../models/exam_models.dart';
import '../models/review_log.dart';
import '../sync/hlc.dart';
import 'app_database.dart';
import 'daos/card_dao.dart';
import 'daos/database_context.dart';
import 'daos/deck_dao.dart';
import 'daos/exam_dao.dart';
import 'daos/review_log_dao.dart';
import 'daos/sync_outbox_dao.dart';
import 'daos/user_media_dao.dart';
import 'data_change_bus.dart';

export '../models/review_log.dart';
export '../models/sync_payloads.dart';
export 'daos/card_dao.dart';
export 'daos/deck_dao.dart';
export 'daos/exam_dao.dart';
export 'daos/review_log_dao.dart';
export 'daos/sync_outbox_dao.dart';
export 'daos/user_media_dao.dart';

/// Central database service providing thread-safe SQLite access via Drift
/// and coordinating sub-domain DAOs (Decks, Cards, ReviewLogs, Sync, Exam, Media).
class DatabaseService implements DatabaseContext {
  static DatabaseService? _instance;
  AppDatabase? _db;

  // Sub-domain DAOs
  late final DeckDao _deckDao;
  late final CardDao _cardDao;
  late final ReviewLogDao _reviewLogDao;
  late final SyncOutboxDao _syncOutboxDao;
  late final ExamDao _examDao;
  late final UserMediaDao _userMediaDao;

  // Hybrid Logical Clock (HLC) & Node Identity
  String _nodeId = IdHelper.generateNodeId();
  Hlc? _lastHlc;

  @override
  String get nodeId => _nodeId;
  Hlc get currentHlc => _lastHlc ?? Hlc.now(_nodeId);

  void configureNodeId(String id) {
    _nodeId = id;
  }

  @override
  Hlc advanceHlc({int? wallTime}) {
    _lastHlc = Hlc.send(_lastHlc, _nodeId, wallTime: wallTime);
    return _lastHlc!;
  }

  void updateHlcFromRemote(Hlc remoteHlc) {
    _lastHlc = Hlc.recv(_lastHlc, remoteHlc, _nodeId);
  }

  /// Optional listener triggered whenever a local mutation is enqueued into the outbox.
  @override
  void Function()? onMutationEnqueued;

  // In-memory cache for synchronous fast UI rendering
  List<DeckModel> _cachedDecks = [];
  List<CardModel> _cachedCards = [];
  List<ReviewLogModel> _cachedReviewLogs = [];

  @override
  List<DeckModel> get cachedDecks => _cachedDecks;
  @override
  set cachedDecks(List<DeckModel> value) => _cachedDecks = value;

  @override
  List<CardModel> get cachedCards => _cachedCards;
  @override
  set cachedCards(List<CardModel> value) => _cachedCards = value;

  @override
  List<ReviewLogModel> get cachedReviewLogs => _cachedReviewLogs;
  @override
  set cachedReviewLogs(List<ReviewLogModel> value) => _cachedReviewLogs = value;

  DatabaseService._() {
    _initDaos();
  }

  DatabaseService.forTest(AppDatabase database) : _db = database {
    _initDaos();
  }

  void _initDaos() {
    _deckDao = DeckDao(this);
    _cardDao = CardDao(this);
    _reviewLogDao = ReviewLogDao(this);
    _syncOutboxDao = SyncOutboxDao(this);
    _examDao = ExamDao(this);
    _userMediaDao = UserMediaDao(this);
  }

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  @override
  AppDatabase get db {
    if (_db == null) {
      throw StateError(
        'DatabaseService has not been initialized. Call init() first.',
      );
    }
    return _db!;
  }

  // DAO Getters for modular access
  DeckDao get deckDao => _deckDao;
  CardDao get cardDao => _cardDao;
  ReviewLogDao get reviewLogDao => _reviewLogDao;
  SyncOutboxDao get syncOutboxDao => _syncOutboxDao;
  ExamDao get examDao => _examDao;
  UserMediaDao get userMediaDao => _userMediaDao;

  Future<void> init({String? customPath}) async {
    if (customPath != null && _db != null) {
      await close();
    }
    if (_db == null) {
      if (customPath != null) {
        _db = AppDatabase(NativeDatabase(File(customPath)));
      } else {
        _db = AppDatabase(driftDatabase(name: AppConfig.databaseName));
      }
    }

    await reloadCache();
    unawaited(deduplicateDecks());
  }

  @override
  Future<void> reloadCache() async {
    if (_db == null) return;
    final deckRows =
        await (db.select(db.decks)
              ..where((t) => t.isDeleted.equals(false))
              ..orderBy([(t) => OrderingTerm.asc(t.title)]))
            .get();
    _cachedDecks = deckRows.map((r) {
      return DeckModel(
        id: r.id,
        title: r.title,
        description: r.description,
        dueCount: r.dueCount,
        newCount: r.newCount,
        totalCount: r.totalCount,
        lastStudied: r.lastStudied,
        isSyncEnabled: r.isSyncEnabled,
      );
    }).toList();

    final cardRows =
        await (db.select(db.cards)
              ..where((t) => t.isDeleted.equals(false))
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .get();
    _cachedCards = cardRows.map(CardDao.mapRowToCard).toList();

    final logRows = await (db.select(
      db.reviewLogs,
    )..orderBy([(t) => OrderingTerm.desc(t.reviewTime)])).get();
    _cachedReviewLogs = logRows.map((r) {
      return ReviewLogModel(
        id: r.id,
        cardId: r.cardId,
        rating: ReviewRating.fromValue(r.rating),
        reviewTime: r.reviewTime,
        scheduledDays: r.scheduledDays,
        elapsedDays: r.elapsedDays,
      );
    }).toList();
    DataChangeBus.instance.notifyAll();
  }

  // --- Decks Delegation ---
  List<DeckModel> getAllDecks() => _deckDao.getAllDecks();

  Future<void> saveDeck(DeckModel deck) => _deckDao.saveDeck(deck);

  Future<void> recordDeckStudyProgress(String deckId) =>
      _deckDao.recordDeckStudyProgress(deckId);

  Future<void> saveDecks(List<DeckModel> decks) => _deckDao.saveDecks(decks);

  Future<void> deduplicateDecks() => _deckDao.deduplicateDecks();

  Future<void> deleteDeck(String deckId) => _deckDao.deleteDeck(deckId);

  Future<void> toggleDeckSync(String deckId, bool enabled) =>
      _deckDao.toggleDeckSync(deckId, enabled);

  Future<void> recalculateAllDeckCounts() =>
      _deckDao.recalculateAllDeckCounts();

  // --- Cards Delegation ---
  List<CardModel> getAllCards() => _cardDao.getAllCards();

  List<CardModel> getCardsForDeck(String deckId) =>
      _cardDao.getCardsForDeck(deckId);

  List<CardModel> getStudyQueue(
    String deckId, {
    int? limit,
    int? newLimit,
    int? reviewLimit,
  }) => _cardDao.getStudyQueue(
    deckId,
    limit: limit,
    newLimit: newLimit,
    reviewLimit: reviewLimit,
  );

  List<CardModel> getCramQueue({
    required String filterTag,
    int limit = 20,
    bool onlyFlagged = false,
  }) => _cardDao.getCramQueue(
    filterTag: filterTag,
    limit: limit,
    onlyFlagged: onlyFlagged,
  );

  List<CardModel> getCustomStudyQueue({required String deckId, int? limit}) =>
      _cardDao.getCustomStudyQueue(deckId: deckId, limit: limit);

  int countCardsForCustomStudy({
    required CustomStudyMode mode,
    required String tag,
  }) => _cardDao.countCardsForCustomStudy(mode: mode, tag: tag);

  Future<void> saveCard(CardModel card, {bool markOutbox = true}) =>
      _cardDao.saveCard(card, markOutbox: markOutbox);

  Future<void> saveCards(List<CardModel> cards, {bool markOutbox = true}) =>
      _cardDao.saveCards(cards, markOutbox: markOutbox);

  Future<void> mergeCards(List<CardModel> remoteCards) =>
      _cardDao.mergeCards(remoteCards);

  Future<void> deleteCard(String cardId, {bool markOutbox = true}) =>
      _cardDao.deleteCard(cardId, markOutbox: markOutbox);

  // --- Review Logs Delegation ---
  List<ReviewLogModel> getAllReviewLogs() => _reviewLogDao.getAllReviewLogs();

  Future<void> insertReviewLog({
    required String cardId,
    required ReviewRating rating,
    required DateTime reviewTime,
    required int scheduledDays,
    required int elapsedDays,
  }) => _reviewLogDao.insertReviewLog(
    cardId: cardId,
    rating: rating,
    reviewTime: reviewTime,
    scheduledDays: scheduledDays,
    elapsedDays: elapsedDays,
  );

  Future<void> saveReviewLogs(List<ReviewLogModel> logs) =>
      _reviewLogDao.saveReviewLogs(logs);

  bool hasLocalChangesSince(DateTime? lastSyncTime) =>
      _reviewLogDao.hasLocalChangesSince(lastSyncTime);

  Future<void> saveSyncTemplateBytes(Uint8List bytes) =>
      _reviewLogDao.saveSyncTemplateBytes(bytes);

  Future<void> saveSyncTemplateFile(File sourceFile) =>
      _reviewLogDao.saveSyncTemplateFile(sourceFile);

  Future<Uint8List> exportToAnki2Db() => _reviewLogDao.exportToAnki2Db();

  // --- Sync Outbox Delegation ---
  Future<List<SyncOutboxData>> getPendingOutboxBatch({int limit = 100}) =>
      _syncOutboxDao.getPendingOutboxBatch(limit: limit);

  Future<void> acknowledgeOutboxBatch(List<String> ids) =>
      _syncOutboxDao.acknowledgeOutboxBatch(ids);

  Future<int> getPendingOutboxCount() => _syncOutboxDao.getPendingOutboxCount();

  Future<String?> getSyncCursor(String entityType) =>
      _syncOutboxDao.getSyncCursor(entityType);

  Future<void> setSyncCursor(String entityType, String lastServerHlc) =>
      _syncOutboxDao.setSyncCursor(entityType, lastServerHlc);

  @override
  Future<void> enqueueOutbox({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
    String? hlc,
  }) => _syncOutboxDao.enqueueOutbox(
    entityType: entityType,
    entityId: entityId,
    operation: operation,
    payload: payload,
    hlc: hlc,
  );

  Future<void> applyRemoteDeltasBatch({
    List<Map<String, dynamic>> decks = const [],
    List<Map<String, dynamic>> cards = const [],
    List<Map<String, dynamic>> reviewLogs = const [],
    List<Map<String, dynamic>> grammarProgress = const [],
    List<Map<String, dynamic>> examSubmissions = const [],
    List<Map<String, dynamic>> wrongQuestions = const [],
    List<Map<String, dynamic>> userMedia = const [],
  }) => _syncOutboxDao.applyRemoteDeltasBatch(
    decks: decks,
    cards: cards,
    reviewLogs: reviewLogs,
    grammarProgress: grammarProgress,
    examSubmissions: examSubmissions,
    wrongQuestions: wrongQuestions,
    userMedia: userMedia,
  );

  Future<Map<String, dynamic>> exportDatabaseSnapshot() =>
      _syncOutboxDao.exportDatabaseSnapshot();

  Future<void> restoreDatabaseSnapshot(Map<String, dynamic> data) =>
      _syncOutboxDao.restoreDatabaseSnapshot(data);

  // --- User Media Delegation ---
  static String lookupMimeType(String filename) =>
      UserMediaDao.lookupMimeType(filename);

  Future<UserMediaData> registerLocalMedia({
    required String filename,
    required List<int> bytes,
    String? mimeType,
  }) => _userMediaDao.registerLocalMedia(
    filename: filename,
    bytes: bytes,
    mimeType: mimeType,
  );

  Future<List<UserMediaData>> getPendingUploadMedia({int limit = 50}) =>
      _userMediaDao.getPendingUploadMedia(limit: limit);

  Future<void> markMediaUploaded(String filename) =>
      _userMediaDao.markMediaUploaded(filename);

  Future<List<UserMediaData>> getAllUserMedia() =>
      _userMediaDao.getAllUserMedia();

  Future<UserMediaData?> getUserMedia(String filename) =>
      _userMediaDao.getUserMedia(filename);

  Future<void> deleteMediaLocal(String filename) =>
      _userMediaDao.deleteMediaLocal(filename);

  // --- Exam Bank Delegation ---
  Future<void> saveExamCatalog(List<ExamPaperModel> exams) =>
      _examDao.saveExamCatalog(exams);

  Future<List<ExamPaperModel>> getExamCatalog({
    ExamCategory? category,
    String? level,
  }) => _examDao.getExamCatalog(category: category, level: level);

  Future<ExamPaperModel?> getExamPaperById(String examId) =>
      _examDao.getExamPaperById(examId);

  Future<void> saveExamPaperWithQuestions(
    ExamPaperModel paper,
    List<ExamSectionModel> sections,
    List<ExamQuestionModel> questions,
  ) => _examDao.saveExamPaperWithQuestions(paper, sections, questions);

  Future<List<ExamSectionModel>> getExamSections(String examId) =>
      _examDao.getExamSections(examId);

  Future<List<ExamQuestionModel>> getExamQuestions(String examId) =>
      _examDao.getExamQuestions(examId);

  Future<void> submitExamResult(
    ExamSubmissionModel submission,
    List<WrongQuestionModel> wrongQuestions, {
    bool markOutbox = true,
  }) => _examDao.submitExamResult(
    submission,
    wrongQuestions,
    markOutbox: markOutbox,
  );

  Future<List<ExamSubmissionModel>> getExamSubmissions(String examId) =>
      _examDao.getExamSubmissions(examId);

  Future<List<WrongQuestionModel>> getWrongQuestions({
    String? examId,
    WrongQuestionStatus? status,
  }) => _examDao.getWrongQuestions(examId: examId, status: status);

  Future<void> updateWrongQuestionStatus(
    String id,
    WrongQuestionStatus status, {
    bool markOutbox = true,
  }) => _examDao.updateWrongQuestionStatus(id, status, markOutbox: markOutbox);

  Future<void> close() async {
    await _db?.close();
    _db = null;
    _cachedDecks = [];
    _cachedCards = [];
    _cachedReviewLogs = [];
  }
}
