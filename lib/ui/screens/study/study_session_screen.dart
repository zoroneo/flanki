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
import 'widgets/scratchpad_overlay.dart';
import 'widgets/card_action_sheet.dart';

class StudySessionScreen extends HookConsumerWidget {
  final String deckId;

  const StudySessionScreen({
    super.key,
    required this.deckId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sessionState = ref.watch(studySessionProvider);
    final sessionNotifier = ref.read(studySessionProvider.notifier);
    final deckNotifier = ref.read(deckListProvider.notifier);

    // Initialize deck on enter
    useEffect(() {
      sessionNotifier.init(deckId);
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

    void handleRate(int rating) {
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
                title: const Text('Đã hoàn tác'),
                subtitle: const Text('Khôi phục thẻ vừa đánh giá.'),
                leading: const Icon(m.Icons.undo_rounded, size: 18),
                trailing: IconButton.ghost(
                  icon: const Icon(m.Icons.close),
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

      m.showModalBottomSheet(
        context: context,
        backgroundColor: m.Colors.transparent,
        isScrollControlled: true,
        builder: (ctx) {
          return m.Material(
            type: m.MaterialType.transparency,
            child: CardActionSheet(
              card: card,
              onSetFlag: (flagColor) => sessionNotifier.toggleFlag(flagColor),
              onBury: () => sessionNotifier.buryCurrentCard(),
              onSuspend: () => sessionNotifier.suspendCurrentCard(),
              onEdit: (f, b) => sessionNotifier.editCurrentCard(f, b),
            ),
          );
        },
      );
    }

    if (sessionState.isFinished) {
      return Scaffold(
        headers: [
          AppBar(
            leading: [
              IconButton.ghost(
                icon: const Icon(m.Icons.close_rounded),
                onPressed: () => context.pop(),
              ),
            ],
            title: const Text('Hoàn thành'),
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
                    m.Icons.check_circle_rounded,
                    size: 64,
                    color: m.Colors.green,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Tuyệt vời! Bạn đã hoàn thành',
                  style: theme.typography.h2.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Đã hoàn thành ${sessionState.completedCount} thẻ trong phiên học này với thuật toán FSRS.',
                  style: theme.typography.small.copyWith(color: theme.colorScheme.mutedForeground),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  onPressed: () => context.pop(),
                  child: const Text('Quay lại danh sách bộ thẻ'),
                ),
                const SizedBox(height: 12),
                GhostButton(
                  onPressed: () => sessionNotifier.restart(),
                  child: const Text('Ôn lại lần nữa'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentCard = sessionState.currentCard;
    final fsrsService = useMemoized(() => FsrsEngineService());
    final intervals = useMemoized(() {
      if (currentCard == null) return <int, String>{};
      return fsrsService.previewIntervals(currentCard);
    }, [currentCard?.id, currentCard?.stability, currentCard?.difficulty, currentCard?.reps]);

    return Scaffold(
      headers: [
        AppBar(
          leading: [
            IconButton.ghost(
              icon: const Icon(m.Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () => context.pop(),
            ),
          ],
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Thẻ còn lại: ${sessionState.queue.length + (currentCard != null ? 1 : 0)}',
                style: theme.typography.small.copyWith(fontWeight: FontWeight.w600),
              ),
              if (currentCard != null && currentCard.hasFlag) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: CardActionSheet.ankiFlagColors[currentCard.flag - 1],
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
                icon: const Icon(m.Icons.undo_rounded, size: 20),
                onPressed: handleUndo,
              ),

            // Whiteboard / Scratchpad toggle
            IconButton.ghost(
              icon: Icon(
                isWhiteboardOpen.value
                    ? m.Icons.draw_rounded
                    : m.Icons.draw_outlined,
                size: 20,
                color: isWhiteboardOpen.value ? theme.colorScheme.primary : null,
              ),
              onPressed: () {
                isWhiteboardOpen.value = !isWhiteboardOpen.value;
              },
            ),

            // Card Actions (Flag, Bury, Suspend, Edit)
            IconButton.ghost(
              icon: const Icon(m.Icons.more_vert_rounded, size: 20),
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
              Progress(
                progress: sessionState.progress,
              ),

              // Main Card Container with 3D Flip & Horizontal Gesture
              Expanded(
                child: GestureDetector(
                  onTap: handleFlip,
                  onHorizontalDragUpdate: (details) {
                    if (sessionState.isFlipped && !isWhiteboardOpen.value) {
                      dragOffset.value += details.primaryDelta ?? 0;
                    }
                  },
                  onHorizontalDragEnd: (details) {
                    if (sessionState.isFlipped && !isWhiteboardOpen.value) {
                      if (dragOffset.value < -80) {
                        handleRate(1);
                      } else if (dragOffset.value > 80) {
                        handleRate(3);
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Transform(
                            alignment: Alignment.center,
                            transform: matrix,
                            child: isUnder
                                ? Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()..rotateY(math.pi),
                                    child: _CardBackView(
                                      card: currentCard,
                                      theme: theme,
                                    ),
                                  )
                                : _CardFrontView(
                                    card: currentCard,
                                    theme: theme,
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: sessionState.isFlipped
                      ? Row(
                          children: [
                            Expanded(
                              child: _RatingButton(
                                label: 'Again',
                                interval: intervals[1] ?? '< 10p',
                                backgroundColor: m.Colors.red.shade600,
                                onTap: () => handleRate(1),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _RatingButton(
                                label: 'Hard',
                                interval: intervals[2] ?? '1 ngày',
                                backgroundColor: m.Colors.orange.shade700,
                                onTap: () => handleRate(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _RatingButton(
                                label: 'Good',
                                interval: intervals[3] ?? '4 ngày',
                                backgroundColor: m.Colors.blue.shade600,
                                onTap: () => handleRate(3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _RatingButton(
                                label: 'Easy',
                                interval: intervals[4] ?? '12 ngày',
                                backgroundColor: m.Colors.green.shade600,
                                onTap: () => handleRate(4),
                              ),
                            ),
                          ],
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            onPressed: handleFlip,
                            child: const Text('Chạm để lật thẻ (Lật đáp án)'),
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
    );
  }
}

class _CardFrontView extends StatelessWidget {
  final CardModel? card;
  final ThemeData theme;

  const _CardFrontView({required this.card, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      padding: const EdgeInsets.all(28),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.muted,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'CÂU HỎI',
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
                      color: CardActionSheet.ankiFlagColors[card!.flag - 1],
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 36),
            Text(
              card?.front ?? '',
              style: theme.typography.h2.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            Text(
              'Chạm vào màn hình để lật thẻ',
              style: theme.typography.xSmall.copyWith(
                color: theme.colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardBackView extends StatelessWidget {
  final CardModel? card;
  final ThemeData theme;

  const _CardBackView({required this.card, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      padding: const EdgeInsets.all(28),
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'ĐÁP ÁN',
                  style: theme.typography.xSmall.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                card?.front ?? '',
                style: theme.typography.lead.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                card?.back ?? '',
                style: theme.typography.h3.copyWith(fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Text(
                'Vuốt trái: Again • Vuốt phải: Good',
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RatingButton extends StatelessWidget {
  final String label;
  final String interval;
  final m.Color backgroundColor;
  final VoidCallback onTap;

  const _RatingButton({
    required this.label,
    required this.interval,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: m.Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              interval,
              style: TextStyle(
                color: m.Colors.white.withValues(alpha: 0.8),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
