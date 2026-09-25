import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/extensions/responsive_extensions.dart';
import '../../../core/fsrs/fsrs_engine_service.dart';
import '../../../core/fsrs/sm2_engine_service.dart';
import '../../../core/models/card.dart';
import '../../../core/services/card_audio_service.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/config/settings_notifier.dart';
import '../../../core/database/database_service.dart';
import '../providers/study_session_notifier.dart';
import 'widgets/card_action_sheet.dart';
import 'widgets/scratchpad_overlay.dart';
import 'widgets/study_app_bar.dart';
import 'widgets/study_bottom_action_area.dart';
import 'widgets/study_card_gesture_area.dart';
import 'widgets/study_finished_view.dart';
import 'widgets/study_shortcuts.dart';

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
    final (fsrsEnabled, desiredRetention) = ref.watch(
      studySettingsProvider.select((s) => (s.fsrsEnabled, s.desiredRetention)),
    );

    useEffect(() {
      Future.microtask(() => sessionNotifier.init(deckId));
      return () {
        CardAudioService.instance.stop();
      };
    }, [deckId]);

    final flipController = useAnimationController(
      duration: AppDurations.medium,
    );
    final dragOffset = useState<double>(0.0);
    final isWhiteboardOpen = useState<bool>(false);
    final userTypedAnswer = useRef<String>('');
    final quickFocusTagOffset = useState<Offset?>(null);

    useEffect(() {
      userTypedAnswer.value = '';
      flipController.value = 0.0;
      CardAudioService.instance.stop();
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

    void handleFlip() {
      if (!isFlipped) {
        HapticFeedback.lightImpact();
        sessionNotifier.flip();
      }
    }

    void handleRate(ReviewRating rating) {
      HapticFeedback.mediumImpact();
      DatabaseService.instance.recordDeckStudyProgress(deckId);
      dragOffset.value = 0.0;
      CardAudioService.instance.stop();
      flipController.value = 0.0;
      sessionNotifier.rateCard(rating);
    }

    void handleUndo() {
      HapticFeedback.mediumImpact();
      CardAudioService.instance.stop();
      flipController.value = 0.0;
      final success = sessionNotifier.undo();
      if (success) {
        showToast(
          context: context,
          builder: (context, overlay) {
            return SurfaceCard(
              child: Basic(
                title: Text(l10n.undoSuccessTitle),
                subtitle: Text(l10n.undoSuccessDesc),
                leading: const Icon(LucideIcons.undo2, size: AppIconSize.md),
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

    final shortcuts = buildStudyShortcuts(
      isFlipped: isFlipped,
      canUndo: canUndo,
      onFlip: handleFlip,
      onRate: handleRate,
      onUndo: handleUndo,
      onEscape: () => context.pop(),
    );

    final isMobile = context.isMobile;
    final cardPadding = switch (context.deviceScreenType) {
      DeviceScreenType.mobile => AppSpacing.pageMobile,
      DeviceScreenType.tablet => AppSpacing.pageTablet,
      _ => AppSpacing.pageDesktop,
    };
    final bottomPadding = switch (context.deviceScreenType) {
      DeviceScreenType.mobile => AppSpacing.pageMobile,
      DeviceScreenType.tablet => AppSpacing.pageTablet,
      _ => AppSpacing.pageDesktop,
    };

    return CallbackShortcuts(
      bindings: shortcuts,
      child: Focus(
        autofocus: true,
        child: Scaffold(
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
                    duration: AppDurations.medium,
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedProgress, _) {
                      return Progress(progress: animatedProgress);
                    },
                  ),
                  Expanded(
                    child: StudyCardGestureArea(
                      currentCard: currentCard,
                      isFlipped: isFlipped,
                      isWhiteboardOpen: isWhiteboardOpen.value,
                      flipController: flipController,
                      typedAnswer: userTypedAnswer.value,
                      onAnswerChanged: (v) => userTypedAnswer.value = v,
                      onSubmitAnswer: handleFlip,
                      cardHorizontalPadding: cardPadding,
                      dragOffset: dragOffset.value,
                      onDragOffsetDelta: (delta) => dragOffset.value += delta,
                      onDragOffsetReset: (val) => dragOffset.value = val,
                      onSwipeRate: handleRate,
                      quickFocusTagOffset: quickFocusTagOffset.value,
                      onQuickFocusTagOffsetChanged: (offset) =>
                          quickFocusTagOffset.value = offset,
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
        ),
      ),
    );
  }
}
