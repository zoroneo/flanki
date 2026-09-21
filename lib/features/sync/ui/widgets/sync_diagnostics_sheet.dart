import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/localization/locale_notifier.dart';
import '../../../../core/sync/sync_telemetry_service.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/adaptive_modal.dart';
import '../../providers/sync_telemetry_provider.dart';
import 'sync_circuit_breaker_banner.dart';
import 'sync_diagnostics_metrics_grid.dart';

/// Modal bottom sheet displaying real-time telemetry metrics, circuit breaker status,
/// and recent sync logs.
class SyncDiagnosticsSheet extends ConsumerWidget {
  const SyncDiagnosticsSheet({super.key});

  /// Presents the diagnostics sheet in an adaptive modal/sheet.
  static Future<void> show(BuildContext context) {
    return showAdaptiveModal<void>(
      context: context,
      builder: (context, isDesktop) => const SyncDiagnosticsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final telemetry = ref.watch(syncTelemetryNotifierProvider);
    final telemetryNotifier = ref.read(syncTelemetryNotifierProvider.notifier);

    return Container(
      constraints: const BoxConstraints(maxHeight: 620),
      padding: AppEdgeInsets.all16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.mutedForeground.withValues(alpha: 0.3),
                borderRadius: AppRadius.borderXs,
              ),
            ),
          ),

          // Header
          Row(
            children: [
              Icon(
                LucideIcons.activity,
                size: AppIconSize.md,
                color: theme.colorScheme.primary,
              ),
              AppGaps.h8,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.syncDiagnosticsTitle,
                      style: theme.typography.base.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      l10n.syncDiagnosticsSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.xSmall.copyWith(
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.ghost(
                icon: const Icon(LucideIcons.x, size: AppIconSize.sm),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          AppGaps.v16,
          const Divider(),
          AppGaps.v12,

          // KPI Metrics Grid
          SyncDiagnosticsMetricsGrid(telemetry: telemetry, l10n: l10n),
          AppGaps.v12,

          // Circuit Breaker Status Banner
          SyncCircuitBreakerBanner(state: telemetry.circuitState, l10n: l10n),
          AppGaps.v12,

          // Recent Cycles Section Title & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.syncHistoryTitle,
                style: theme.typography.xSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
              Button.ghost(
                onPressed: () => telemetryNotifier.clearLogs(),
                child: Text(l10n.clearTelemetryLogs),
              ),
            ],
          ),
          AppGaps.v8,

          // Scrollable Logs
          Expanded(
            child: telemetry.records.isEmpty
                ? Center(
                    child: Text(
                      l10n.noSyncHistory,
                      style: theme.typography.small.copyWith(
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: telemetry.records.length,
                    separatorBuilder: (_, _) => AppGaps.v4,
                    itemBuilder: (context, index) {
                      final item = telemetry.records[index];
                      return _buildLogItem(context, theme, item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(
    BuildContext context,
    ThemeData theme,
    SyncTelemetryRecord item,
  ) {
    final icon = item.isSuccess
        ? LucideIcons.circleCheck
        : (item.isOffline ? LucideIcons.wifiOff : LucideIcons.circleAlert);
    final iconColor = item.isSuccess
        ? context.colors.success
        : (item.isOffline ? context.colors.warning : context.colors.error);

    final timeStr =
        '${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}:${item.timestamp.second.toString().padLeft(2, '0')}';

    return Container(
      padding: AppEdgeInsets.h8v4,
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withValues(alpha: 0.2),
        borderRadius: AppRadius.borderXs,
      ),
      child: Row(
        children: [
          Icon(icon, size: AppIconSize.xs, color: iconColor),
          AppGaps.h8,
          Text(
            timeStr,
            style: theme.typography.xSmall.copyWith(
              color: theme.colorScheme.mutedForeground,
            ),
          ),
          AppGaps.h8,
          Expanded(
            child: Text(
              item.resolveSummary(context.l10n),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.xSmall,
            ),
          ),
          Text(
            '${item.durationMs}ms',
            style: theme.typography.xSmall.copyWith(
              color: theme.colorScheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
