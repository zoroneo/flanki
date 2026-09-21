import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';

class ConflictOptionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String desc;
  final String? badge;
  final VoidCallback onTap;

  const ConflictOptionCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.desc,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return m.Material(
      color: theme.colorScheme.card,
      borderRadius: AppRadius.borderMd,
      child: m.InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderMd,
        child: Container(
          padding: AppEdgeInsets.all12,
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderMd,
            border: Border.all(
              color: badge != null
                  ? theme.colorScheme.primary.withValues(alpha: 0.4)
                  : theme.colorScheme.border.withValues(alpha: 0.8),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: AppEdgeInsets.all8,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderMd,
                ),
                child: Icon(icon, size: AppIconSize.md, color: iconColor),
              ),
              AppGaps.h8,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(title, style: context.textStyles.nav),
                        ),
                        if (badge != null) ...[
                          AppGaps.h8,
                          Container(
                            padding: AppEdgeInsets.h4v2,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: AppRadius.borderSm,
                            ),
                            child: Text(
                              badge!,
                              style: context.textStyles.captionBold.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    AppGaps.v2,
                    Text(
                      desc,
                      style: theme.typography.xSmall.copyWith(
                        color: theme.colorScheme.mutedForeground,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              AppGaps.h8,
              Icon(
                LucideIcons.chevronRight,
                size: AppIconSize.sm,
                color: theme.colorScheme.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
