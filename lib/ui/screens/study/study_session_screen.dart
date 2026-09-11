import 'dart:math' as math;

import 'package:flutter/material.dart' as m;
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/fsrs/fsrs_engine_service.dart';
import '../../../core/fsrs/sm2_engine_service.dart';
import '../../../core/localization/locale_notifier.dart';
import '../../../core/models/card.dart';
import '../../../core/notifiers/deck_notifier.dart';
import '../../../core/notifiers/settings_notifier.dart';
import '../../../core/notifiers/study_session_notifier.dart';
import '../../widgets/sync_flow_coordinator.dart';
import 'widgets/card_action_sheet.dart';
import 'widgets/scratchpad_overlay.dart';
import 'widgets/study_card_views.dart';
import 'widgets/study_rating_bar.dart';

class StudySessionScreen extends HookConsumerWidget {
  final String deckId;

  const StudySessionScreen({super.key, required this.deckId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final currentDeckId = ref.watch(
      studySessionProvider.select((s) => s.deckId),
    );
    final isFinished = ref.watch(
      studySessionProvider.select((s) => s.isFinished),
    );
    final completedCount = ref.watch(
      studySessionProvider.select((s) => s.completedCount),
    );
    final currentCard = ref.watch(
      studySessionProvider.select((s) => s.currentCard),
    );
    final isFlipped = ref.watch(
      studySessionProvider.select((s) => s.isFlipped),
    );
    final canUndo = ref.watch(studySessionProvider.select((s) => s.canUndo));
    final progress = ref.watch(studySessionProvider.select((s) => s.progress));
    final remainingCount = ref.watch(
      studySessionProvider.select(
        (s) => s.queue.length + (s.currentCard != null ? 1 : 0),
      ),
    );
    final sessionNotifier = ref.read(studySessionProvider.notifier);
    final deckNotifier = ref.read(deckListProvider.notifier);
    final (fsrsEnabled, desiredRetention) = ref.watch(
      studySettingsProvider.select((s) => (s.fsrsEnabled, s.desiredRetention)),
    );

    useEffect(() {
      Future.microtask(() => sessionNotifier.init(deckId));
      return null;
    }, [deckId]);

    final flipController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );
    final dragOffset = useState<double>(0.0);
    final isWhiteboardOpen = useState<bool>(false);
    final userTypedAnswer = useState<String>('');

    useEffect(() {
      userTypedAnswer.value = '';
      return null;
    }, [currentCard?.id]);

    useEffect(() {
      if (isFlipped) {
        flipController.forward();
      } else {
        flipController.reverse();
      }
      return null;
    }, [isFlipped]);

    useEffect(() {
      if (isFinished && completedCount > 0) {
        Future.microtask(() {
          if (!context.mounted) return;
          SyncFlowCoordinator.runAutoSync(
            context: context,
            ref: ref,
            l10n: l10n,
          );
        });
      }
      return null;
    }, [isFinished]);

    void handleFlip() {
      if (!isFlipped) {
        HapticFeedback.lightImpact();
        sessionNotifier.flip();
      }
    }

    void handleRate(ReviewRating rating) {
      HapticFeedback.mediumImpact();
      deckNotifier.recordStudyProgress(deckId);
      dragOffset.value = 0.0;
      sessionNotifier.rateCard(rating);
    }

    void handleUndo() {
      HapticFeedback.mediumImpact();
      final success = sessionNotifier.undo();
      if (success) {
        showToast(
          context: context,
          builder: (context, overlay) {
            return SurfaceCard(
              child: Basic(
                title: Text(l10n.undoSuccessTitle),
                subtitle: Text(l10n.undoSuccessDesc),
                leading: const Icon(LucideIcons.undo2, size: 18),
                trailing: IconButton.ghost(
                  icon: const Icon(LucideIcons.x),
                  onPressed: () => overlay.close(),
                ),
              ),
            );
          },
        );
      }
    }

    void openCardActions() {
      final card = currentCard;
      if (card == null) return;

      CardActionSheet.show(
        context,
        card: card,
        onSetFlag: (flagColor) => sessionNotifier.toggleFlag(flagColor),
        onBury: () => sessionNotifier.buryCurrentCard(),
        onSuspend: () => sessionNotifier.suspendCurrentCard(),
        onEdit: (f, b) => sessionNotifier.editCurrentCard(f, b),
        onDelete: () => sessionNotifier.deleteCurrentCard(),
      );
    }

    if (currentDeckId != deckId) {
      return const Scaffold(child: Center(child: CircularProgressIndicator()));
    }

    if (isFinished) {
      return _buildFinishedState(
        context,
        l10n,
        theme,
        sessionNotifier,
        completedCount,
      );
    }

    final intervals = useMemoized(
      () {
        if (currentCard == null) return <ReviewRating, String>{};
        if (fsrsEnabled) {
          final engine = FsrsEngineService(desiredRetention: desiredRetention);
          return engine.previewIntervals(currentCard, l10n: l10n);
        } else {
          const engine = Sm2EngineService();
          return engine.previewIntervals(currentCard, l10n: l10n);
        }
      },
      [
        currentCard?.id,
        currentCard?.stability,
        currentCard?.difficulty,
        currentCard?.reps,
        currentCard?.intervalDays,
        fsrsEnabled,
        desiredRetention,
        l10n,
      ],
    );

    final shortcuts = <ShortcutActivator, VoidCallback>{
      const SingleActivator(LogicalKeyboardKey.space): () {
        isFlipped ? handleRate(ReviewRating.good) : handleFlip();
      },
      const SingleActivator(LogicalKeyboardKey.enter): () {
        isFlipped ? handleRate(ReviewRating.good) : handleFlip();
      },
      const SingleActivator(LogicalKeyboardKey.digit1): () {
        if (isFlipped) handleRate(ReviewRating.again);
      },
      const SingleActivator(LogicalKeyboardKey.numpad1): () {
        if (isFlipped) handleRate(ReviewRating.again);
      },
      const SingleActivator(LogicalKeyboardKey.digit2): () {
        if (isFlipped) handleRate(ReviewRating.hard);
      },
      const SingleActivator(LogicalKeyboardKey.numpad2): () {
        if (isFlipped) handleRate(ReviewRating.hard);
      },
      const SingleActivator(LogicalKeyboardKey.digit3): () {
        if (isFlipped) handleRate(ReviewRating.good);
      },
      const SingleActivator(LogicalKeyboardKey.numpad3): () {
        if (isFlipped) handleRate(ReviewRating.good);
      },
      const SingleActivator(LogicalKeyboardKey.digit4): () {
        if (isFlipped) handleRate(ReviewRating.easy);
      },
      const SingleActivator(LogicalKeyboardKey.numpad4): () {
        if (isFlipped) handleRate(ReviewRating.easy);
      },
      const SingleActivator(LogicalKeyboardKey.keyZ, control: true): () {
        if (canUndo) handleUndo();
      },
      const SingleActivator(LogicalKeyboardKey.keyZ): () {
        if (canUndo) handleUndo();
      },
      const SingleActivator(LogicalKeyboardKey.escape): () => context.pop(),
    };

    return CallbackShortcuts(
      bindings: shortcuts,
      child: Focus(
        autofocus: true,
        child: ResponsiveBuilder(
          builder: (context, sizingInfo) {
            final isMobile =
                sizingInfo.deviceScreenType == DeviceScreenType.mobile;
            final cardPadding = getValueForScreenType<double>(
              context: context,
              mobile: 16.0,
              tablet: 20.0,
              desktop: 24.0,
            );
            final bottomPadding = getValueForScreenType<double>(
              context: context,
              mobile: 16.0,
              tablet: 20.0,
              desktop: 24.0,
            );

            return Scaffold(
              headers: [
                _buildAppBar(
                  context: context,
                  theme: theme,
                  l10n: l10n,
                  currentCard: currentCard,
                  remainingCount: remainingCount,
                  canUndo: canUndo,
                  isWhiteboardOpen: isWhiteboardOpen.value,
                  onUndo: handleUndo,
                  onToggleWhiteboard: () =>
                      isWhiteboardOpen.value = !isWhiteboardOpen.value,
                  onOpenActions: openCardActions,
                ),
              ],
              child: Stack(
                children: [
                  Column(
                    children: [
                      Progress(progress: progress),
                      Expanded(
                        child: GestureDetector(
                          onHorizontalDragUpdate: (details) {
                            if (isFlipped && !isWhiteboardOpen.value) {
                              dragOffset.value += details.primaryDelta ?? 0;
                            }
                          },
                          onHorizontalDragEnd: (details) {
                            if (isFlipped && !isWhiteboardOpen.value) {
                              if (dragOffset.value < -80) {
                                handleRate(ReviewRating.again);
                              } else if (dragOffset.value > 80) {
                                handleRate(ReviewRating.good);
                              } else {
                                dragOffset.value = 0.0;
                              }
                            }
                          },
                          child: _buildCardFlipper(
                            flipController: flipController,
                            currentCard: currentCard,
                            theme: theme,
                            typedAnswer: userTypedAnswer.value,
                            onAnswerChanged: (v) => userTypedAnswer.value = v,
                            onSubmitAnswer: handleFlip,
                            cardHorizontalPadding: cardPadding,
                          ),
                        ),
                      ),
                      _buildBottomActionArea(
                        isFlipped: isFlipped,
                        isMobile: isMobile,
                        intervals: intervals,
                        onRate: handleRate,
                        onFlip: handleFlip,
                        bottomHorizontalPadding: bottomPadding,
                        l10n: l10n,
                      ),
                    ],
                  ),
                  if (isWhiteboardOpen.value)
                    ScratchpadOverlay(
                      onClose: () => isWhiteboardOpen.value = false,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFinishedState(
    BuildContext context,
    dynamic l10n,
    ThemeData theme,
    StudySessionNotifier notifier,
    int completedCount,
  ) {
    return Scaffold(
      headers: [
        AppBar(
          leading: [
            IconButton.ghost(
              icon: const Icon(LucideIcons.x),
              onPressed: () => context.pop(),
            ),
          ],
          title: Text(l10n.studyCompleteTitle),
        ),
      ],
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: m.Colors.green.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.checkCheck,
                  size: 64,
                  color: m.Colors.green,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.studyCompleteTitle,
                style: theme.typography.h2.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.studyCompleteDesc(completedCount),
                style: theme.typography.small.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                alignment: Alignment.center,
                onPressed: () => context.pop(),
                child: Text(l10n.backToDecks),
              ),
              const SizedBox(height: 12),
              GhostButton(
                onPressed: () => notifier.restart(),
                child: Text(l10n.studyAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar({
    required BuildContext context,
    required ThemeData theme,
    required dynamic l10n,
    required CardModel? currentCard,
    required int remainingCount,
    required bool canUndo,
    required bool isWhiteboardOpen,
    required VoidCallback onUndo,
    required VoidCallback onToggleWhiteboard,
    required VoidCallback onOpenActions,
  }) {
    return AppBar(
      leading: [
        IconButton.ghost(
          icon: const Icon(LucideIcons.chevronLeft, size: 18),
          onPressed: () => context.pop(),
        ),
      ],
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.cardsRemaining(remainingCount),
            style: theme.typography.small.copyWith(fontWeight: FontWeight.w600),
          ),
          if (currentCard != null && currentCard.hasFlag) ...[
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color:
                    CardActionSheet.ankiFlagColors[currentCard.flag] ??
                    m.Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
      trailing: [
        if (canUndo)
          IconButton.ghost(
            icon: const Icon(LucideIcons.undo2, size: 20),
            onPressed: onUndo,
          ),
        IconButton.ghost(
          icon: Icon(
            LucideIcons.pencil,
            size: 20,
            color: isWhiteboardOpen ? theme.colorScheme.primary : null,
          ),
          onPressed: onToggleWhiteboard,
        ),
        IconButton.ghost(
          icon: const Icon(LucideIcons.ellipsisVertical, size: 20),
          onPressed: onOpenActions,
        ),
      ],
    );
  }

  Widget _buildCardFlipper({
    required AnimationController flipController,
    required CardModel? currentCard,
    required ThemeData theme,
    required String typedAnswer,
    required ValueChanged<String> onAnswerChanged,
    required VoidCallback onSubmitAnswer,
    required double cardHorizontalPadding,
  }) {
    return AnimatedBuilder(
      animation: flipController,
      builder: (context, child) {
        final angle = flipController.value * math.pi;
        final isUnder = angle > (math.pi / 2);
        final matrix = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(angle);

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: cardHorizontalPadding,
                vertical: 12,
              ),
              child: SizedBox.expand(
                child: Transform(
                  alignment: Alignment.center,
                  transform: matrix,
                  child: isUnder
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(math.pi),
                          child: CardBackView(
                            card: currentCard,
                            theme: theme,
                            typedAnswer: typedAnswer,
                          ),
                        )
                      : CardFrontView(
                          card: currentCard,
                          theme: theme,
                          typedAnswer: typedAnswer,
                          onAnswerChanged: onAnswerChanged,
                          onSubmitAnswer: onSubmitAnswer,
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomActionArea({
    required bool isFlipped,
    required bool isMobile,
    required Map<ReviewRating, String> intervals,
    required ValueChanged<ReviewRating> onRate,
    required VoidCallback onFlip,
    required double bottomHorizontalPadding,
    required dynamic l10n,
  }) {
    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: bottomHorizontalPadding,
              vertical: 12,
            ),
            child: isFlipped
                ? StudyRatingBar(
                    intervals: intervals,
                    isMobile: isMobile,
                    onRate: onRate,
                  )
                : SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      alignment: Alignment.center,
                      onPressed: onFlip,
                      child: Text(
                        !isMobile
                            ? '${l10n.tapToFlip}  [Space]'
                            : l10n.tapToFlip,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
