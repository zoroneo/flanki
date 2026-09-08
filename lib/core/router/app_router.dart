import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ui/screens/auth/anki_web_auth_screen.dart';
import '../../ui/screens/browser/card_browser_screen.dart';
import '../../ui/screens/decks/decks_screen.dart';
import '../../ui/screens/editor/note_editor_screen.dart';
import '../../ui/screens/settings/licenses_screen.dart';
import '../../ui/screens/settings/privacy_policy_screen.dart';
import '../../ui/screens/settings/settings_screen.dart';
import '../../ui/screens/stats/stats_screen.dart';
import '../../ui/screens/study/study_session_screen.dart';
import '../../ui/widgets/adaptive_scaffold.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouterProvider = Provider<GoRouter>((ref) {
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
    ],
  );
});
