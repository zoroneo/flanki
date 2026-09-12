import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/grammar/models/grammar_models.dart';
import '../screens/auth/anki_web_auth_screen.dart';
import '../screens/browser/card_browser_screen.dart';
import '../screens/decks/decks_screen.dart';
import '../screens/editor/note_editor_screen.dart';
import '../../features/grammar/ui/grammar_catalog_screen.dart';
import '../../features/grammar/ui/grammar_practice_screen.dart';
import '../../features/grammar/ui/grammar_theory_screen.dart';
import '../screens/settings/licenses_screen.dart';
import '../screens/settings/privacy_policy_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../../features/stats/ui/stats_screen.dart';
import '../screens/study/study_session_screen.dart';
import '../widgets/adaptive_scaffold.dart';

part 'app_router.g.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/decks',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdaptiveScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/decks',
                name: 'decks',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: DecksScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/browser',
                name: 'browser',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: CardBrowserScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/grammar',
                name: 'grammar',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: GrammarCatalogScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stats',
                name: 'stats',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: StatsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
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
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AnkiWebAuthScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/editor',
        name: 'editor',
        builder: (context, state) => const NoteEditorScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/licenses',
        name: 'licenses',
        builder: (context, state) => const LicensesScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/privacy-policy',
        name: 'privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/decks/:deckId/study',
        name: 'study',
        builder: (context, state) {
          final deckId = state.pathParameters['deckId'] ?? 'default';
          return StudySessionScreen(deckId: deckId);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/grammar/:unitId/theory',
        name: 'grammar-theory',
        builder: (context, state) {
          final unitId = state.pathParameters['unitId'] ?? '';
          return GrammarTheoryScreen(unitId: unitId);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/grammar/:unitId/practice',
        name: 'grammar-practice',
        builder: (context, state) {
          final unitId = state.pathParameters['unitId'] ?? '';
          final mode = GrammarPracticeMode.fromString(
            state.uri.queryParameters['mode'],
          );
          return GrammarPracticeScreen(unitId: unitId, mode: mode);
        },
      ),
    ],
  );
}
