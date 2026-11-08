import 'package:flutter/material.dart' as m;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/database/database_service.dart';
import '../../../../core/fsrs/fsrs_optimizer_service.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../providers/settings_notifier.dart';
import 'fsrs_optimizer_progress_card.dart';
import 'fsrs_optimizer_result_view.dart';

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

    // Narrow reactive rebuild scope strictly to custom parameters existence
    final hasCustomWeights = ref.watch(
      studySettingsProvider.select((s) => s.fsrsCustomParameters != null),
    );
    final studySettingsNotifier = ref.read(studySettingsProvider.notifier);

    final logs = DatabaseService.instance.getAllReviewLogs();
    final totalReviews = logs.length;
    final canOptimize = FsrsOptimizerService.canOptimize(totalReviews);

    return ModalContainer(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: AppDimensions.modalDesktopMaxWidth,
          maxHeight: AppDimensions.diagnosticsSheetMaxHeight,
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
                    ? FsrsOptimizerResultView(
                        result: _result!,
                        logLossTitle: l10n.fsrsMetricsLogLoss,
                        rmseTitle: l10n.fsrsMetricsRmse,
                        defaultLabel: l10n.defaultLabel,
                      )
                    : _buildInitialView(theme, l10n, totalReviews, canOptimize),
              ),
            ),
            AppGaps.v16,
            _buildActionFooter(
              theme,
              l10n,
              canOptimize,
              hasCustomWeights,
              studySettingsNotifier,
              logs,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, dynamic l10n, bool hasCustomWeights) {
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
            color:
                (hasCustomWeights
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
        FsrsOptimizerProgressCard(
          totalReviews: totalReviews,
          minReviews: minReviews,
          canOptimize: canOptimize,
          readyMessage: l10n.fsrsOptimizerReady(totalReviews),
          notReadyMessage: l10n.fsrsOptimizerMinReviewsRequired(
            minReviews,
            totalReviews,
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

  Widget _buildActionFooter(
    ThemeData theme,
    dynamic l10n,
    bool canOptimize,
    bool hasCustomWeights,
    StudySettingsNotifier notifier,
    dynamic logs,
  ) {
    if (_isOptimizing) {
      return const SizedBox.shrink();
    }

    Future<void> handleReset() async {
      await notifier.resetFsrsParameters();
      if (!mounted) return;
      _showToast(l10n.fsrsOptimizerResetToast, LucideIcons.rotateCcw);
      Navigator.of(context).pop();
    }

    final closeButton = Button.ghost(
      onPressed: () => Navigator.of(context).pop(),
      child: Text(l10n.closeButton),
    );

    if (_result != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          closeButton,
          AppGaps.h8,
          Button.outline(
            onPressed: handleReset,
            child: Text(l10n.fsrsOptimizerReset),
          ),
          AppGaps.h8,
          Button.primary(
            onPressed: () async {
              await notifier.saveFsrsCustomParameters(
                _result!.optimizedParameters,
              );
              if (!mounted) return;
              _showToast(l10n.fsrsOptimizerSuccessToast, LucideIcons.check);
              Navigator.of(context).pop();
            },
            child: Text(l10n.fsrsOptimizerApply),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        closeButton,
        if (hasCustomWeights) ...[
          AppGaps.h8,
          Button.outline(
            onPressed: handleReset,
            child: Text(l10n.fsrsOptimizerReset),
          ),
        ],
        AppGaps.h8,
        Button.primary(
          onPressed: canOptimize ? () => _runOptimization(logs) : null,
          child: Text(l10n.fsrsOptimizerStart),
        ),
      ],
    );
  }

  void _showToast(String title, IconData icon) {
    showToast(
      context: context,
      builder: (context, overlay) => SurfaceCard(
        child: Basic(title: Text(title), leading: Icon(icon)),
      ),
    );
  }

  Future<void> _runOptimization(dynamic logs) async {
    setState(() {
      _isOptimizing = true;
      _errorMessage = null;
    });
    try {
      final currentParams = ref
          .read(studySettingsProvider)
          .fsrsCustomParameters;
      final res = await FsrsOptimizerService.optimizeAsync(
        logs,
        currentWeights: currentParams,
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
}
