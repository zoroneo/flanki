import 'package:animated_emoji/animated_emoji.dart';
import 'package:flanki/core/widgets/flanki_animated_emoji.dart';
import 'package:flanki/features/decks/ui/widgets/deck_empty_state.dart';
import 'package:flanki/features/exam/models/exam_models.dart';
import 'package:flanki/features/exam/ui/widgets/exam_score_summary_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class MockExamL10n {
  String get examPassed => 'Passed';
  String get examFailed => 'Failed';
  String examScorePoints(int score) => '$score pts';
  String get noDecksFound => 'No decks found';
  String get addNewDeck => 'Add New Deck';
  String get correctCountStat => 'Correct';
  String get durationStat => 'Duration';
  String get passingScoreStat => 'Passing';
}

void main() {
  group('FlankiAnimatedEmoji Widget Tests', () {
    testWidgets('renders AnimatedEmoji with correct size constraints', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ShadcnApp(
          home: Scaffold(
            child: FlankiAnimatedEmoji(emoji: AnimatedEmojis.fire, size: 48.0),
          ),
        ),
      );

      final animatedEmojiFinder = find.byType(AnimatedEmoji);
      expect(animatedEmojiFinder, findsOneWidget);

      final flankiEmojiWidget = tester.widget<FlankiAnimatedEmoji>(
        find.byType(FlankiAnimatedEmoji),
      );
      expect(flankiEmojiWidget.size, equals(48.0));
      expect(flankiEmojiWidget.repeat, isTrue);
    });

    testWidgets('allows overriding repeat to false', (tester) async {
      await tester.pumpWidget(
        const ShadcnApp(
          home: Scaffold(
            child: FlankiAnimatedEmoji(
              emoji: AnimatedEmojis.fire,
              size: 48.0,
              repeat: false,
            ),
          ),
        ),
      );

      final flankiEmojiWidget = tester.widget<FlankiAnimatedEmoji>(
        find.byType(FlankiAnimatedEmoji),
      );
      expect(flankiEmojiWidget.repeat, isFalse);
    });

    testWidgets('respects MediaQuery.disableAnimations (Reduce Motion)', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ShadcnApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(
              child: FlankiAnimatedEmoji(
                emoji: AnimatedEmojis.trophy,
                size: 32.0,
              ),
            ),
          ),
        ),
      );

      final animatedEmojiFinder = find.byType(AnimatedEmoji);
      expect(animatedEmojiFinder, findsOneWidget);

      final animatedEmojiWidget = tester.widget<AnimatedEmoji>(
        animatedEmojiFinder,
      );
      expect(animatedEmojiWidget.animate, isFalse);
    });

    testWidgets('triggers onTap callback when interactive is true and tapped', (
      tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        ShadcnApp(
          home: Scaffold(
            child: FlankiAnimatedEmoji(
              emoji: AnimatedEmojis.partyPopper,
              size: 64.0,
              interactive: true,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(tapped, isFalse);
      await tester.tap(find.byType(FlankiAnimatedEmoji));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets(
      'DeckEmptyState renders books emoji when showAddButton is true',
      (tester) async {
        await tester.pumpWidget(
          ShadcnApp(
            home: Scaffold(
              child: DeckEmptyState(
                l10n: MockExamL10n(),
                onAddDeck: () {},
                showAddButton: true,
              ),
            ),
          ),
        );

        final emojiFinder = find.byType(FlankiAnimatedEmoji);
        expect(emojiFinder, findsOneWidget);

        final widget = tester.widget<FlankiAnimatedEmoji>(emojiFinder);
        expect(widget.emoji, equals(AnimatedEmojis.books));
        expect(widget.repeat, isTrue);
      },
    );

    testWidgets(
      'DeckEmptyState renders eyes emoji when showAddButton is false',
      (tester) async {
        await tester.pumpWidget(
          ShadcnApp(
            home: Scaffold(
              child: DeckEmptyState(
                l10n: MockExamL10n(),
                onAddDeck: () {},
                showAddButton: false,
              ),
            ),
          ),
        );

        final emojiFinder = find.byType(FlankiAnimatedEmoji);
        expect(emojiFinder, findsOneWidget);

        final widget = tester.widget<FlankiAnimatedEmoji>(emojiFinder);
        expect(widget.emoji, equals(AnimatedEmojis.eyes));
      },
    );

    testWidgets(
      'ExamScoreSummaryCard renders confettiBall when passed and thinkingFace when failed',
      (tester) async {
        final now = DateTime.now();
        final paper = ExamPaperModel(
          id: 'p1',
          title: 'TOEIC Practice Test',
          category: ExamCategory.toeic,
          durationMinutes: 120,
          passingScore: 60,
          totalQuestions: 100,
          createdAt: now,
          updatedAt: now,
        );

        final passedSubmission = ExamSubmissionModel(
          id: 's1',
          examId: 'p1',
          score: 750,
          totalCorrect: 75,
          totalQuestions: 100,
          durationSeconds: 3600,
          answers: const {},
          submittedAt: now,
        );

        await tester.pumpWidget(
          ShadcnApp(
            home: Scaffold(
              child: ExamScoreSummaryCard(
                submission: passedSubmission,
                paper: paper,
                l10n: MockExamL10n(),
              ),
            ),
          ),
        );

        var emojiFinder = find.byType(FlankiAnimatedEmoji);
        expect(emojiFinder, findsOneWidget);
        var emojiWidget = tester.widget<FlankiAnimatedEmoji>(emojiFinder);
        expect(emojiWidget.emoji, equals(AnimatedEmojis.confettiBall));

        final failedSubmission = ExamSubmissionModel(
          id: 's2',
          examId: 'p1',
          score: 450,
          totalCorrect: 45,
          totalQuestions: 100,
          durationSeconds: 3600,
          answers: const {},
          submittedAt: now,
        );

        await tester.pumpWidget(
          ShadcnApp(
            home: Scaffold(
              child: ExamScoreSummaryCard(
                submission: failedSubmission,
                paper: paper,
                l10n: MockExamL10n(),
              ),
            ),
          ),
        );

        emojiFinder = find.byType(FlankiAnimatedEmoji);
        expect(emojiFinder, findsOneWidget);
        emojiWidget = tester.widget<FlankiAnimatedEmoji>(emojiFinder);
        expect(emojiWidget.emoji, equals(AnimatedEmojis.thinkingFace));
      },
    );
  });
}
