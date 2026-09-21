import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flanki/features/sync/ui/widgets/social_auth_buttons.dart';
import 'package:flanki/l10n/generated/app_localizations.dart';

void main() {
  testWidgets(
    'SocialAuthButtons renders Google and Apple buttons and fires callbacks',
    (tester) async {
      bool googleClicked = false;
      bool appleClicked = false;

      await tester.pumpWidget(
        ShadcnApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            child: SocialAuthButtons(
              isLoading: false,
              onGooglePressed: () {
                googleClicked = true;
              },
              onApplePressed: () {
                appleClicked = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify presence of buttons and divider text
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with Apple'), findsOneWidget);
      expect(find.text('Or continue with email'), findsOneWidget);

      // Tap Google button
      await tester.tap(find.text('Continue with Google'));
      await tester.pump();
      expect(googleClicked, isTrue);

      // Tap Apple button
      await tester.tap(find.text('Continue with Apple'));
      await tester.pump();
      expect(appleClicked, isTrue);
    },
  );
}
