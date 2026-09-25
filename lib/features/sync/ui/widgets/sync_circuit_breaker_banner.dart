import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/sync/circuit_breaker.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../providers/sync_state_notifier.dart';
import '../../providers/sync_telemetry_provider.dart';

/// Interactive banner displaying Circuit Breaker health and manual reset action.
class SyncCircuitBreakerBanner extends ConsumerWidget {
  final CircuitState state;
  final AppLocalizations l10n;

  const SyncCircuitBreakerBanner({
    super.key,
    required this.state,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final telemetryNotifier = ref.read(syncTelemetryNotifierProvider.notifier);

    Color badgeColor;
    String statusText;

    switch (state) {
      case CircuitState.closed:
        badgeColor = context.colors.success;
        statusText = l10n.circuitBreakerClosed;
        break;
      case CircuitState.halfOpen:
        badgeColor = context.colors.warning;
        statusText = l10n.circuitBreakerHalfOpen;
        break;
      case CircuitState.open:
        badgeColor = context.colors.error;
        statusText = l10n.circuitBreakerOpen;
        break;
    }

    return Container(
      padding: AppEdgeInsets.all8,
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: AppRadius.borderSm,
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.shieldAlert,
            size: AppIconSize.sm,
            color: badgeColor,
          ),
          AppGaps.h8,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.circuitBreakerStatus,
                  style: theme.typography.xSmall.copyWith(
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
                Text(
                  statusText,
                  style: theme.typography.xSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: badgeColor,
                  ),
                ),
              ],
            ),
          ),
          if (state != CircuitState.closed)
            Button.outline(
              onPressed: () {
                ref.read(syncStateNotifierProvider.notifier).syncNow();
                telemetryNotifier.updateCircuitState(CircuitState.closed);
                showToast(
                  context: context,
                  builder: (context, overlay) => SurfaceCard(
                    child: Basic(
                      title: Text(l10n.circuitBreakerResetSuccess),
                      leading: Icon(
                        LucideIcons.check,
                        color: context.colors.success,
                      ),
                    ),
                  ),
                );
              },
              child: Text(l10n.circuitBreakerReset),
            ),
        ],
      ),
    );
  }
}
