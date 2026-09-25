import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../models/card.dart';
import '../../theme/app_tokens.dart';
import '../adaptive_modal.dart';
import 'card_action_edit_form.dart';
import 'card_action_sheet_components.dart';

class CardActionSheet extends HookWidget {
  final CardModel card;
  final ValueChanged<CardFlag> onSetFlag;
  final VoidCallback onBury;
  final VoidCallback onSuspend;
  final void Function(String front, String back) onEdit;
  final VoidCallback? onDelete;
  final bool isDesktop;

  const CardActionSheet({
    super.key,
    required this.card,
    required this.onSetFlag,
    required this.onBury,
    required this.onSuspend,
    required this.onEdit,
    this.onDelete,
    this.isDesktop = false,
  });

  /// Shows the card action sheet adaptively (bottom sheet on mobile, dialog on desktop).
  static Future<void> show(
    BuildContext context, {
    required CardModel card,
    required ValueChanged<CardFlag> onSetFlag,
    required VoidCallback onBury,
    required VoidCallback onSuspend,
    required void Function(String front, String back) onEdit,
    VoidCallback? onDelete,
  }) {
    return showAdaptiveModal(
      context: context,
      useRootNavigator: false,
      desktopMaxWidth: 520,
      builder: (ctx, isDesktop) => CardActionSheet(
        card: card,
        onSetFlag: onSetFlag,
        onBury: onBury,
        onSuspend: onSuspend,
        onEdit: onEdit,
        onDelete: onDelete,
        isDesktop: isDesktop,
      ),
    );
  }

  /// Returns dynamic semantic flag color based on theme context.
  static Color getFlagColor(BuildContext context, CardFlag flag) =>
      getAnkiFlagColor(context, flag);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isEditing = useState(false);
    final isDesktopMode = isDesktop;

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
                    height: AppSpacing.xxs,
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
              if (isEditing.value)
                CardActionEditForm(
                  card: card,
                  isDesktopMode: isDesktopMode,
                  onCancel: () => isEditing.value = false,
                  onSave: onEdit,
                )
              else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.cardActionTitle, style: theme.typography.h4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (card.tags.isNotEmpty)
                          Wrap(
                            spacing: AppSpacing.xs,
                            children: card.tags.take(2).map((t) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xxs,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.muted.withValues(
                                    alpha: 0.5,
                                  ),
                                  borderRadius: AppRadius.borderSm,
                                ),
                                child: Text(
                                  '#$t',
                                  style: theme.typography.xSmall.copyWith(
                                    color: theme.colorScheme.mutedForeground,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        if (isDesktopMode) ...[
                          AppGaps.h8,
                          IconButton.ghost(
                            icon: const Icon(
                              LucideIcons.x,
                              size: AppIconSize.md,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                AppGaps.v16,
                Text(
                  l10n.flagSelector,
                  style: theme.typography.xSmall.copyWith(
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
                AppGaps.v8,
                CardFlagSelector(
                  currentFlag: card.flag,
                  onSelectFlag: (flag) {
                    onSetFlag(flag);
                    Navigator.of(context).pop();
                  },
                ),
                AppGaps.v24,
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: OutlineButton(
                          alignment: Alignment.center,
                          onPressed: () {
                            onBury();
                            Navigator.of(context).pop();
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                LucideIcons.clock,
                                size: AppIconSize.sm,
                              ),
                              AppGaps.h8,
                              Text(l10n.buryCard),
                            ],
                          ),
                        ),
                      ),
                      AppGaps.h8,
                      Expanded(
                        child: OutlineButton(
                          alignment: Alignment.center,
                          onPressed: () {
                            onSuspend();
                            Navigator.of(context).pop();
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                LucideIcons.pause,
                                size: AppIconSize.sm,
                              ),
                              AppGaps.h8,
                              Text(l10n.suspendCard),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AppGaps.v8,
                OutlineButton(
                  onPressed: () => isEditing.value = true,
                  leading: const Icon(
                    LucideIcons.filePenLine,
                    size: AppIconSize.sm,
                  ),
                  child: Text(l10n.editCardContent),
                ),
                if (onDelete != null) ...[
                  AppGaps.v8,
                  DestructiveButton(
                    onPressed: () async {
                      final confirmed = await m.showDialog<bool>(
                        context: context,
                        builder: (dialogCtx) {
                          return m.AlertDialog(
                            title: Text(l10n.deleteCardTitle),
                            content: Text(l10n.deleteCardConfirm),
                            actions: [
                              OutlineButton(
                                onPressed: () =>
                                    Navigator.of(dialogCtx).pop(false),
                                child: Text(l10n.cancel),
                              ),
                              DestructiveButton(
                                onPressed: () =>
                                    Navigator.of(dialogCtx).pop(true),
                                child: Text(l10n.delete),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmed == true && context.mounted) {
                        Navigator.of(context).pop();
                        onDelete?.call();
                      }
                    },
                    leading: const Icon(
                      LucideIcons.trash2,
                      size: AppIconSize.sm,
                    ),
                    child: Text(l10n.deleteCard),
                  ),
                ],
                AppGaps.v20,
                CardFsrsStatsCard(card: card),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
