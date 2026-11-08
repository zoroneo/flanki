import 'package:flutter/widgets.dart';

import '../../../../core/fsrs/fsrs_optimizer_service.dart';
import '../../../../core/theme/app_tokens.dart';
import 'fsrs_metric_card.dart';
import 'fsrs_parameter_matrix_view.dart';

class FsrsOptimizerResultView extends StatelessWidget {
  const FsrsOptimizerResultView({
    super.key,
    required this.result,
    required this.logLossTitle,
    required this.rmseTitle,
    required this.defaultLabel,
  });

  final FsrsOptimizationResult result;
  final String logLossTitle;
  final String rmseTitle;
  final String defaultLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: FsrsMetricCard(
                title: logLossTitle,
                baseline: result.baselineLogLoss,
                optimized: result.optimizedLogLoss,
                gainPercent: result.logLossImprovementPercent,
                defaultLabel: defaultLabel,
              ),
            ),
            AppGaps.h12,
            Expanded(
              child: FsrsMetricCard(
                title: rmseTitle,
                baseline: result.baselineRmse,
                optimized: result.optimizedRmse,
                gainPercent: result.rmseImprovementPercent,
                defaultLabel: defaultLabel,
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
}
