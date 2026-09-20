import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/localization/locale_notifier.dart';
import '../../../../core/theme/app_tokens.dart';

class ExamTakingToolbar extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onPrev;
  final VoidCallback onNext;
  final VoidCallback onOpenSheet;

  const ExamTakingToolbar({
    super.key,
    required this.isFirst,
    required this.isLast,
    required this.onPrev,
    required this.onNext,
    required this.onOpenSheet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        border: Border(top: BorderSide(color: theme.colorScheme.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageMobile,
            vertical: AppSpacing.smPlus,
          ),
          child: SizedBox(
            height: AppSpacing.xxxl,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: OutlineButton(
                    alignment: Alignment.center,
                    size: ButtonSize.normal,
                    onPressed: isFirst ? null : onPrev,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(RadixIcons.arrowLeft, size: AppIconSize.sm),
                        AppGaps.h8,
                        Flexible(
                          child: Text(
                            l10n.previousQuestion,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.typography.small.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AppGaps.h8,
                IconButton.outline(
                  size: ButtonSize.normal,
                  icon: const Icon(RadixIcons.viewGrid, size: AppIconSize.md),
                  onPressed: onOpenSheet,
                ),
                AppGaps.h8,
                Expanded(
                  child: PrimaryButton(
                    alignment: Alignment.center,
                    size: ButtonSize.normal,
                    onPressed: isLast ? null : onNext,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            l10n.nextQuestion,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.typography.small.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        AppGaps.h8,
                        const Icon(RadixIcons.arrowRight, size: AppIconSize.sm),
                      ],
                    ),
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
