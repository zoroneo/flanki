import 'package:flutter/material.dart' as m;
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../l10n/generated/app_localizations.dart';

class GrammarExitDialog extends StatelessWidget {
  const GrammarExitDialog({super.key});

  static Future<void> show(BuildContext context) {
    return m.showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const GrammarExitDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        margin: AppEdgeInsets.all24,
        child: Card(
          child: Padding(
            padding: AppEdgeInsets.all24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: AppEdgeInsets.all8,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.triangleAlert,
                        size: AppIconSize.md,
                        color: Colors.red,
                      ),
                    ),
                    AppGaps.h12,
                    Expanded(
                      child: Text(
                        l10n.grammarExitDialogTitle,
                        style: theme.typography.large.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                AppGaps.v12,
                Text(
                  l10n.grammarExitDialogContent,
                  style: theme.typography.small.copyWith(
                    color: theme.colorScheme.mutedForeground,
                    height: 1.4,
                  ),
                ),
                AppGaps.v24,
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlineButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.grammarContinueStudying),
                    ),
                    AppGaps.h8,
                    DestructiveButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.pop();
                      },
                      child: Text(l10n.grammarExitConfirm),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
