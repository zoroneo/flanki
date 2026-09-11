import 'package:flutter/material.dart' as m;
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

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
        margin: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.triangleAlert,
                        size: 20,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
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
                const SizedBox(height: 12),
                Text(
                  l10n.grammarExitDialogContent,
                  style: theme.typography.small.copyWith(
                    color: theme.colorScheme.mutedForeground,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlineButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.grammarContinueStudying),
                    ),
                    const SizedBox(width: 10),
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
