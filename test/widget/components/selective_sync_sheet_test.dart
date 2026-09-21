import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flanki/features/decks/ui/widgets/selective_sync_sheet.dart';
import 'package:flanki/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('SelectiveSyncSheet renders header, empty state or decks list', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ShadcnApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(child: SelectiveSyncSheet()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title & Subtitle
    expect(find.text('Selective Deck Sync'), findsOneWidget);
    expect(
      find.text('Choose which decks sync to the cloud to save storage'),
      findsOneWidget,
    );
  });
}
