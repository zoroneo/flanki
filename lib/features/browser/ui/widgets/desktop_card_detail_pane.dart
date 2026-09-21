import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/localization/locale_notifier.dart';
import '../../../../core/models/card.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../providers/card_browser_notifier.dart';

import 'package:flanki/core/widgets/rich_card_content.dart';

class DesktopCardDetailPane extends HookWidget {
  final CardModel card;
  final String? deckTitle;
  final CardBrowserNotifier browserNotifier;

  const DesktopCardDetailPane({
    super.key,
    required this.card,
    this.deckTitle,
    required this.browserNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final showAnswer = useState(false);
    final userTypedAnswer = useState('');

    useEffect(() {
      showAnswer.value = false;
      userTypedAnswer.value = '';
      return null;
    }, [card.id]);

    return Column(
      children: [
        _buildTopActionBar(context, theme, l10n),
        Expanded(
          child: SingleChildScrollView(
            padding: AppEdgeInsets.all24,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildFrontSection(
                      theme,
                      l10n,
                      showAnswer,
                      userTypedAnswer,
                    ),
                    if (showAnswer.value) ...[
                      AppGaps.v20,
                      _buildBackSection(theme, l10n, userTypedAnswer),
                    ],
                    AppGaps.v24,
                    _buildFsrsMetricsGrid(theme, l10n),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopActionBar(
    BuildContext context,
    ThemeData theme,
    dynamic l10n,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.smPlus,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(bottom: BorderSide(color: theme.colorScheme.border)),
      ),
      child: Row(
        children: [
          Container(
            padding: AppEdgeInsets.h8v4,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: AppRadius.borderSm,
            ),
            child: Text(
              deckTitle ?? card.deckId,
              style: context.textStyles.xSmallSemiBold.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          AppGaps.h8,
          if (card.noteType == NoteType.cloze)
            Container(
              padding: AppEdgeInsets.h8v4,
              decoration: BoxDecoration(
                color: theme.colorScheme.muted,
                borderRadius: AppRadius.borderSm,
              ),
              child: Text(
                l10n.clozeDeletion,
                style: context.textStyles.xSmallSemiBold,
              ),
            ),
          const Spacer(),
          OutlineButton(
            size: ButtonSize.small,
            leading: Icon(
              card.isSuspended ? LucideIcons.play : LucideIcons.pause,
              size: AppIconSize.sm,
            ),
            child: Text(
              card.isSuspended ? l10n.unsuspendCard : l10n.suspendCard,
            ),
            onPressed: () => browserNotifier.toggleCardSuspend(card.id),
          ),
          AppGaps.h8,
          DestructiveButton(
            size: ButtonSize.small,
            leading: const Icon(LucideIcons.trash2, size: AppIconSize.sm),
            child: Text(l10n.delete),
            onPressed: () => browserNotifier.deleteCard(card.id),
          ),
        ],
      ),
    );
  }

  Widget _buildFrontSection(
    ThemeData theme,
    dynamic l10n,
    ValueNotifier<bool> showAnswer,
    ValueNotifier<String> userTypedAnswer,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(LucideIcons.fileQuestion, size: AppIconSize.sm),
            AppGaps.h8,
            Text(
              l10n.frontSide,
              style: theme.typography.xSmall.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: theme.colorScheme.mutedForeground,
              ),
            ),
            const Spacer(),
            GhostButton(
              size: ButtonSize.small,
              leading: Icon(
                showAnswer.value ? LucideIcons.eyeOff : LucideIcons.eye,
                size: AppIconSize.sm,
              ),
              child: Text(showAnswer.value ? l10n.hideAnswer : l10n.showAnswer),
              onPressed: () => showAnswer.value = !showAnswer.value,
            ),
          ],
        ),
        AppGaps.v8,
        SurfaceCard(
          padding: AppEdgeInsets.all20,
          child: RichCardContent(
            content: card.front,
            textAlign: TextAlign.left,
            typedAnswer: userTypedAnswer.value,
            onAnswerChanged: (v) => userTypedAnswer.value = v,
            onSubmitAnswer: () => showAnswer.value = true,
          ),
        ),
      ],
    );
  }

  Widget _buildBackSection(
    ThemeData theme,
    dynamic l10n,
    ValueNotifier<String> userTypedAnswer,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(LucideIcons.circleCheck, size: AppIconSize.sm),
            AppGaps.h8,
            Text(
              l10n.backSide,
              style: theme.typography.xSmall.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: theme.colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
        AppGaps.v8,
        SurfaceCard(
          padding: AppEdgeInsets.all20,
          child: RichCardContent(
            content: card.back,
            textAlign: TextAlign.left,
            typedAnswer: userTypedAnswer.value,
          ),
        ),
      ],
    );
  }

  Widget _buildFsrsMetricsGrid(ThemeData theme, dynamic l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.fsrsScheduleTitle,
          style: theme.typography.xSmall.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: theme.colorScheme.mutedForeground,
          ),
        ),
        AppGaps.v8,
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: l10n.stabilityLabel,
                value: '${card.stability.toStringAsFixed(1)}d',
                icon: LucideIcons.shieldCheck,
              ),
            ),
            AppGaps.h8,
            Expanded(
              child: MetricCard(
                title: l10n.difficultyLabel,
                value: '${card.difficulty.toStringAsFixed(1)} / 10',
                icon: LucideIcons.brain,
              ),
            ),
            AppGaps.h8,
            Expanded(
              child: MetricCard(
                title: l10n.intervalLabel,
                value: '${card.intervalDays}d',
                icon: LucideIcons.calendar,
              ),
            ),
            AppGaps.h8,
            Expanded(
              child: MetricCard(
                title: l10n.repsAndLapsesLabel,
                value: '${card.reps} / ${card.lapses}',
                icon: LucideIcons.rotateCw,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: AppEdgeInsets.all12,
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: AppIconSize.sm,
                color: theme.colorScheme.mutedForeground,
              ),
              AppGaps.h8,
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.captionMuted,
                ),
              ),
            ],
          ),
          AppGaps.v6,
          Text(value, style: context.textStyles.smallBold),
        ],
      ),
    );
  }
}
