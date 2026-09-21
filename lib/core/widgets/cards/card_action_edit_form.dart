import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/localization/locale_notifier.dart';
import '../../../../core/models/card.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/form_focus_helper.dart';

class CardActionEditForm extends HookWidget {
  final CardModel card;
  final bool isDesktopMode;
  final VoidCallback onCancel;
  final void Function(String front, String back) onSave;

  const CardActionEditForm({
    super.key,
    required this.card,
    required this.isDesktopMode,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final frontController = useTextEditingController(text: card.front);
    final backController = useTextEditingController(text: card.back);

    void handleSave() {
      onSave(frontController.text, backController.text);
      Navigator.of(context).pop();
    }

    final editFocusNodes = useTabFocusChain(2, onSubmit: handleSave);
    final frontFocusNode = editFocusNodes[0];
    final backFocusNode = editFocusNodes[1];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(l10n.editCardContent, style: theme.typography.h4),
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
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GhostButton(
                alignment: Alignment.center,
                onPressed: onCancel,
                child: Text(l10n.cancel),
              ),
              AppGaps.h8,
              PrimaryButton(
                alignment: Alignment.center,
                onPressed: handleSave,
                child: Text(l10n.saveChanges),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
