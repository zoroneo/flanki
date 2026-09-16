import 'package:flutter_test/flutter_test.dart';
import 'package:flanki/core/sync/supabase_sync_engine.dart';
import 'package:flanki/features/sync/providers/supabase_auth_notifier.dart';
import 'package:flanki/features/sync/providers/sync_state_notifier.dart';
import 'package:flanki/features/sync/ui/supabase_auth_sheet.dart';
import 'package:flanki/l10n/generated/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class MockSupabaseAuthNotifier extends SupabaseAuthNotifier {
  final SupabaseAuthState _initialState;
  final Future<bool> Function(String email, String password)? onSignIn;
  final Future<bool> Function(String email, String password)? onSignUp;

  MockSupabaseAuthNotifier({
    SupabaseAuthState? initialState,
    this.onSignIn,
    this.onSignUp,
  }) : _initialState =
           initialState ??
           const SupabaseAuthState(status: SupabaseAuthStatus.unauthenticated);

  @override
  SupabaseAuthState build() => _initialState;

  @override
  Future<bool> signIn(String email, String password) async {
    return onSignIn?.call(email, password) ?? Future.value(true);
  }

  @override
  Future<bool> signUp(String email, String password) async {
    return onSignUp?.call(email, password) ?? Future.value(true);
  }
}

class MockSyncStateNotifier extends SyncStateNotifier {
  final VoidCallback? onSyncNow;

  MockSyncStateNotifier({this.onSyncNow});

  @override
  SyncUiState build() => const SyncUiState();

  @override
  Future<SyncResult> syncNow() async {
    onSyncNow?.call();
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
      home: Scaffold(child: child),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SupabaseAuthSheet Widget Tests', () {
    testWidgets('renders tabs, email, password fields and submit button', (
      tester,
    ) async {
      final mockAuth = MockSupabaseAuthNotifier();

      await tester.pumpWidget(
        createTestableWidget(
          child: const SupabaseAuthSheet(isDesktop: false),
          overrides: [
            supabaseAuthNotifierProvider.overrideWith(() => mockAuth),
            syncStateNotifierProvider.overrideWith(
              () => MockSyncStateNotifier(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SupabaseAuthSheet), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(PrimaryButton), findsOneWidget);
    });

    testWidgets('validates invalid email before submit', (tester) async {
      bool signInCalled = false;
      final mockAuth = MockSupabaseAuthNotifier(
        onSignIn: (e, p) async {
          signInCalled = true;
          return true;
        },
      );

      await tester.pumpWidget(
        createTestableWidget(
          child: const SupabaseAuthSheet(isDesktop: false),
          overrides: [
            supabaseAuthNotifierProvider.overrideWith(() => mockAuth),
            syncStateNotifierProvider.overrideWith(
              () => MockSyncStateNotifier(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'invalid-email');
      await tester.enterText(textFields.last, '123456');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(signInCalled, isFalse);
    });

    testWidgets('calls signIn on successful valid submission', (tester) async {
      String? submittedEmail;
      String? submittedPassword;
      final mockAuth = MockSupabaseAuthNotifier(
        onSignIn: (e, p) async {
          submittedEmail = e;
          submittedPassword = p;
          return true;
        },
      );

      await tester.pumpWidget(
        createTestableWidget(
          child: const SupabaseAuthSheet(isDesktop: false),
          overrides: [
            supabaseAuthNotifierProvider.overrideWith(() => mockAuth),
            syncStateNotifierProvider.overrideWith(
              () => MockSyncStateNotifier(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'user@flanki.io');
      await tester.enterText(textFields.last, 'password123');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      expect(submittedEmail, equals('user@flanki.io'));
      expect(submittedPassword, equals('password123'));
    });
  });
}
