import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/localization/locale_notifier.dart';
import '../../../../core/models/card.dart';
import '../../../../core/theme/app_tokens.dart';

import 'package:flanki/core/widgets/adaptive_modal.dart';
import 'package:flanki/core/widgets/form_focus_helper.dart';

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

  static const ankiFlagColors = {
    CardFlag.red: m.Colors.red,
    CardFlag.orange: m.Colors.orange,
    CardFlag.green: m.Colors.green,
    CardFlag.blue: m.Colors.blue,
    CardFlag.pink: m.Colors.pink,
    CardFlag.turquoise: m.Colors.cyan,
    CardFlag.purple: m.Colors.purple,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isEditing = useState(false);
    final frontController = useTextEditingController(text: card.front);
    final backController = useTextEditingController(text: card.back);
    final isDesktopMode = isDesktop;

    void handleSave() {
      onEdit(frontController.text, backController.text);
      Navigator.of(context).pop();
    }

    final editFocusNodes = useTabFocusChain(2, onSubmit: handleSave);
    final frontFocusNode = editFocusNodes[0];
    final backFocusNode = editFocusNodes[1];

    return Container(
      padding: AppEdgeInsets.all24,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: isDesktopMode
            ? AppRadius.borderXl
            : const BorderRadius.vertical(top: Radius.circular(AppSpacing.lg)),
        border: isDesktopMode
            ? Border.all(color: theme.colorScheme.border, width: 1)
            : Border(
                top: BorderSide(color: theme.colorScheme.border, width: 1),
              ),
        boxShadow: [
          BoxShadow(
            color: m.Colors.black.withValues(alpha: isDesktopMode ? 0.2 : 0.15),
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
                // Grab handle
                Center(
                  child: Container(
                    width: 40,
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
              if (isEditing.value) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.editCardContent,
                        style: theme.typography.h4,
                      ),
                    ),
                    if (isDesktopMode)
                      IconButton.ghost(
                        icon: const Icon(LucideIcons.x, size: AppIconSize.md),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                  ],
                ),
                AppGaps.v16,
                Text(
                  l10n.frontSide,
                  style: theme.typography.xSmall.copyWith(
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
                AppGaps.v6,
                TextField(
                  controller: frontController,
                  focusNode: frontFocusNode,
                  maxLines: 3,
                ),
                AppGaps.v16,
                Text(
                  l10n.backSide,
                  style: theme.typography.xSmall.copyWith(
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
                AppGaps.v6,
                TextField(
                  controller: backController,
                  focusNode: backFocusNode,
                  maxLines: 4,
                ),
                AppGaps.v20,
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GhostButton(
                      onPressed: () => isEditing.value = false,
                      child: Text(l10n.cancel),
                    ),
                    AppGaps.h8,
                    PrimaryButton(
                      alignment: Alignment.center,
                      onPressed: () {
                        onEdit(frontController.text, backController.text);
                        Navigator.of(context).pop();
                      },
                      child: Text(l10n.saveChanges),
                    ),
                  ],
                ),
              ] else ...[
                // Card Actions Header
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

                // 7 Anki Flag Selectors
                Text(
                  l10n.flagSelector,
                  style: theme.typography.xSmall.copyWith(
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
                AppGaps.v8,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Clear flag option
                    GestureDetector(
                      onTap: () {
                        onSetFlag(CardFlag.none);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: card.flag == CardFlag.none
                                  ? theme.colorScheme.foreground
                                  : theme.colorScheme.border,
                              width: card.flag == CardFlag.none ? 2 : 1,
                            ),
                          ),
                          child: Icon(
                            LucideIcons.ban,
                            size: AppIconSize.sm,
                            color: card.flag == CardFlag.none
                                ? theme.colorScheme.foreground
                                : theme.colorScheme.mutedForeground,
                          ),
                        ),
                      ),
                    ),
                    ...CardFlag.values.where((f) => f != CardFlag.none).map((
                      flag,
                    ) {
                      final isSelected = card.flag == flag;
                      final c = ankiFlagColors[flag] ?? m.Colors.grey;

                      return GestureDetector(
                        onTap: () {
                          onSetFlag(flag);
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color: theme.colorScheme.foreground,
                                      width: 2.5,
                                    )
                                  : Border.all(color: c, width: 1.5),
                            ),
                            child: isSelected
                                ? const Icon(
                                    LucideIcons.check,
                                    size: AppIconSize.sm,
                                    color: m.Colors.white,
                                  )
                                : null,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                AppGaps.v24,

                // Quick Action Buttons
                Row(
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
                            const Icon(LucideIcons.clock, size: AppIconSize.sm),
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
                            const Icon(LucideIcons.pause, size: AppIconSize.sm),
                            AppGaps.h8,
                            Text(l10n.suspendCard),
                          ],
                        ),
                      ),
                    ),
                  ],
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

                // FSRS Technical Card Stats
                Card(
                  padding: AppEdgeInsets.all12,
                  filled: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatMini(
                        label: l10n.stabilityLabel,
                        value: '${card.stability.toStringAsFixed(1)}d',
                      ),
                      _StatMini(
                        label: l10n.difficultyLabel,
                        value: card.difficulty.toStringAsFixed(1),
                      ),
                      _StatMini(label: l10n.repsLabel, value: '${card.reps}'),
                      _StatMini(
                        label: l10n.lapsesLabel,
                        value: '${card.lapses}',
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatMini extends StatelessWidget {
  final String label;
  final String value;

  const _StatMini({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.typography.semiBold),
        AppGaps.v2,
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: theme.colorScheme.mutedForeground,
          ),
        ),
      ],
    );
  }
}
