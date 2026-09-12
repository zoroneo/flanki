import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/localization/locale_notifier.dart';
import '../../../../core/models/card.dart';
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
            padding: const EdgeInsets.all(24),
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
                      const SizedBox(height: 20),
                      _buildBackSection(theme, l10n, userTypedAnswer),
                    ],
                    const SizedBox(height: 24),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(bottom: BorderSide(color: theme.colorScheme.border)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              deckTitle ?? card.deckId,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (card.noteType == NoteType.cloze)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.muted,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                l10n.clozeDeletion,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const Spacer(),
          OutlineButton(
            size: ButtonSize.small,
            leading: Icon(
              card.isSuspended ? LucideIcons.play : LucideIcons.pause,
              size: 14,
            ),
            child: Text(
              card.isSuspended ? l10n.unsuspendCard : l10n.suspendCard,
            ),
            onPressed: () => browserNotifier.toggleCardSuspend(card.id),
          ),
          const SizedBox(width: 8),
          DestructiveButton(
            size: ButtonSize.small,
            leading: const Icon(LucideIcons.trash2, size: 14),
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
            const Icon(LucideIcons.fileQuestion, size: 16),
            const SizedBox(width: 8),
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
                size: 14,
              ),
              child: Text(showAnswer.value ? l10n.hideAnswer : l10n.showAnswer),
              onPressed: () => showAnswer.value = !showAnswer.value,
            ),
          ],
        ),
        const SizedBox(height: 8),
        SurfaceCard(
          padding: const EdgeInsets.all(20),
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
            const Icon(LucideIcons.circleCheck, size: 16),
            const SizedBox(width: 8),
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
        const SizedBox(height: 8),
        SurfaceCard(
          padding: const EdgeInsets.all(20),
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
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: l10n.stabilityLabel,
                value: '${card.stability.toStringAsFixed(1)}d',
                icon: LucideIcons.shieldCheck,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MetricCard(
                title: l10n.difficultyLabel,
                value: '${card.difficulty.toStringAsFixed(1)} / 10',
                icon: LucideIcons.brain,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MetricCard(
                title: l10n.intervalLabel,
                value: '${card.intervalDays}d',
                icon: LucideIcons.calendar,
              ),
            ),
            const SizedBox(width: 10),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: theme.colorScheme.mutedForeground),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
