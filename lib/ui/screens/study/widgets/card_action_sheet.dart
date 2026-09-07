import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../../../core/localization/locale_notifier.dart';
import '../../../../core/models/card.dart';

class CardActionSheet extends HookWidget {
  final CardModel card;
  final ValueChanged<CardFlag> onSetFlag;
  final VoidCallback onBury;
  final VoidCallback onSuspend;
  final void Function(String front, String back) onEdit;
  final VoidCallback? onDelete;

  const CardActionSheet({
    super.key,
    required this.card,
    required this.onSetFlag,
    required this.onBury,
    required this.onSuspend,
    required this.onEdit,
    this.onDelete,
  });

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

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Grab handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.mutedForeground.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (isEditing.value) ...[
                Text(l10n.editCardContent, style: theme.typography.h4),
                const SizedBox(height: 16),
                Text(l10n.frontSide, style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
                const SizedBox(height: 6),
                TextField(
                  controller: frontController,
                  maxLines: 3,
                ),
                const SizedBox(height: 14),
                Text(l10n.backSide, style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
                const SizedBox(height: 6),
                TextField(
                  controller: backController,
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GhostButton(
                      onPressed: () => isEditing.value = false,
                      child: Text(l10n.cancel),
                    ),
                    const SizedBox(width: 8),
                    PrimaryButton(
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
                    if (card.tags.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        children: card.tags.take(2).map((t) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.muted,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('#$t', style: const TextStyle(fontSize: 10)),
                          );
                        }).toList(),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // 7 Anki Flag Selectors
                Text(l10n.flagSelector, style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
                const SizedBox(height: 10),
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
                              color: card.flag == CardFlag.none ? theme.colorScheme.foreground : theme.colorScheme.border,
                              width: card.flag == CardFlag.none ? 2 : 1,
                            ),
                          ),
                          child: Icon(
                            LucideIcons.ban,
                            size: 16,
                            color: card.flag == CardFlag.none ? theme.colorScheme.foreground : theme.colorScheme.mutedForeground,
                          ),
                        ),
                      ),
                    ),
                    ...CardFlag.values.where((f) => f != CardFlag.none).map((flag) {
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
                                  ? Border.all(color: theme.colorScheme.foreground, width: 2.5)
                                  : Border.all(color: c, width: 1.5),
                            ),
                            child: isSelected
                                ? const Icon(LucideIcons.check, size: 16, color: m.Colors.white)
                                : null,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 24),

                // Quick Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlineButton(
                        onPressed: () {
                          onBury();
                          Navigator.of(context).pop();
                        },
                        leading: const Icon(LucideIcons.clock, size: 16),
                        child: Text(l10n.buryCard),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlineButton(
                        onPressed: () {
                          onSuspend();
                          Navigator.of(context).pop();
                        },
                        leading: const Icon(LucideIcons.pause, size: 16),
                        child: Text(l10n.suspendCard),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                OutlineButton(
                  onPressed: () => isEditing.value = true,
                  leading: const Icon(LucideIcons.filePenLine, size: 16),
                  child: Text(l10n.editCardContent),
                ),
                if (onDelete != null) ...[
                  const SizedBox(height: 10),
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
                                onPressed: () => Navigator.of(dialogCtx).pop(false),
                                child: Text(l10n.cancel),
                              ),
                              DestructiveButton(
                                onPressed: () => Navigator.of(dialogCtx).pop(true),
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
                    leading: const Icon(LucideIcons.trash2, size: 16),
                    child: Text(l10n.deleteCard),
                  ),
                ],
                const SizedBox(height: 20),

                // FSRS Technical Card Stats
                Card(
                  padding: const EdgeInsets.all(12),
                  filled: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatMini(label: l10n.stabilityLabel, value: '${card.stability.toStringAsFixed(1)}d'),
                      _StatMini(label: l10n.difficultyLabel, value: card.difficulty.toStringAsFixed(1)),
                      _StatMini(label: l10n.repsLabel, value: '${card.reps}'),
                      _StatMini(label: l10n.lapsesLabel, value: '${card.lapses}'),
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
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: theme.colorScheme.mutedForeground)),
      ],
    );
  }
}
