import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/localization/locale_notifier.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../router/app_router.dart';
import 'anki_web_auth_sheet.dart';

class AnkiWebAuthScreen extends StatelessWidget {
  const AnkiWebAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      headers: [
        AppBar(
          leading: [
            IconButton.ghost(
              icon: const Icon(LucideIcons.chevronLeft, size: AppIconSize.md),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.decks);
                }
              },
            ),
          ],
          title: Text(
            l10n.authScreenTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.base.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: const AnkiWebAuthSheet(),
          ),
        ),
      ),
    );
  }
}
