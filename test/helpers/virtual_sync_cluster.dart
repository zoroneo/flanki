import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flanki/core/database/app_database.dart';
import 'package:flanki/core/database/database_service.dart';
import 'package:flanki/core/sync/supabase_sync_engine.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// In-memory Mock Supabase Server Hub replicating exact PostgreSQL RPC logic:
/// `sync_push_mutations` & `sync_pull_deltas` with LWW conflict resolution.
class MockSupabaseCloudHub implements SupabaseRpcClient {
  User? user;

  final Map<String, Map<String, dynamic>> decks = {};
  final Map<String, Map<String, dynamic>> cards = {};
  final Map<String, Map<String, dynamic>> reviewLogs = {};
  final Map<String, Map<String, dynamic>> grammarProgress = {};
  final Map<String, Map<String, dynamic>> examSubmissions = {};
  final Map<String, Map<String, dynamic>> wrongQuestions = {};
  final List<Map<String, dynamic>> mockPapers = [];
  final Map<String, List<Map<String, dynamic>>> mockSections = {};
  final Map<String, List<Map<String, dynamic>>> mockQuestions = {};

  // Fault Injection Controls
  bool failNextPush = false;
  bool failNextPull = false;
  bool failPushAfterCommit = false;
  int pushCount = 0;
  int pullCount = 0;

  MockSupabaseCloudHub({User? initialUser})
    : user =
          initialUser ??
          const User(
            id: 'test_user_global',
            appMetadata: {},
            userMetadata: {},
            aud: 'authenticated',
            createdAt: '2026-09-16T00:00:00Z',
            email: 'test@flanki.io',
          );

  @override
  User? get currentUser => user;

