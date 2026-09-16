import 'package:flutter/material.dart' as m;
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/localization/locale_notifier.dart';

import 'package:flanki/core/widgets/adaptive_modal.dart';
import 'package:flanki/core/widgets/form_focus_helper.dart';
import 'package:flanki/core/theme/app_tokens.dart';

class CreateDeckModal extends HookWidget {
  final void Function(String name, String description) onCreateDeck;
  final List<String> existingDeckNames;
  final bool isDesktop;

  const CreateDeckModal({
    super.key,
    required this.onCreateDeck,
    this.existingDeckNames = const [],
    this.isDesktop = false,
  });

  /// Hiển thị modal tạo bộ thẻ thích ứng: bottom sheet trên mobile, dialog trên desktop.
  static Future<void> show(
    BuildContext context, {
    required void Function(String name, String description) onCreateDeck,
    List<String> existingDeckNames = const [],
  }) {
    return showAdaptiveModal(
      context: context,
      useRootNavigator: false,
      desktopMaxWidth: 460,
      builder: (ctx, isDesktop) => CreateDeckModal(
        onCreateDeck: onCreateDeck,
        existingDeckNames: existingDeckNames,
        isDesktop: isDesktop,
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

    final focusNodes = useTabFocusChain(2, onSubmit: handleCreate);
    final nameFocusNode = focusNodes[0];
    final descFocusNode = focusNodes[1];

    final viewInsets = MediaQuery.of(context).viewInsets;
    final isDesktopMode = isDesktop;

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.card,
          borderRadius: isDesktopMode
              ? AppRadius.borderXl
              : const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.xl),
                ),
          border: isDesktopMode
              ? Border.all(color: theme.colorScheme.border, width: 1)
              : Border(
                  top: BorderSide(color: theme.colorScheme.border, width: 1),
                ),
          boxShadow: [
            BoxShadow(
              color: m.Colors.black.withValues(
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
                if (!isDesktopMode)
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
                        borderRadius: AppRadius.borderXs,
                      ),
                    ),
                  ),

                if (isDesktopMode) AppGaps.v16,

                // Header with icon, title, subtitle & close button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: AppEdgeInsets.all8,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: AppRadius.borderMd,
                        ),
                        child: Icon(
                          LucideIcons.folderPlus,
                          color: theme.colorScheme.primary,
                          size: AppIconSize.md,
                        ),
                      ),
                      AppGaps.h12,
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
                            AppGaps.v2,
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
                AppGaps.v12,
                Divider(
                  height: 1,
                  color: theme.colorScheme.border.withValues(alpha: 0.6),
                ),

                // Form fields & actions
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
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
                      AppGaps.v6,
                      TextField(
                        controller: nameController,
                        focusNode: nameFocusNode,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () => descFocusNode.requestFocus(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        placeholder: Text(l10n.deckNamePlaceholder),
                        features: [
                          InputFeature.leading(
                            Icon(
                              LucideIcons.folder,
                              size: AppIconSize.sm,
                              color: theme.colorScheme.mutedForeground,
                            ),
                          ),
                        ],
                        onChanged: (_) {
                          if (errorMessage.value != null) {
                            errorMessage.value = null;
                          }
                        },
                        onSubmitted: (_) => descFocusNode.requestFocus(),
                      ),
                      AppGaps.v4,
                      Text(
                        l10n.deckHierarchyTip,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.mutedForeground,
                        ),
                      ),

                      if (errorMessage.value != null) ...[
                        AppGaps.v8,
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.circleAlert,
                              size: AppIconSize.sm,
                              color: m.Colors.red,
                            ),
                            AppGaps.h8,
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

                      AppGaps.v16,

                      // Field 2: Deck Description Input
                      Text(
                        l10n.deckDescLabel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.foreground,
                        ),
                      ),
                      AppGaps.v6,
                      TextField(
                        controller: descController,
                        focusNode: descFocusNode,
                        padding: AppEdgeInsets.h12v8,
                        placeholder: Text(l10n.deckDescPlaceholder),
                        minLines: 2,
                        maxLines: 3,
                      ),

                      AppGaps.v24,

                      // Action Buttons
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: OutlineButton(
                                alignment: Alignment.center,
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(l10n.cancel),
                              ),
                            ),
                            AppGaps.h12,
                            Expanded(
                              child: PrimaryButton(
                                alignment: Alignment.center,
                                onPressed: handleCreate,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      LucideIcons.plus,
                                      size: AppIconSize.sm,
                                    ),
                                    AppGaps.h8,
                                    Text(l10n.createDeckTitle),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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
