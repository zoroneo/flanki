import 'package:flutter/services.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/localization/locale_notifier.dart';
import '../../../../core/theme/app_tokens.dart';

class PackageLicense {
  final String package;
  final String text;

  const PackageLicense({required this.package, required this.text});
}

class LicenseCodeBlock extends StatelessWidget {
  final String licenseText;
  final VoidCallback onCopy;

  const LicenseCodeBlock({
    super.key,
    required this.licenseText,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: AppEdgeInsets.all12,
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withValues(alpha: 0.45),
        borderRadius: AppRadius.borderSm,
        border: Border.all(
          color: theme.colorScheme.border.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton.ghost(
                icon: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.copy, size: AppIconSize.xs),
                    AppGaps.h4,
                  ],
                ),
                onPressed: onCopy,
              ),
            ],
          ),
          AppGaps.v4,
          SelectableText(
            licenseText,
            style: TextStyle(
              fontFamily: AppTypography.fontFamilyMono,
              fontSize: AppTypography.sub,
              height: 1.45,
              color: theme.colorScheme.foreground.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}

class FlankiLicenseCard extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final String licenseText;

  const FlankiLicenseCard({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    required this.licenseText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Card(
      padding: AppEdgeInsets.all16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppEdgeInsets.all8,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.shieldCheck,
                  size: AppIconSize.md,
                  color: theme.colorScheme.primary,
                ),
              ),
              AppGaps.h12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Flanki',
                          style: theme.typography.semiBold.copyWith(
                            fontSize: 16,
                          ),
                        ),
                        AppGaps.h8,
                        Container(
                          padding: AppEdgeInsets.h8v4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.muted,
                            borderRadius: AppRadius.borderSm,
                          ),
                          child: Text(
                            'v${AppConfig.version}',
                            style: theme.typography.xSmall.copyWith(
                              color: theme.colorScheme.mutedForeground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppGaps.v4,
                    Text(
                      'Copyright © 2026 ZoroNeo. MIT License.',
                      style: theme.typography.xSmall.copyWith(
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.ghost(
                icon: Icon(
                  isExpanded
                      ? LucideIcons.chevronDown
                      : LucideIcons.chevronRight,
                  size: AppIconSize.md,
                  color: theme.colorScheme.mutedForeground,
                ),
                onPressed: onToggle,
              ),
            ],
          ),
          if (isExpanded) ...[
            AppGaps.v12,
            const Divider(),
            AppGaps.v12,
            LicenseCodeBlock(
              licenseText: licenseText,
              onCopy: () {
                Clipboard.setData(ClipboardData(text: licenseText));
                showToast(
                  context: context,
                  builder: (ctx, overlay) => SurfaceCard(
                    child: Basic(
                      title: Text(l10n.licenseCopied),
                      trailing: IconButton.ghost(
                        icon: const Icon(LucideIcons.x, size: AppIconSize.xs),
                        onPressed: () => overlay.close(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class PackageLicenseCard extends StatelessWidget {
  final PackageLicense item;
  final bool isExpanded;
  final VoidCallback onToggle;

  const PackageLicenseCard({
    super.key,
    required this.item,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Card(
      key: ValueKey('pkg_${item.package}'),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggle,
            child: Padding(
              padding: AppEdgeInsets.h16v12,
              child: Row(
                children: [
                  Icon(
                    LucideIcons.package,
                    size: AppIconSize.sm,
                    color: theme.colorScheme.mutedForeground,
                  ),
                  AppGaps.h12,
                  Expanded(
                    child: Text(
                      item.package,
                      style: theme.typography.small.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? LucideIcons.chevronDown
                        : LucideIcons.chevronRight,
                    size: AppIconSize.sm,
                    color: theme.colorScheme.mutedForeground,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: LicenseCodeBlock(
                licenseText: item.text,
                onCopy: () {
                  Clipboard.setData(ClipboardData(text: item.text));
                  showToast(
                    context: context,
                    builder: (ctx, overlay) => SurfaceCard(
                      child: Basic(
                        title: Text(l10n.licenseCopied),
                        trailing: IconButton.ghost(
                          icon: const Icon(LucideIcons.x, size: AppIconSize.xs),
                          onPressed: () => overlay.close(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