  @override
  Future<dynamic> rpc(String function, {Map<String, dynamic>? params}) async {
    if (user == null) {
      throw const AuthException('User must be logged in to execute RPC');
    }

    if (function == 'sync_push_mutations') {
      pushCount++;
      if (failNextPush) {
        failNextPush = false;
        throw const SocketException('Connection reset by peer (injected)');
      }

      final mutations = (params?['mutations'] as List<dynamic>?) ?? [];
      final ackIds = <String>[];

      for (final m in mutations) {
        final mutation = Map<String, dynamic>.from(m as Map);
        final id = mutation['id'] as String;
        final entityType = mutation['entity_type'] as String;
        final entityId = mutation['entity_id'] as String;
        final op = mutation['op'] as String;
        final isDeleted = mutation['is_deleted'] as bool? ?? (op == 'DELETE');
        final payload = Map<String, dynamic>.from(mutation['payload'] as Map);
        final hlc = mutation['hlc'] as String;

        if (entityType == 'deck') {
          final existing = decks[entityId];
          final existingHlc = existing?['updated_at_hlc'] as String? ?? '';
          if (existing == null || hlc.compareTo(existingHlc) >= 0) {
            decks[entityId] = {
              ...?existing,
              ...payload,
              'id': entityId,
              'updated_at_hlc': hlc,
              'is_deleted': isDeleted,
            };
          }
        } else if (entityType == 'card') {
          final existing = cards[entityId];
          final existingHlc = existing?['updated_at_hlc'] as String? ?? '';
          if (existing == null || hlc.compareTo(existingHlc) >= 0) {
            cards[entityId] = {
              ...?existing,
              ...payload,
              'id': entityId,
              'updated_at_hlc': hlc,
              'is_deleted': isDeleted,
            };
          }
        } else if (entityType == 'review_log') {
          final clientLogId = payload['client_log_id'] as String? ?? entityId;
          if (!reviewLogs.containsKey(clientLogId)) {
            reviewLogs[clientLogId] = {
              ...payload,
              'client_log_id': clientLogId,
              'created_at':
                  payload['review_time'] ??
                  DateTime.now().toUtc().toIso8601String(),
            };
          }
        } else if (entityType == 'grammar_progress') {
          final existing = grammarProgress[entityId];
          final existingHlc = existing?['updated_at_hlc'] as String? ?? '';
          if (existing == null || hlc.compareTo(existingHlc) >= 0) {
            grammarProgress[entityId] = {
              ...?existing,
              ...payload,
              'id': entityId,
              'updated_at_hlc': hlc,
              'is_deleted': isDeleted,
            };
          }
        } else if (entityType == 'exam_submission') {
          final existing = examSubmissions[entityId];
          final existingHlc = existing?['updated_at_hlc'] as String? ?? '';
          if (existing == null || hlc.compareTo(existingHlc) >= 0) {
            examSubmissions[entityId] = {
              ...?existing,
              ...payload,
              'id': entityId,
              'updated_at_hlc': hlc,
              'is_deleted': isDeleted,
            };
          }
        } else if (entityType == 'wrong_question') {
          final existing = wrongQuestions[entityId];
          final existingHlc = existing?['updated_at_hlc'] as String? ?? '';
          if (existing == null || hlc.compareTo(existingHlc) >= 0) {
            wrongQuestions[entityId] = {
              ...?existing,
              ...payload,
              'id': entityId,
              'updated_at_hlc': hlc,
              'is_deleted': isDeleted,
            };
          }
        }

        ackIds.add(id);
      }

      if (failPushAfterCommit) {
        failPushAfterCommit = false;
        throw const SocketException(
          'Server committed but network dropped before ACK (injected)',
        );
      }

      return {
        'ack_ids': ackIds,
        'server_timestamp': DateTime.now().toUtc().toIso8601String(),
        'processed_count': ackIds.length,
      };
    }

    if (function == 'sync_pull_deltas') {
      pullCount++;
      if (failNextPull) {
        failNextPull = false;
        throw const SocketException(
          'Connection timed out during pull (injected)',
        );
      }

      final cursors = (params?['cursors'] as Map<String, dynamic>?) ?? {};
      final deckCursor = cursors['deck'] as String? ?? '';
      final cardCursor = cursors['card'] as String? ?? '';
      final revlogCursor =
          cursors['review_log'] as String? ?? '1970-01-01T00:00:00.000Z';
      final grammarCursor = cursors['grammar_progress'] as String? ?? '';
      final examCursor = cursors['exam_submission'] as String? ?? '';
      final wrongQuestionCursor = cursors['wrong_question'] as String? ?? '';

      final matchedDecks = decks.values
          .where(
            (d) =>
                (d['updated_at_hlc'] as String? ?? '').compareTo(deckCursor) >
                0,
          )
          .toList();

      final matchedCards = cards.values
          .where(
            (c) =>
                (c['updated_at_hlc'] as String? ?? '').compareTo(cardCursor) >
                0,
          )
          .toList();

      final matchedLogs = reviewLogs.values
          .where(
            (l) =>
                (l['created_at'] as String? ?? '').compareTo(revlogCursor) > 0,
          )
          .toList();

      final matchedGrammar = grammarProgress.values
          .where(
            (g) =>
                (g['updated_at_hlc'] as String? ?? '').compareTo(
                  grammarCursor,
                ) >
                0,
          )
          .toList();

      final matchedExams = examSubmissions.values
          .where(
            (e) =>
                (e['updated_at_hlc'] as String? ?? '').compareTo(examCursor) >
                0,
          )
          .toList();

      final matchedWrongs = wrongQuestions.values
          .where(
            (w) =>
                (w['updated_at_hlc'] as String? ?? '').compareTo(
                  wrongQuestionCursor,
                ) >
                0,
          )
          .toList();

      return {
        'decks': matchedDecks,
        'cards': matchedCards,
        'review_logs': matchedLogs,
        'grammar_progress': matchedGrammar,
        'exam_submissions': matchedExams,
        'wrong_questions': matchedWrongs,
      };
    }

    if (function == 'fetch_exam_catalog') {
      final category = params?['p_category'] as String?;
      final level = params?['p_level'] as String?;

      return mockPapers.where((p) {
        if (category != null && p['category'] != category) return false;
        if (level != null && p['level'] != level) return false;
        return true;
      }).toList();
    }

    if (function == 'download_exam_paper') {
      final examId = params?['p_exam_id'] as String?;
      final paper = mockPapers.firstWhere(
        (p) => p['id'] == examId,
        orElse: () => <String, dynamic>{},
      );
      final sections = mockSections[examId] ?? [];
      final questions = mockQuestions[examId] ?? [];

      return {'paper': paper, 'sections': sections, 'questions': questions};
    }

    throw UnimplementedError('RPC function $function not mocked');
  }
}

/// Represents an isolated physical device in the multi-device test cluster.
class VirtualSyncNode {
  final String nodeId;
  late final AppDatabase db;
  late final DatabaseService dbService;
  late final SupabaseSyncEngine engine;
  final MockSupabaseCloudHub cloudHub;

  VirtualSyncNode({required this.nodeId, required this.cloudHub});

  Future<void> init() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    dbService = DatabaseService.forTest(db);
    dbService.configureNodeId(nodeId);
    await dbService.init();

    engine = SupabaseSyncEngine(rpcClient: cloudHub, dbService: dbService);
  }

  Future<void> close() async {
    await dbService.close();
  }
}
