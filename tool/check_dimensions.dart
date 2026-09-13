import 'dart:io';

/// Fast CLI Scanner for dimension standardization enforcement in Flanki.
///
/// Scans UI directories for raw dimension magic numbers:
/// - SizedBox(height: \d+) / SizedBox(width: \d+) -> use AppGaps.*
/// - EdgeInsets.all(\d+) -> use AppEdgeInsets.* or AppSpacing.*
/// - BorderRadius.circular(\d+) -> use AppRadius.*
///
/// To whitelist an intentional custom dimension, add `// allow-magic-dimension`
/// on the same line.
void main(List<String> args) {
  final targetDirs = [
    Directory('lib/features'),
    Directory('lib/core/widgets'),
  ];

  final violations = <DimensionViolation>[];

  for (final dir in targetDirs) {
    if (!dir.existsSync()) continue;

    for (final entity in dir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;

      // Only inspect UI files (skip non-UI models, repositories, notifiers, etc.)
      final normalizedPath = entity.path.replaceAll(r'\', '/');
      final isUiFile = normalizedPath.contains('/ui/') ||
          normalizedPath.contains('/widgets/') ||
          normalizedPath.contains('lib/core/widgets/');

      if (!isUiFile) continue;

      _scanFile(entity, violations);
    }
  }

  if (violations.isEmpty) {
    stdout.writeln('✅ [check_dimensions] All UI files adhere to AppTokens! No raw magic dimensions found.');
    exit(0);
  } else {
    stderr.writeln('❌ [check_dimensions] Found ${violations.length} dimension token violation(s):');
    stderr.writeln('');
    for (final v in violations) {
      stderr.writeln('  ${v.filePath}:${v.lineNumber}');
      stderr.writeln('    Line:     ${v.lineContent.trim()}');
      stderr.writeln('    Issue:    ${v.message}');
      stderr.writeln('    Suggest:  ${v.suggestion}');
      stderr.writeln('');
    }
    stderr.writeln('Fix violations using AppGaps, AppSpacing, AppRadius, or AppEdgeInsets from AppTokens.');
    stderr.writeln('To whitelist an intentional exception, append `// allow-magic-dimension` to the line.');
    exit(1);
  }
}

class DimensionViolation {
  final String filePath;
  final int lineNumber;
  final String lineContent;
  final String message;
  final String suggestion;

  DimensionViolation({
    required this.filePath,
    required this.lineNumber,
    required this.lineContent,
    required this.message,
    required this.suggestion,
  });
}

void _scanFile(File file, List<DimensionViolation> violations) {
  final lines = file.readAsLinesSync();
  final path = file.path.replaceAll(r'\', '/');

  // Regex patterns for magic dimensions
  final sizedBoxGapPattern = RegExp(r'SizedBox\s*\(\s*(height|width)\s*:\s*(\d+(?:\.\d+)?)\s*\)');
  final edgeInsetsAllPattern = RegExp(r'EdgeInsets\.all\s*\(\s*(\d+(?:\.\d+)?)\s*\)');
  final borderRadiusCircularPattern = RegExp(r'BorderRadius\.circular\s*\(\s*(\d+(?:\.\d+)?)\s*\)');

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];

    // Whitelist comments
    if (line.contains('// allow-magic-dimension') || line.trim().startsWith('//')) {
      continue;
    }

    // Check raw SizedBox gaps
    final sizedBoxMatch = sizedBoxGapPattern.firstMatch(line);
    if (sizedBoxMatch != null) {
      final property = sizedBoxMatch.group(1)!;
      final val = sizedBoxMatch.group(2)!;
      final isVertical = property == 'height';
      final prefix = isVertical ? 'v' : 'h';
      violations.add(
        DimensionViolation(
          filePath: path,
          lineNumber: i + 1,
          lineContent: line,
          message: 'Raw SizedBox($property: $val) used.',
          suggestion: 'Use AppGaps.$prefix$val or const SizedBox($property: AppSpacing.*).',
        ),
      );
    }

    // Check raw EdgeInsets.all
    final edgeInsetsMatch = edgeInsetsAllPattern.firstMatch(line);
    if (edgeInsetsMatch != null) {
      final val = edgeInsetsMatch.group(1)!;
      violations.add(
        DimensionViolation(
          filePath: path,
          lineNumber: i + 1,
          lineContent: line,
          message: 'Raw EdgeInsets.all($val) used.',
          suggestion: 'Use AppEdgeInsets.all$val or EdgeInsets.all(AppSpacing.*).',
        ),
      );
    }

    // Check raw BorderRadius.circular
    final borderRadiusMatch = borderRadiusCircularPattern.firstMatch(line);
    if (borderRadiusMatch != null) {
      final val = borderRadiusMatch.group(1)!;
      violations.add(
        DimensionViolation(
          filePath: path,
          lineNumber: i + 1,
          lineContent: line,
          message: 'Raw BorderRadius.circular($val) used.',
          suggestion: 'Use AppRadius.border* from AppTokens.',
        ),
      );
    }
  }
}
