import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/grammar/models/grammar_models.dart';
import '../features/exam/ui/exam_catalog_screen.dart';
import '../features/exam/ui/exam_taking_screen.dart';
import '../features/exam/ui/exam_result_screen.dart';
import '../features/exam/ui/wrong_notebook_screen.dart';
import '../features/sync/ui/anki_web_auth_screen.dart';
import '../features/browser/ui/card_browser_screen.dart';
import '../features/decks/ui/decks_screen.dart';
import '../features/editor/ui/note_editor_screen.dart';
import '../features/grammar/ui/grammar_catalog_screen.dart';
import '../features/grammar/ui/grammar_practice_screen.dart';
import '../features/grammar/ui/grammar_theory_screen.dart';
import '../features/settings/ui/licenses_screen.dart';
import '../features/settings/ui/privacy_policy_screen.dart';
import '../features/settings/ui/settings_screen.dart';
import '../features/stats/ui/stats_screen.dart';
import '../features/study/ui/study_session_screen.dart';
import '../app/shell/adaptive_scaffold.dart';

part 'app_router.g.dart';

abstract final class AppRoutes {
  const AppRoutes._();

  static const String decks = '/decks';
  static const String browser = '/browser';
  static const String grammar = '/grammar';
  static const String exams = '/exams';
  static const String stats = '/stats';
  static const String settings = '/settings';
  static const String auth = '/auth';
  static const String editor = '/editor';
  static const String licenses = '/licenses';
  static const String privacyPolicy = '/privacy-policy';
  static const String wrongNotebook = '/exams/wrong-notebook';

  static const String studyPattern = '/decks/:deckId/study';
  static const String grammarTheoryPattern = '/grammar/:unitId/theory';
  static const String grammarPracticePattern = '/grammar/:unitId/practice';
  static const String examTakingPattern = '/exams/:examId/taking';
  static const String examResultPattern = '/exams/:examId/result';

  static String study(String deckId) => '/decks/$deckId/study';
  static String grammarTheory(String unitId) => '/grammar/$unitId/theory';
  static String grammarPractice(String unitId, {String? mode}) => mode != null
      ? '/grammar/$unitId/practice?mode=$mode'
      : '/grammar/$unitId/practice';
  static String examTaking(String examId) => '/exams/$examId/taking';
  static String examResult(String examId) => '/exams/$examId/result';
}

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.decks,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdaptiveScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.decks,
                name: 'decks',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: DecksScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.browser,
                name: 'browser',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: CardBrowserScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.grammar,
                name: 'grammar',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: GrammarCatalogScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.exams,
                name: 'exams',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ExamCatalogScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.stats,
                name: 'stats',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: StatsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                name: 'settings',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SettingsScreen()),
              ),
            ],
          ),
        ],
      ),
      // Top-level full screen routes (no bottom nav)
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.auth,
        name: 'auth',
        builder: (context, state) => const AnkiWebAuthScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.editor,
        name: 'editor',
        builder: (context, state) => const NoteEditorScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.licenses,
        name: 'licenses',
        builder: (context, state) => const LicensesScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.privacyPolicy,
        name: 'privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.studyPattern,
        name: 'study',
        builder: (context, state) {
          final deckId = state.pathParameters['deckId'] ?? 'default';
          return StudySessionScreen(deckId: deckId);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.grammarTheoryPattern,
        name: 'grammar-theory',
        builder: (context, state) {
          final unitId = state.pathParameters['unitId'] ?? '';
          return GrammarTheoryScreen(unitId: unitId);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.grammarPracticePattern,
        name: 'grammar-practice',
        builder: (context, state) {
          final unitId = state.pathParameters['unitId'] ?? '';
          final mode = GrammarPracticeMode.fromString(
            state.uri.queryParameters['mode'],
          );
          return GrammarPracticeScreen(unitId: unitId, mode: mode);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.wrongNotebook,
        name: 'wrong-notebook',
        builder: (context, state) => const WrongNotebookScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.examTakingPattern,
        name: 'exam-taking',
        builder: (context, state) {
          final examId = state.pathParameters['examId'] ?? '';
          return ExamTakingScreen(examId: examId);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.examResultPattern,
        name: 'exam-result',
        builder: (context, state) {
          final examId = state.pathParameters['examId'] ?? '';
          return ExamResultScreen(examId: examId);
        },
      ),
    ],
  );
}
