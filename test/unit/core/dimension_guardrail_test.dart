import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Dimension Guardrail: All UI files must strictly use AppTokens', () {
    final targetDirs = [
      Directory('lib/features'),
      Directory('lib/core/widgets'),
    ];

    final violations = <String>[];

    final sizedBoxGapPattern = RegExp(
      r'SizedBox\s*\(\s*(height|width)\s*:\s*(\d+(?:\.\d+)?)\s*\)',
    );
    final edgeInsetsAllPattern = RegExp(
      r'EdgeInsets\.all\s*\(\s*(\d+(?:\.\d+)?)\s*\)',
    );
    final borderRadiusCircularPattern = RegExp(
      r'BorderRadius\.circular\s*\(\s*(\d+(?:\.\d+)?)\s*\)',
    );

    for (final dir in targetDirs) {
      if (!dir.existsSync()) continue;

      for (final entity in dir.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;

        final normalizedPath = entity.path.replaceAll(r'\', '/');
        final isUiFile =
            normalizedPath.contains('/ui/') ||
            normalizedPath.contains('/widgets/') ||
            normalizedPath.contains('lib/core/widgets/');

        if (!isUiFile) continue;

        final lines = entity.readAsLinesSync();
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i];

          // Whitelist comments
          if (line.contains('// allow-magic-dimension') ||
              line.trim().startsWith('//')) {
            continue;
          }

          if (sizedBoxGapPattern.hasMatch(line)) {
            violations.add(
              '$normalizedPath:${i + 1} -> Raw SizedBox gap used: "${line.trim()}". Replace with AppGaps.*',
            );
          }

          if (edgeInsetsAllPattern.hasMatch(line)) {
            violations.add(
              '$normalizedPath:${i + 1} -> Raw EdgeInsets.all used: "${line.trim()}". Replace with AppEdgeInsets.* or AppSpacing.*',
            );
          }

          if (borderRadiusCircularPattern.hasMatch(line)) {
            violations.add(
              '$normalizedPath:${i + 1} -> Raw BorderRadius.circular used: "${line.trim()}". Replace with AppRadius.*',
            );
          }
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'Raw magic dimensions detected in UI code! Use AppTokens (AppSpacing, AppGaps, AppRadius, AppEdgeInsets).\n'
          'Violations:\n${violations.join('\n')}',
    );
  });
}
