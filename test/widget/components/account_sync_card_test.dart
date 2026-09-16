import 'package:flutter_test/flutter_test.dart';
import 'package:flanki/core/sync/supabase_sync_engine.dart';
import 'package:flanki/features/settings/ui/widgets/account_sync_card.dart';
import 'package:flanki/features/sync/providers/supabase_auth_notifier.dart';
import 'package:flanki/features/sync/providers/sync_state_notifier.dart';
import 'package:flanki/l10n/generated/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseAuthNotifier extends SupabaseAuthNotifier {
  final SupabaseAuthState _initialState;
  final Future<void> Function()? onSignOut;

  MockSupabaseAuthNotifier({SupabaseAuthState? initialState, this.onSignOut})
    : _initialState =
          initialState ??
          const SupabaseAuthState(status: SupabaseAuthStatus.unauthenticated);

  @override
  SupabaseAuthState build() => _initialState;

  @override
  Future<void> signOut() async {
    await onSignOut?.call();
  }
}

class MockSyncStateNotifier extends SyncStateNotifier {
  final SyncUiState _initialState;
  final Future<void> Function()? onSyncNow;

  MockSyncStateNotifier({SyncUiState? initialState, this.onSyncNow})
    : _initialState = initialState ?? const SyncUiState();

  @override
  SyncUiState build() => _initialState;

  @override
  Future<SyncResult> syncNow() async {
    await onSyncNow?.call();
    return const SyncResult(isSuccess: true);
  }
}

Widget createTestableWidget({
  required Widget child,
  List<dynamic> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides.cast(),
    child: ShadcnApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(child: SingleChildScrollView(child: child)),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AccountSyncCard Widget Tests', () {
    testWidgets('renders unauthenticated state with login button and AnkiWeb', (
      tester,
    ) async {
      final mockAuth = MockSupabaseAuthNotifier();
      final mockSync = MockSyncStateNotifier();
      final isSyncing = ValueNotifier<bool>(false);

      await tester.pumpWidget(
        createTestableWidget(
          child: AccountSyncCard(isSyncing: isSyncing, onSync: () async {}),
          overrides: [
            supabaseAuthNotifierProvider.overrideWith(() => mockAuth),
            syncStateNotifierProvider.overrideWith(() => mockSync),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AccountSyncCard), findsOneWidget);
      expect(find.text('AnkiWeb (Legacy)'), findsOneWidget);
      expect(find.byType(PrimaryButton), findsOneWidget);
    });

    testWidgets(
      'renders authenticated state with user email, logout, and sync buttons',
      (tester) async {
        bool signOutCalled = false;
        bool syncNowCalled = false;

        const user = User(
          id: 'user_456',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: '2026-09-16T00:00:00Z',
          email: 'flanki_user@example.com',
        );

        final mockAuth = MockSupabaseAuthNotifier(
          initialState: const SupabaseAuthState(
            status: SupabaseAuthStatus.authenticated,
            user: user,
          ),
          onSignOut: () async {
            signOutCalled = true;
          },
        );

        final mockSync = MockSyncStateNotifier(
          onSyncNow: () async {
            syncNowCalled = true;
          },
        );

        final isSyncing = ValueNotifier<bool>(false);

        await tester.pumpWidget(
          createTestableWidget(
            child: AccountSyncCard(isSyncing: isSyncing, onSync: () async {}),
            overrides: [
              supabaseAuthNotifierProvider.overrideWith(() => mockAuth),
              syncStateNotifierProvider.overrideWith(() => mockSync),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('flanki_user@example.com'), findsOneWidget);

        // Tap Sync button (PrimaryButton)
        final primaryButtons = find.byType(PrimaryButton);
        expect(primaryButtons, findsOneWidget);
        await tester.tap(primaryButtons);
        await tester.pumpAndSettle();
        expect(syncNowCalled, isTrue);

        // Tap Sign Out button (OutlineButton for Cloud)
        final outlineButtons = find.byType(OutlineButton);
        expect(outlineButtons, findsWidgets);
        await tester.tap(outlineButtons.first);
        await tester.pumpAndSettle();
        expect(signOutCalled, isTrue);
      },
    );
  });
}
