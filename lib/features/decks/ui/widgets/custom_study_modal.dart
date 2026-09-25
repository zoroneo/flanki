import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/models/custom_study_mode.dart';

import 'package:flanki/core/widgets/adaptive_modal.dart';
import 'package:flanki/core/widgets/form_focus_helper.dart';
import 'package:flanki/core/theme/app_tokens.dart';

class CustomStudyModal extends HookWidget {
  final void Function(String name, String tag, int limit, CustomStudyMode mode)
  onStartCram;
  final bool isDesktop;

  const CustomStudyModal({
    super.key,
    required this.onStartCram,
    this.isDesktop = false,
  });

  /// Shows the custom study modal adaptively (bottom sheet on mobile, dialog on desktop).
  static Future<void> show(
    BuildContext context, {
    required void Function(
      String name,
      String tag,
      int limit,
      CustomStudyMode mode,
    )
    onStartCram,
  }) {
    return showAdaptiveModal(
      context: context,
      useRootNavigator: false,
      desktopMaxWidth: 500,
      builder: (ctx, isDesktop) =>
          CustomStudyModal(onStartCram: onStartCram, isDesktop: isDesktop),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final mode = useState<CustomStudyMode>(CustomStudyMode.byTag);
    final tagController = useTextEditingController();
    final limit = useState<int>(20);
    final isDesktopMode = isDesktop;

    void handleStartCram() {
      final tagName = switch (mode.value) {
        CustomStudyMode.byTag => tagController.text.trim(),
        CustomStudyMode.flagged => CustomStudyMode.tagFlagged,
        CustomStudyMode.reviewAhead => CustomStudyMode.tagReviewAhead,
      };
      final displayName = switch (mode.value) {
        CustomStudyMode.byTag => tagName,
        CustomStudyMode.flagged => l10n.flaggedCards,
        CustomStudyMode.reviewAhead => l10n.reviewAhead,
      };
      onStartCram(displayName, tagName, limit.value, mode.value);
      Navigator.of(context).pop();
    }

    final cramFocusNodes = useTabFocusChain(1, onSubmit: handleStartCram);
    final tagFocusNode = cramFocusNodes[0];

    return Container(
      padding: AppEdgeInsets.all24,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: isDesktopMode
            ? AppRadius.borderXl
            : const BorderRadius.vertical(top: Radius.circular(AppSpacing.lg)),
        border: isDesktopMode
            ? Border.all(
                color: theme.colorScheme.border,
                width: AppDimensions.hairline,
              )
            : Border(
                top: BorderSide(
                  color: theme.colorScheme.border,
                  width: AppDimensions.hairline,
                ),
              ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(
              alpha: isDesktopMode ? 0.2 : 0.15,
            ),
            blurRadius: isDesktopMode ? 24 : 16,
            offset: isDesktopMode ? const Offset(0, 8) : const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: !isDesktopMode,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isDesktopMode) ...[
                Center(
                  child: Container(
                    width: AppDimensions.modalGrabHandleWidth,
                    height: AppDimensions.modalGrabHandleHeight,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.mutedForeground.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: AppRadius.borderXs,
                    ),
                  ),
                ),
                AppGaps.v16,
              ],
              Row(
                children: [
                  Icon(
                    LucideIcons.zap,
                    color: context.colors.cramAmber,
                    size: AppIconSize.lg,
                  ),
                  AppGaps.h8,
                  Expanded(
                    child: Text(l10n.cramModeTitle, style: theme.typography.h4),
                  ),
                  if (isDesktopMode)
                    IconButton.ghost(
                      icon: const Icon(LucideIcons.x, size: AppIconSize.md),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                ],
              ),
              AppGaps.v6,
              Text(
                l10n.cramModeDesc,
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
              AppGaps.v20,

              // Mode selector
              Text(
                l10n.filterMode,
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
              AppGaps.v8,
              Row(
                children: [
                  Expanded(
                    child: _ModeButton(
                      label: l10n.byTag,
                      isSelected: mode.value == CustomStudyMode.byTag,
                      onTap: () => mode.value = CustomStudyMode.byTag,
                    ),
                  ),
                  AppGaps.h8,
                  Expanded(
                    child: _ModeButton(
                      label: l10n.flaggedCards,
                      isSelected: mode.value == CustomStudyMode.flagged,
                      onTap: () => mode.value = CustomStudyMode.flagged,
                    ),
                  ),
                  AppGaps.h8,
                  Expanded(
                    child: _ModeButton(
                      label: l10n.reviewAhead,
                      isSelected: mode.value == CustomStudyMode.reviewAhead,
                      onTap: () => mode.value = CustomStudyMode.reviewAhead,
                    ),
                  ),
                ],
              ),
              AppGaps.v16,

              if (mode.value == CustomStudyMode.byTag) ...[
                Text(
                  l10n.cramTagInputLabel,
                  style: theme.typography.xSmall.copyWith(
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
                AppGaps.v6,
                TextField(
                  controller: tagController,
                  focusNode: tagFocusNode,
                  padding: AppEdgeInsets.h12v8,
                  placeholder: Text(l10n.addTagPlaceholder),
                  onSubmitted: (_) => handleStartCram(),
                ),
                AppGaps.v16,
              ],

              // Card limit
              Text(
                l10n.cardLimit,
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
              AppGaps.v8,
              Row(
                children: AppConfig.cramLimitOptions.map((l) {
                  final isSelected = limit.value == l;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxs,
                      ),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => limit.value = l,
                        child: Container(
                          constraints: const BoxConstraints(
                            minHeight: AppDimensions.buttonHeightStandard,
                          ),
                          padding: AppEdgeInsets.v8,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.muted,
                            borderRadius: AppRadius.borderMd,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            l10n.cardsCountUnit(l),
                            style:
                                (isSelected
                                        ? context.textStyles.xSmallBold
                                        : context.textStyles.xSmallMedium)
                                    .copyWith(
                                      color: isSelected
                                          ? theme.colorScheme.primaryForeground
                                          : theme.colorScheme.foreground,
                                    ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              AppGaps.v24,

              PrimaryButton(
                onPressed: handleStartCram,
                alignment: Alignment.center,
                leading: const Icon(LucideIcons.play, size: AppIconSize.sm),
                child: Text(l10n.startCram),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.muted,
          borderRadius: AppRadius.borderMd,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style:
              (isSelected
                      ? context.textStyles.xSmallBold
                      : context.textStyles.xSmallMedium)
                  .copyWith(
                    color: isSelected
                        ? theme.colorScheme.primaryForeground
                        : theme.colorScheme.foreground,
                  ),
        ),
      ),
    );
  }
}
