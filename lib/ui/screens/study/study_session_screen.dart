import 'dart:math' as math;

import 'package:flutter/material.dart' as m;
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/notifiers/study_session_notifier.dart';
import '../../../core/notifiers/deck_notifier.dart';
import '../../../core/models/card.dart';
import '../../../core/fsrs/fsrs_engine_service.dart';
import '../../../core/fsrs/sm2_engine_service.dart';
import '../../../core/notifiers/settings_notifier.dart';
import '../../../core/localization/locale_notifier.dart';
import '../../../core/services/desktop_update_service.dart';
import 'widgets/scratchpad_overlay.dart';
import 'widgets/card_action_sheet.dart';
import 'widgets/rich_card_content.dart';

class StudySessionScreen extends HookConsumerWidget {
  final String deckId;

  const StudySessionScreen({super.key, required this.deckId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final sessionState = ref.watch(studySessionProvider);
    final sessionNotifier = ref.read(studySessionProvider.notifier);
    final deckNotifier = ref.read(deckListProvider.notifier);
    final studySettings = ref.watch(studySettingsProvider);

    // Initialize deck on enter
    useEffect(() {
      Future.microtask(() {
        sessionNotifier.init(deckId);
      });
      return null;
    }, [deckId]);

    // Hooks: 3D Flip animation controller
    final flipController = useAnimationController(
      duration: const Duration(milliseconds: 300),
    );

    // Swipe horizontal drag offset hook
    final dragOffset = useState<double>(0.0);

    // Scratchpad (Whiteboard) visibility state
    final isWhiteboardOpen = useState<bool>(false);

    // User-typed answer state for interactive cards
    final userTypedAnswer = useState<String>('');

    // Clear typed answer when moving to a new card
    useEffect(() {
      userTypedAnswer.value = '';
      return null;
    }, [sessionState.currentCard?.id]);

    // Sync animation with state
    useEffect(() {
      if (sessionState.isFlipped) {
        flipController.forward();
      } else {
        flipController.reverse();
      }
      return null;
    }, [sessionState.isFlipped]);

    void handleFlip() {
      if (!sessionState.isFlipped) {
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
      final card = sessionState.currentCard;
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

    if (sessionState.deckId != deckId) {
      return const Scaffold(child: Center(child: CircularProgressIndicator()));
    }

    if (sessionState.isFinished) {
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
                  l10n.studyCompleteDesc(sessionState.completedCount),
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
                  onPressed: () => sessionNotifier.restart(),
                  child: Text(l10n.studyAgain),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentCard = sessionState.currentCard;
    final intervals = useMemoized(
      () {
        if (currentCard == null) return <ReviewRating, String>{};
        if (studySettings.fsrsEnabled) {
          final engine = FsrsEngineService(
            desiredRetention: studySettings.desiredRetention,
          );
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
        studySettings.fsrsEnabled,
        studySettings.desiredRetention,
        l10n,
      ],
    );

    final shortcuts = <ShortcutActivator, VoidCallback>{
      const SingleActivator(LogicalKeyboardKey.space): () {
        if (!sessionState.isFlipped) {
          handleFlip();
        } else {
          handleRate(ReviewRating.good);
        }
      },
      const SingleActivator(LogicalKeyboardKey.enter): () {
        if (!sessionState.isFlipped) {
          handleFlip();
        } else {
          handleRate(ReviewRating.good);
        }
      },
      const SingleActivator(LogicalKeyboardKey.digit1): () {
        if (sessionState.isFlipped) handleRate(ReviewRating.again);
      },
      const SingleActivator(LogicalKeyboardKey.numpad1): () {
        if (sessionState.isFlipped) handleRate(ReviewRating.again);
      },
      const SingleActivator(LogicalKeyboardKey.digit2): () {
        if (sessionState.isFlipped) handleRate(ReviewRating.hard);
      },
      const SingleActivator(LogicalKeyboardKey.numpad2): () {
        if (sessionState.isFlipped) handleRate(ReviewRating.hard);
      },
      const SingleActivator(LogicalKeyboardKey.digit3): () {
        if (sessionState.isFlipped) handleRate(ReviewRating.good);
      },
      const SingleActivator(LogicalKeyboardKey.numpad3): () {
        if (sessionState.isFlipped) handleRate(ReviewRating.good);
      },
      const SingleActivator(LogicalKeyboardKey.digit4): () {
        if (sessionState.isFlipped) handleRate(ReviewRating.easy);
      },
      const SingleActivator(LogicalKeyboardKey.numpad4): () {
        if (sessionState.isFlipped) handleRate(ReviewRating.easy);
      },
      const SingleActivator(LogicalKeyboardKey.keyZ, control: true): () {
        if (sessionState.canUndo) handleUndo();
      },
      const SingleActivator(LogicalKeyboardKey.keyZ): () {
        if (sessionState.canUndo) handleUndo();
      },
      const SingleActivator(LogicalKeyboardKey.escape): () {
        context.pop();
      },
    };

    return CallbackShortcuts(
      bindings: shortcuts,
      child: Focus(
        autofocus: true,
        child: Scaffold(
          headers: [
            AppBar(
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
                    l10n.cardsRemaining(
                      sessionState.queue.length + (currentCard != null ? 1 : 0),
                    ),
                    style: theme.typography.small.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
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
                // Undo button
                if (sessionState.canUndo)
                  IconButton.ghost(
                    icon: const Icon(LucideIcons.undo2, size: 20),
                    onPressed: handleUndo,
                  ),

                // Whiteboard / Scratchpad toggle
                IconButton.ghost(
                  icon: Icon(
                    LucideIcons.pencil,
                    size: 20,
                    color: isWhiteboardOpen.value
                        ? theme.colorScheme.primary
                        : null,
                  ),
                  onPressed: () {
                    isWhiteboardOpen.value = !isWhiteboardOpen.value;
                  },
                ),

                // Card Actions (Flag, Bury, Suspend, Edit)
                IconButton.ghost(
                  icon: const Icon(LucideIcons.ellipsisVertical, size: 20),
                  onPressed: openCardActions,
                ),
              ],
            ),
          ],
          child: Stack(
            children: [
              Column(
                children: [
                  // Top slim progress bar
                  Progress(progress: sessionState.progress),

                  // Main Card Container with 3D Flip & Horizontal Gesture
                  Expanded(
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        if (sessionState.isFlipped && !isWhiteboardOpen.value) {
                          dragOffset.value += details.primaryDelta ?? 0;
                        }
                      },
                      onHorizontalDragEnd: (details) {
                        if (sessionState.isFlipped && !isWhiteboardOpen.value) {
                          if (dragOffset.value < -80) {
                            handleRate(ReviewRating.again);
                          } else if (dragOffset.value > 80) {
                            handleRate(ReviewRating.good);
                          } else {
                            dragOffset.value = 0.0;
                          }
                        }
                      },
                      child: AnimatedBuilder(
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                child: SizedBox.expand(
                                  child: Transform(
                                    alignment: Alignment.center,
                                    transform: matrix,
                                    child: isUnder
                                        ? Transform(
                                            alignment: Alignment.center,
                                            transform: Matrix4.identity()
                                              ..rotateY(math.pi),
                                            child: _CardBackView(
                                              card: currentCard,
                                              theme: theme,
                                              typedAnswer:
                                                  userTypedAnswer.value,
                                            ),
                                          )
                                        : _CardFrontView(
                                            card: currentCard,
                                            theme: theme,
                                            typedAnswer: userTypedAnswer.value,
                                            onAnswerChanged: (v) =>
                                                userTypedAnswer.value = v,
                                            onSubmitAnswer: handleFlip,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Bottom Action Area
                  SafeArea(
                    top: false,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: sessionState.isFlipped
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: _RatingButton(
                                        label: l10n.ratingAgain,
                                        shortcutHint: '1',
                                        interval:
                                            intervals[ReviewRating.again] ??
                                            '< ${l10n.intervalMinutes(10)}',
                                        backgroundColor: m.Colors.red.shade600,
                                        onTap: () =>
                                            handleRate(ReviewRating.again),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _RatingButton(
                                        label: l10n.ratingHard,
                                        shortcutHint: '2',
                                        interval:
                                            intervals[ReviewRating.hard] ??
                                            l10n.intervalDays(1),
                                        backgroundColor:
                                            m.Colors.orange.shade700,
                                        onTap: () =>
                                            handleRate(ReviewRating.hard),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _RatingButton(
                                        label: l10n.ratingGood,
                                        shortcutHint: '3',
                                        interval:
                                            intervals[ReviewRating.good] ??
                                            l10n.intervalDays(4),
                                        backgroundColor: m.Colors.blue.shade600,
                                        onTap: () =>
                                            handleRate(ReviewRating.good),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _RatingButton(
                                        label: l10n.ratingEasy,
                                        shortcutHint: '4',
                                        interval:
                                            intervals[ReviewRating.easy] ??
                                            l10n.intervalDays(12),
                                        backgroundColor:
                                            m.Colors.green.shade600,
                                        onTap: () =>
                                            handleRate(ReviewRating.easy),
                                      ),
                                    ),
                                  ],
                                )
                              : SizedBox(
                                  width: double.infinity,
                                  child: PrimaryButton(
                                    alignment: Alignment.center,
                                    onPressed: handleFlip,
                                    child: Text(
                                      DesktopUpdateService.isDesktop
                                          ? '${l10n.tapToFlip}  [Space]'
                                          : l10n.tapToFlip,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Whiteboard (Scratchpad) overlay if enabled
              if (isWhiteboardOpen.value)
                ScratchpadOverlay(
                  onClose: () => isWhiteboardOpen.value = false,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardFrontView extends StatelessWidget {
  final CardModel? card;
  final ThemeData theme;
  final String? typedAnswer;
  final ValueChanged<String>? onAnswerChanged;
  final VoidCallback? onSubmitAnswer;

  const _CardFrontView({
    required this.card,
    required this.theme,
    this.typedAnswer,
    this.onAnswerChanged,
    this.onSubmitAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.zero,
      child: SizedBox.expand(
        child: ClipRRect(
          borderRadius: theme.borderRadiusLg,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                clipBehavior: Clip.antiAlias,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: math.max(0.0, constraints.maxHeight - 40),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.muted,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              l10n.studyQuestion,
                              style: theme.typography.xSmall.copyWith(
                                color: theme.colorScheme.mutedForeground,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                          if (card != null && card!.hasFlag) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color:
                                    CardActionSheet.ankiFlagColors[card!
                                        .flag] ??
                                    m.Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 18),
                      RichCardContent(
                        content: card?.front ?? '',
                        autoPlayAudio: true,
                        typedAnswer: typedAnswer,
                        onAnswerChanged: onAnswerChanged,
                        onSubmitAnswer: onSubmitAnswer,
                        textStyle: theme.typography.h2.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CardBackView extends StatelessWidget {
  final CardModel? card;
  final ThemeData theme;
  final String? typedAnswer;

  const _CardBackView({
    required this.card,
    required this.theme,
    this.typedAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.zero,
      child: SizedBox.expand(
        child: ClipRRect(
          borderRadius: theme.borderRadiusLg,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                clipBehavior: Clip.antiAlias,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: math.max(0.0, constraints.maxHeight - 40),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          l10n.studyAnswer,
                          style: theme.typography.xSmall.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      RichCardContent(
                        content: card?.back ?? '',
                        autoPlayAudio: true,
                        typedAnswer: typedAnswer,
                        textStyle: theme.typography.h3.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RatingButton extends HookWidget {
  final String label;
  final String interval;
  final String? shortcutHint;
  final m.Color backgroundColor;
  final VoidCallback onTap;

  const _RatingButton({
    required this.label,
    required this.interval,
    this.shortcutHint,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPressed = useState(false);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => isPressed.value = true,
        onTapUp: (_) => isPressed.value = false,
        onTapCancel: () => isPressed.value = false,
        onTap: onTap,
        child: AnimatedScale(
          scale: isPressed.value ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutCubic,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: m.Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (shortcutHint != null) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: m.Colors.black.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          shortcutHint!,
                          style: const TextStyle(
                            color: m.Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  interval,
                  style: TextStyle(
                    color: m.Colors.white.withValues(alpha: 0.85),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
