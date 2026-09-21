import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flanki/features/settings/ui/widgets/cloud_backup_card.dart';
import 'package:flanki/l10n/generated/app_localizations.dart';

void main() {
  testWidgets(
    'CloudBackupCard renders header, storage stats, and action buttons',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: ShadcnApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              child: SingleChildScrollView(child: CloudBackupCard()),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Title & Subtitle
      expect(find.text('Cloud Backup & Snapshot'), findsOneWidget);
      expect(
        find.text('Create or restore comprehensive .flanki snapshots'),
        findsOneWidget,
      );

      // Verify Section and Buttons
      expect(find.text('Storage Breakdown'), findsOneWidget);
      expect(find.text('Back Up Now'), findsOneWidget);
      expect(find.text('Manage Deck Sync'), findsOneWidget);
      expect(find.text('Export .flanki file'), findsOneWidget);
      expect(find.text('Import .flanki file'), findsOneWidget);
    },
  );
}
