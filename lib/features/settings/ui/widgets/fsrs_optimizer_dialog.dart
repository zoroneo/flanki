import 'package:flutter/material.dart' as m;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/database/database_service.dart';
import '../../../../core/fsrs/fsrs_optimizer_service.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../providers/settings_notifier.dart';
import 'fsrs_parameter_matrix_view.dart';

class FsrsOptimizerDialog extends ConsumerStatefulWidget {
  const FsrsOptimizerDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await m.showDialog(
      context: context,
      builder: (context) => const m.Dialog(
        backgroundColor: AppColors.transparent,
        child: FsrsOptimizerDialog(),
      ),
    );
  }

  @override
  ConsumerState<FsrsOptimizerDialog> createState() =>
      _FsrsOptimizerDialogState();
}

class _FsrsOptimizerDialogState extends ConsumerState<FsrsOptimizerDialog> {
  bool _isOptimizing = false;
  FsrsOptimizationResult? _result;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final studySettings = ref.watch(studySettingsProvider);
    final studySettingsNotifier = ref.read(studySettingsProvider.notifier);

    final logs = DatabaseService.instance.getAllReviewLogs();
    final totalReviews = logs.length;
    final canOptimize = FsrsOptimizerService.canOptimize(totalReviews);
    final hasCustomWeights = studySettings.fsrsCustomParameters != null;

