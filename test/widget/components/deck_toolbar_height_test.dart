import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

void main() {
  testWidgets('Check height inside ListView', (tester) async {
    await tester.pumpWidget(
      ShadcnApp(
        home: Scaffold(
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: const [
              SizedBox(
                height: 38,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: TextField(
                        features: [
                          InputFeature.leading(
                            Icon(LucideIcons.search, size: 18),
                          ),
                        ],
                        placeholder: Text('Search...'),
                      ),
                    ),
                    SizedBox(width: 12),
                    PrimaryButton(
                      leading: Icon(LucideIcons.plus, size: 16),
                      child: Text('Add Deck'),
                    ),
                    SizedBox(width: 8),
                    OutlineButton(
                      leading: Icon(LucideIcons.fileUp, size: 16),
                      child: Text('Import'),
                    ),
                    SizedBox(width: 8),
                    GhostButton(
                      leading: Icon(LucideIcons.zap, size: 16),
                      child: Text('Custom'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final inputSize = tester.getSize(find.byType(TextField));
    final primarySize = tester.getSize(find.byType(PrimaryButton));
    final outlineSize = tester.getSize(find.byType(OutlineButton));
    final ghostSize = tester.getSize(find.byType(GhostButton));

    expect(inputSize.height, equals(38.0));
    expect(primarySize.height, equals(38.0));
    expect(outlineSize.height, equals(38.0));
    expect(ghostSize.height, equals(38.0));
  });
}
