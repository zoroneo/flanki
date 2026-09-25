import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../router/app_router.dart';

class DeckToolbar extends StatelessWidget {
  final bool isMobile;
  final ValueNotifier<String> searchQuery;
  final VoidCallback onAddDeck;
  final VoidCallback onImportApkg;
  final VoidCallback onCustomStudy;

  const DeckToolbar({
    super.key,
    required this.isMobile,
    required this.searchQuery,
    required this.onAddDeck,
    required this.onImportApkg,
    required this.onCustomStudy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final isCompactToolbar = availableWidth < 680;
        final isUltraCompact = availableWidth < 520;

        return SizedBox(
          height: AppDimensions.searchToolbarHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: TextField(
                  features: [
                    InputFeature.leading(
                      Icon(
                        LucideIcons.search,
                        size: AppIconSize.md,
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                  placeholder: Text(l10n.searchDecks),
                  onChanged: (val) => searchQuery.value = val,
                ),
              ),
              if (isMobile) ...[
                AppGaps.h8,
                Tooltip(
                  tooltip: (context) =>
                      TooltipContainer(child: Text(l10n.navBrowser)),
                  child: IconButton.outline(
                    icon: const Icon(
                      LucideIcons.fileSearch,
                      size: AppIconSize.sm,
                    ),
                    onPressed: () => context.go(AppRoutes.browser),
                  ),
                ),
              ],
              if (!isMobile) ...[
                AppGaps.h12,
                PrimaryButton(
                  alignment: Alignment.center,
                  leading: const Icon(LucideIcons.plus, size: AppIconSize.sm),
                  onPressed: onAddDeck,
                  child: Text(l10n.addNewDeck, maxLines: 1, softWrap: false),
                ),
                if (!isUltraCompact) ...[
                  AppGaps.h8,
                  _buildImportButton(context, l10n, isCompactToolbar),
                  AppGaps.h8,
                  _buildCustomStudyButton(context, l10n, isCompactToolbar),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildImportButton(
    BuildContext context,
    dynamic l10n,
    bool isCompact,
  ) {
    if (isCompact) {
      return Tooltip(
        tooltip: (context) => TooltipContainer(child: Text(l10n.importApkg)),
        child: IconButton.outline(
          icon: const Icon(LucideIcons.fileUp, size: AppIconSize.sm),
          onPressed: onImportApkg,
        ),
      );
    }
    return OutlineButton(
      alignment: Alignment.center,
      leading: const Icon(LucideIcons.fileUp, size: AppIconSize.sm),
      onPressed: onImportApkg,
      child: Text(l10n.importApkg, maxLines: 1, softWrap: false),
    );
  }

  Widget _buildCustomStudyButton(
    BuildContext context,
    dynamic l10n,
    bool isCompact,
  ) {
    if (isCompact) {
      return Tooltip(
        tooltip: (context) => TooltipContainer(child: Text(l10n.customStudy)),
        child: IconButton.ghost(
          icon: const Icon(LucideIcons.zap, size: AppIconSize.sm),
          onPressed: onCustomStudy,
        ),
      );
    }
    return GhostButton(
      alignment: Alignment.center,
      leading: const Icon(LucideIcons.zap, size: AppIconSize.sm),
      onPressed: onCustomStudy,
      child: Text(l10n.customStudy, maxLines: 1, softWrap: false),
    );
  }
}
