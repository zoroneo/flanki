import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flanki/core/sync/circuit_breaker.dart';
import 'package:flanki/core/sync/sync_telemetry_service.dart';
import 'package:flanki/features/sync/ui/widgets/sync_diagnostics_sheet.dart';
import 'package:flanki/l10n/generated/app_localizations.dart';

void main() {
  setUp(() {
    SyncTelemetryService.instance.clear();
  });

  testWidgets('SyncDiagnosticsSheet renders header, KPIs, and empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ShadcnApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(child: SyncDiagnosticsSheet()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title & Subtitle
    expect(find.text('Sync Diagnostics & Telemetry'), findsOneWidget);
    expect(find.text('Success Rate'), findsOneWidget);
    expect(find.text('Avg Latency'), findsOneWidget);
    expect(find.text('Data Transferred'), findsOneWidget);
    expect(find.text('Bandwidth Saved'), findsOneWidget);

    // Verify Circuit Breaker default state
    expect(find.text('Circuit Breaker'), findsOneWidget);
    expect(find.text('Healthy (Closed)'), findsOneWidget);

    // Verify empty state
    expect(find.text('No sync cycles recorded yet.'), findsOneWidget);
  });

  testWidgets('SyncDiagnosticsSheet displays sync history item when present', (
    tester,
  ) async {
    SyncTelemetryService.instance.recordCycle(
      durationMs: 145,
      isSuccess: true,
      pushedCount: 3,
      pulledCount: 1,
      circuitState: CircuitState.closed,
    );

    await tester.pumpWidget(
      const ProviderScope(
        child: ShadcnApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(child: SyncDiagnosticsSheet()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Should display log item
    expect(find.text('Pushed: 3 | Pulled: 1 | Media: 0'), findsOneWidget);
    expect(find.text('145ms'), findsOneWidget);
    expect(find.text('100.0%'), findsOneWidget);
  });
}
