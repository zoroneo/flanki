import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../../../core/localization/locale_notifier.dart';

enum CustomStudyMode {
  byTag,
  flagged,
  reviewAhead,
}

class CustomStudyModal extends HookWidget {
  final void Function(String name, String tag, int limit, String mode) onStartCram;

  const CustomStudyModal({
    super.key,
    required this.onStartCram,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final mode = useState<CustomStudyMode>(CustomStudyMode.byTag);
    final tagController = useTextEditingController();
    final limit = useState<int>(20);

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
              Row(
                children: [
                  const Icon(LucideIcons.zap, color: m.Colors.amber, size: 22),
                  const SizedBox(width: 8),
                  Text(l10n.cramModeTitle, style: theme.typography.h4),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                l10n.cramModeDesc,
                style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground),
              ),
              const SizedBox(height: 20),

              // Mode selector
              Text(l10n.filterMode, style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _ModeButton(
                      label: l10n.byTag,
                      isSelected: mode.value == CustomStudyMode.byTag,
                      onTap: () => mode.value = CustomStudyMode.byTag,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ModeButton(
                      label: l10n.flaggedCards,
                      isSelected: mode.value == CustomStudyMode.flagged,
                      onTap: () => mode.value = CustomStudyMode.flagged,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ModeButton(
                      label: l10n.reviewAhead,
                      isSelected: mode.value == CustomStudyMode.reviewAhead,
                      onTap: () => mode.value = CustomStudyMode.reviewAhead,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (mode.value == CustomStudyMode.byTag) ...[
                Text(l10n.cramTagInputLabel, style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
                const SizedBox(height: 6),
                TextField(
                  controller: tagController,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  placeholder: Text(l10n.addTagPlaceholder),
                ),
                const SizedBox(height: 16),
              ],

              // Card limit
              Text(l10n.cardLimit, style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
              const SizedBox(height: 8),
              Row(
                children: [10, 20, 50, 100].map((l) {
                  final isSelected = limit.value == l;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => limit.value = l,
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 42),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.muted,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            l10n.cardsCountUnit(l),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? theme.colorScheme.primaryForeground : theme.colorScheme.foreground,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              PrimaryButton(
                onPressed: () {
                  final tagName = switch (mode.value) {
                    CustomStudyMode.byTag => tagController.text.trim(),
                    CustomStudyMode.flagged => 'flagged',
                    CustomStudyMode.reviewAhead => 'ahead',
                  };
                  final displayName = switch (mode.value) {
                    CustomStudyMode.byTag => tagName,
                    CustomStudyMode.flagged => l10n.flaggedCards,
                    CustomStudyMode.reviewAhead => l10n.reviewAhead,
                  };
                  onStartCram(
                    displayName,
                    tagName,
                    limit.value,
                    mode.value.name,
                  );
                  Navigator.of(context).pop();
                },
                leading: const Icon(LucideIcons.play, size: 16),
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
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.muted,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? theme.colorScheme.primaryForeground : theme.colorScheme.foreground,
          ),
        ),
      ),
    );
  }
}
