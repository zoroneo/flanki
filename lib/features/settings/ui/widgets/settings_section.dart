import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';

/// Bọc một cụm cài đặt liên quan với tiêu đề trực quan, biểu tượng và khoảng cách chuẩn.
class SettingsSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xs,
            bottom: AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.s6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.muted.withValues(alpha: 0.5),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Icon(
                  icon,
                  size: AppIconSize.sm,
                  color: theme.colorScheme.foreground,
                ),
              ),
              AppGaps.h10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.typography.small.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.foreground,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (subtitle != null) ...[
                      AppGaps.v2,
                      Text(
                        subtitle!,
                        style: theme.typography.xSmall.copyWith(
                          color: theme.colorScheme.mutedForeground,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        // Section Children
        ...children,
      ],
    );
  }
}
