import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/sync/payload_optimizer.dart';
import '../../../../core/sync/sync_telemetry_service.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// 4-column KPI metrics grid for Sync Diagnostics.
class SyncDiagnosticsMetricsGrid extends StatelessWidget {
  final SyncTelemetrySnapshot telemetry;
  final AppLocalizations l10n;

  const SyncDiagnosticsMetricsGrid({
    super.key,
    required this.telemetry,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final successRateStr =
        '${telemetry.successRatePercent.toStringAsFixed(1)}%';
    final latencyStr = '${telemetry.averageLatencyMs.toStringAsFixed(0)} ms';
    final transferredStr = SyncBandwidthTracker.formatBytes(
      telemetry.totalBytesTransferred,
    );
    final savedStr = SyncBandwidthTracker.formatBytes(
      telemetry.totalBytesSaved,
    );

    final items = [
      _metricPill(
        theme,
        LucideIcons.circleCheck,
        l10n.syncSuccessRate,
        successRateStr,
        context.colors.success,
      ),
      _metricPill(
        theme,
        LucideIcons.timer,
        l10n.syncAvgLatency,
        latencyStr,
        theme.colorScheme.primary,
      ),
      _metricPill(
        theme,
        LucideIcons.arrowUpDown,
        l10n.syncBandwidthTransferred,
        transferredStr,
        theme.colorScheme.mutedForeground,
      ),
      _metricPill(
        theme,
        LucideIcons.sparkles,
        l10n.syncBandwidthSaved,
        savedStr,
        context.colors.warning,
      ),
    ];

    return Row(
      children: items
          .map(
            (w) => Expanded(
              child: Padding(padding: AppEdgeInsets.h4, child: w),
            ),
          )
          .toList(),
    );
  }

  Widget _metricPill(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Container(
      padding: AppEdgeInsets.h8v4,
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withValues(alpha: 0.35),
        borderRadius: AppRadius.borderSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: AppIconSize.xs, color: iconColor),
              AppGaps.h4,
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.xSmall.copyWith(
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
          AppGaps.v2,
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.xSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