    return ModalContainer(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 520,
          maxHeight: 650,
        ),
        padding: AppEdgeInsets.all20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme, l10n, hasCustomWeights),
            AppGaps.v16,
            Flexible(
              child: SingleChildScrollView(
                child: _isOptimizing
                    ? _buildLoadingState(theme, l10n)
                    : _result != null
                        ? _buildResultView(theme, l10n, _result!)
                        : _buildInitialView(
                            theme,
                            l10n,
                            totalReviews,
                            canOptimize,
                          ),
              ),
            ),
            AppGaps.v16,
            _buildActionFooter(
              theme,
              l10n,
              canOptimize,
              hasCustomWeights,
              studySettings,
              studySettingsNotifier,
              logs,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    ThemeData theme,
    dynamic l10n,
    bool hasCustomWeights,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.sparkles,
              size: AppIconSize.md,
              color: theme.colorScheme.primary,
            ),
            AppGaps.h8,
            Text(
              l10n.fsrsOptimizerTitle,
              style: theme.typography.large.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Container(
          padding: AppEdgeInsets.h8v2,
          decoration: BoxDecoration(
            color: (hasCustomWeights
                    ? theme.colorScheme.primary
                    : theme.colorScheme.muted)
                .withValues(alpha: 0.15),
            borderRadius: AppRadius.borderSm,
          ),
          child: Text(
            hasCustomWeights
                ? l10n.fsrsWeightsCustomBadge
                : l10n.fsrsWeightsDefaultBadge,
            style: theme.typography.xSmall.copyWith(
              color: hasCustomWeights
                  ? theme.colorScheme.primary
                  : theme.colorScheme.mutedForeground,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(ThemeData theme, dynamic l10n) {
    return Center(
      child: Padding(
        padding: AppEdgeInsets.all32,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            AppGaps.v16,
            Text(
              l10n.fsrsOptimizerOptimizing,
              style: theme.typography.small.copyWith(
                color: theme.colorScheme.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialView(
    ThemeData theme,
    dynamic l10n,
    int totalReviews,
    bool canOptimize,
  ) {
    const minReviews = FsrsOptimizerService.minRequiredReviews;
    final progress = (totalReviews / minReviews).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.fsrsOptimizerSubtitle,
          style: theme.typography.small.copyWith(
            color: theme.colorScheme.mutedForeground,
          ),
        ),
        AppGaps.v16,
        SurfaceCard(
          padding: AppEdgeInsets.all16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    canOptimize
                        ? l10n.fsrsOptimizerReady(totalReviews)
                        : l10n.fsrsOptimizerMinReviewsRequired(
                            minReviews,
                            totalReviews,
                          ),
                    style: theme.typography.small.copyWith(
                      fontWeight: FontWeight.w600,
                      color: canOptimize
                          ? theme.colorScheme.primary
                          : theme.colorScheme.foreground,
                    ),
                  ),
                  Text(
                    '$totalReviews / $minReviews',
                    style: theme.typography.small.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              AppGaps.v8,
              m.LinearProgressIndicator(
                value: progress,
                backgroundColor: theme.colorScheme.muted,
                color: canOptimize
                    ? theme.colorScheme.primary
                    : theme.colorScheme.destructive,
                minHeight: 6,
              ),
            ],
          ),
        ),
        if (_errorMessage != null) ...[
          AppGaps.v12,
          Text(
            _errorMessage!,
            style: theme.typography.small.copyWith(
              color: theme.colorScheme.destructive,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResultView(
    ThemeData theme,
    dynamic l10n,
    FsrsOptimizationResult result,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                theme,
                title: l10n.fsrsMetricsLogLoss,
                baseline: result.baselineLogLoss,
                optimized: result.optimizedLogLoss,
                gainPercent: result.logLossImprovementPercent,
              ),
            ),
            AppGaps.h12,
            Expanded(
              child: _buildMetricCard(
                theme,
                title: l10n.fsrsMetricsRmse,
                baseline: result.baselineRmse,
                optimized: result.optimizedRmse,
                gainPercent: result.rmseImprovementPercent,
              ),
            ),
          ],
        ),
        AppGaps.v16,
        FsrsParameterMatrixView(
          baseline: result.baselineParameters,
          candidate: result.optimizedParameters,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    ThemeData theme, {
    required String title,
    required double baseline,
    required double optimized,
    required double gainPercent,
  }) {
    return SurfaceCard(
      padding: AppEdgeInsets.all12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.typography.xSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.mutedForeground,
            ),
          ),
          AppGaps.v6,
          Row(
            children: [
              Text(
                optimized.toStringAsFixed(4),
                style: theme.typography.large.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              AppGaps.h6,
              Text(
                '(${gainPercent >= 0 ? '-' : '+'}${gainPercent.abs().toStringAsFixed(1)}%)',
                style: theme.typography.xSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: gainPercent >= 0
                      ? theme.colorScheme.primary
                      : theme.colorScheme.destructive,
                ),
              ),
            ],
          ),
          AppGaps.v2,
          Text(
            'Mặc định: ${baseline.toStringAsFixed(4)}',
            style: theme.typography.xSmall.copyWith(
              color: theme.colorScheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionFooter(
    ThemeData theme,
    dynamic l10n,
    bool canOptimize,
    bool hasCustomWeights,
    dynamic studySettings,
    StudySettingsNotifier notifier,
    dynamic logs,
  ) {
    if (_isOptimizing) {
      return const SizedBox.shrink();
    }

    if (_result != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Button.ghost(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
          AppGaps.h8,
          Button.outline(
            onPressed: () async {
              await notifier.resetFsrsParameters();
              if (mounted) {
                showToast(
                  context: context,
                  builder: (context, overlay) => SurfaceCard(
                    child: Basic(
                      title: Text(l10n.fsrsOptimizerResetToast),
                      leading: const Icon(LucideIcons.rotateCcw),
                    ),
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            child: Text(l10n.fsrsOptimizerReset),
          ),
          AppGaps.h8,
          Button.primary(
            onPressed: () async {
              await notifier.saveFsrsCustomParameters(
                _result!.optimizedParameters,
              );
              if (mounted) {
                showToast(
                  context: context,
                  builder: (context, overlay) => SurfaceCard(
                    child: Basic(
                      title: Text(l10n.fsrsOptimizerSuccessToast),
                      leading: const Icon(LucideIcons.check),
                    ),
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            child: Text(l10n.fsrsOptimizerApply),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Button.ghost(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
        if (hasCustomWeights) ...[
          AppGaps.h8,
          Button.outline(
            onPressed: () async {
              await notifier.resetFsrsParameters();
              if (mounted) {
                showToast(
                  context: context,
                  builder: (context, overlay) => SurfaceCard(
                    child: Basic(
                      title: Text(l10n.fsrsOptimizerResetToast),
                      leading: const Icon(LucideIcons.rotateCcw),
                    ),
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            child: Text(l10n.fsrsOptimizerReset),
          ),
        ],
        AppGaps.h8,
        Button.primary(
          onPressed: canOptimize
              ? () async {
                  setState(() {
                    _isOptimizing = true;
                    _errorMessage = null;
                  });
                  try {
                    final res = await FsrsOptimizerService.optimizeAsync(
                      logs,
                      currentWeights: studySettings.fsrsCustomParameters,
                    );
                    if (mounted) {
                      setState(() {
                        _isOptimizing = false;
                        _result = res;
                      });
                    }
                  } catch (e) {
                    if (mounted) {
                      setState(() {
                        _isOptimizing = false;
                        _errorMessage = e.toString();
                      });
                    }
                  }
                }
              : null,
          child: Text(l10n.fsrsOptimizerStart),
        ),
      ],
    );
  }
}
