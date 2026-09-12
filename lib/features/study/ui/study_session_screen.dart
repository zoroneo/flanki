import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/fsrs/fsrs_engine_service.dart';
import '../../../core/fsrs/sm2_engine_service.dart';
import '../../../core/notifiers/locale_notifier.dart';
import '../../../core/models/card.dart';
import 'package:flanki/features/decks/providers/deck_notifier.dart';
import '../../settings/providers/settings_notifier.dart';
import '../providers/study_session_notifier.dart';
import '../../sync/ui/sync_flow_coordinator.dart';
import 'widgets/card_action_sheet.dart';
import 'widgets/scratchpad_overlay.dart';
import 'widgets/study_app_bar.dart';
import 'widgets/study_bottom_action_area.dart';
import 'widgets/study_card_flipper.dart';
import 'widgets/study_finished_view.dart';

class StudySessionScreen extends HookConsumerWidget {
  final String deckId;

  const StudySessionScreen({super.key, required this.deckId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      return StudyFinishedView(
        l10n: l10n,
        notifier: sessionNotifier,
        completedCount: completedCount,
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
                StudyAppBar(
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
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: progress),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        builder: (context, animatedProgress, _) {
                          return Progress(progress: animatedProgress);
                        },
                      ),
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
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: Tween<double>(
                                    begin: 0.95,
                                    end: 1.0,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: KeyedSubtree(
                              key: ValueKey(currentCard?.id ?? 'none'),
                              child: StudyCardFlipper(
                                flipController: flipController,
                                currentCard: currentCard,
                                typedAnswer: userTypedAnswer.value,
                                onAnswerChanged: (v) =>
                                    userTypedAnswer.value = v,
                                onSubmitAnswer: handleFlip,
                                cardHorizontalPadding: cardPadding,
                                dragOffset: dragOffset.value,
                              ),
                            ),
                          ),
                        ),
                      ),
                      StudyBottomActionArea(
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
}
