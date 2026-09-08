import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/localization/locale_notifier.dart';

class CreateDeckModal extends HookWidget {
  final void Function(String name, String description) onCreateDeck;
  final List<String> existingDeckNames;

  const CreateDeckModal({
    super.key,
    required this.onCreateDeck,
    this.existingDeckNames = const [],
  });

  /// Hiển thị modal tạo bộ thẻ dưới dạng bottom sheet thích ứng bàn phím.
  static Future<void> show(
    BuildContext context, {
    required void Function(String name, String description) onCreateDeck,
    List<String> existingDeckNames = const [],
  }) {
    return m.showModalBottomSheet(
      context: context,
      useRootNavigator: false,
      backgroundColor: m.Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => m.Material(
        type: m.MaterialType.transparency,
        child: CreateDeckModal(
          onCreateDeck: onCreateDeck,
          existingDeckNames: existingDeckNames,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final nameController = useTextEditingController();
    final descController = useTextEditingController();
    final errorMessage = useState<String?>(null);

    void handleCreate() {
      final name = nameController.text.trim();
      final desc = descController.text.trim();

      if (name.isEmpty) {
        errorMessage.value = l10n.deckNameRequired;
        return;
      }

      final isDuplicate = existingDeckNames.any(
        (existing) => existing.toLowerCase() == name.toLowerCase(),
      );
      if (isDuplicate) {
        errorMessage.value = l10n.deckAlreadyExists;
        return;
      }

      errorMessage.value = null;
      Navigator.of(context).pop();
      onCreateDeck(name, desc);
    }

    final viewInsets = MediaQuery.of(context).viewInsets;

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          border: Border(
            top: BorderSide(color: theme.colorScheme.border, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: m.Colors.black.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          bottom: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top drag grab handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(top: 10, bottom: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.mutedForeground.withValues(
                        alpha: 0.25,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header with icon, title, subtitle & close button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          LucideIcons.folderPlus,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.createDeckTitle,
                              style: theme.typography.h4.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.createDeckDesc,
                              style: theme.typography.xSmall.copyWith(
                                color: theme.colorScheme.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  color: theme.colorScheme.border.withValues(alpha: 0.6),
                ),

                // Form fields & actions
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Field 1: Deck Name Input
                      Text(
                        l10n.deckNameLabel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.foreground,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: nameController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        placeholder: Text(l10n.deckNamePlaceholder),
                        features: [
                          InputFeature.leading(
                            Icon(
                              LucideIcons.folder,
                              size: 16,
                              color: theme.colorScheme.mutedForeground,
                            ),
                          ),
                        ],
                        onChanged: (_) {
                          if (errorMessage.value != null) {
                            errorMessage.value = null;
                          }
                        },
                        onSubmitted: (_) => handleCreate(),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.deckHierarchyTip,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.mutedForeground,
                        ),
                      ),

                      if (errorMessage.value != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.circleAlert,
                              size: 14,
                              color: m.Colors.red,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                errorMessage.value!,
                                style: theme.typography.xSmall.copyWith(
                                  color: m.Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Field 2: Deck Description Input
                      Text(
                        l10n.deckDescLabel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.foreground,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: descController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        placeholder: Text(l10n.deckDescPlaceholder),
                        minLines: 2,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 22),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlineButton(
                              alignment: Alignment.center,
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(l10n.cancel),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PrimaryButton(
                              alignment: Alignment.center,
                              onPressed: handleCreate,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(LucideIcons.plus, size: 16),
                                  const SizedBox(width: 8),
                                  Text(l10n.createDeckTitle),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
