import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/localization/locale_notifier.dart';
import '../../../../core/models/custom_study_mode.dart';

import '../../../widgets/adaptive_modal.dart';
import '../../../widgets/form_focus_helper.dart';

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
            String name, String tag, int limit, CustomStudyMode mode)
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
        mode.value,
      );
      Navigator.of(context).pop();
    }

    final cramFocusNodes = useTabFocusChain(1, onSubmit: handleStartCram);
    final tagFocusNode = cramFocusNodes[0];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: isDesktopMode
            ? BorderRadius.circular(16)
            : const BorderRadius.vertical(top: Radius.circular(20)),
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
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.mutedForeground.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  const Icon(LucideIcons.zap, color: m.Colors.amber, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(l10n.cramModeTitle, style: theme.typography.h4),
                  ),
                  if (isDesktopMode)
                    IconButton.ghost(
                      icon: const Icon(LucideIcons.x, size: 18),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                l10n.cramModeDesc,
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
              const SizedBox(height: 20),

              // Mode selector
              Text(
                l10n.filterMode,
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
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
                Text(
                  l10n.cramTagInputLabel,
                  style: theme.typography.xSmall.copyWith(
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: tagController,
                  focusNode: tagFocusNode,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  placeholder: Text(l10n.addTagPlaceholder),
                  onSubmitted: (_) => handleStartCram(),
                ),
                const SizedBox(height: 16),
              ],

              // Card limit
              Text(
                l10n.cardLimit,
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
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
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.muted,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            l10n.cardsCountUnit(l),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
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
              const SizedBox(height: 24),

              PrimaryButton(
                onPressed: handleStartCram,
                alignment: Alignment.center,
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
          color:
              isSelected ? theme.colorScheme.primary : theme.colorScheme.muted,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? theme.colorScheme.primaryForeground
                : theme.colorScheme.foreground,
          ),
        ),
      ),
    );
  }
}
