import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flanki/core/theme/app_tokens.dart';

void main() {
  group('AppSpacing Tokens', () {
    test('values are strictly non-negative and monotonically increasing', () {
      expect(AppSpacing.none, equals(0));
      expect(AppSpacing.xxs, equals(2));
      expect(AppSpacing.xs, equals(4));
      expect(AppSpacing.sm, equals(8));
      expect(AppSpacing.smPlus, equals(12));
      expect(AppSpacing.md, equals(16));
      expect(AppSpacing.lg, equals(20));
      expect(AppSpacing.xl, equals(24));
      expect(AppSpacing.xxl, equals(32));
      expect(AppSpacing.xxxl, equals(48));

      const spacings = [
        AppSpacing.none,
        AppSpacing.xxs,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.smPlus,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xxxl,
      ];

      for (var i = 0; i < spacings.length - 1; i++) {
        expect(spacings[i] < spacings[i + 1], isTrue);
      }
    });

    test('page padding presets are consistent', () {
      expect(AppSpacing.pageMobile, equals(16));
      expect(AppSpacing.pageTablet, equals(20));
      expect(AppSpacing.pageDesktop, equals(24));
    });
  });

  group('AppRadius Tokens', () {
    test('radius scalars are consistent', () {
      expect(AppRadius.none, equals(0));
      expect(AppRadius.xs, equals(2));
      expect(AppRadius.sm, equals(4));
      expect(AppRadius.md, equals(8));
      expect(AppRadius.lg, equals(12));
      expect(AppRadius.xl, equals(16));
      expect(AppRadius.full, equals(999));
    });

    test('BorderRadius objects match their scalar values', () {
      expect(AppRadius.borderZero, equals(BorderRadius.zero));
      expect(AppRadius.borderXs.topLeft.x, equals(AppRadius.xs));
      expect(AppRadius.borderSm.topLeft.x, equals(AppRadius.sm));
      expect(AppRadius.borderMd.topLeft.x, equals(AppRadius.md));
      expect(AppRadius.borderLg.topLeft.x, equals(AppRadius.lg));
      expect(AppRadius.borderXl.topLeft.x, equals(AppRadius.xl));
      expect(AppRadius.borderFull.topLeft.x, equals(AppRadius.full));
    });
  });

  group('AppIconSize Tokens', () {
    test('icon sizes are monotonically increasing', () {
      expect(AppIconSize.xs, equals(12));
      expect(AppIconSize.sm, equals(16));
      expect(AppIconSize.md, equals(20));
      expect(AppIconSize.lg, equals(24));
      expect(AppIconSize.xl, equals(32));

      const iconSizes = [
        AppIconSize.xs,
        AppIconSize.sm,
        AppIconSize.md,
        AppIconSize.lg,
        AppIconSize.xl,
      ];

      for (var i = 0; i < iconSizes.length - 1; i++) {
        expect(iconSizes[i] < iconSizes[i + 1], isTrue);
      }
    });
  });

  group('AppGaps Tokens', () {
    test('horizontal and vertical gaps have correct dimensions', () {
      expect(AppGaps.h4.width, equals(AppSpacing.xs));
      expect(AppGaps.h8.width, equals(AppSpacing.sm));
      expect(AppGaps.h12.width, equals(AppSpacing.smPlus));
      expect(AppGaps.h16.width, equals(AppSpacing.md));
      expect(AppGaps.h20.width, equals(AppSpacing.lg));
      expect(AppGaps.h24.width, equals(AppSpacing.xl));
      expect(AppGaps.h32.width, equals(AppSpacing.xxl));

      expect(AppGaps.v2.height, equals(AppSpacing.xxs));
      expect(AppGaps.v4.height, equals(AppSpacing.xs));
      expect(AppGaps.v6.height, equals(6));
      expect(AppGaps.v8.height, equals(AppSpacing.sm));
      expect(AppGaps.v12.height, equals(AppSpacing.smPlus));
      expect(AppGaps.v16.height, equals(AppSpacing.md));
      expect(AppGaps.v20.height, equals(AppSpacing.lg));
      expect(AppGaps.v24.height, equals(AppSpacing.xl));
      expect(AppGaps.v32.height, equals(AppSpacing.xxl));
    });
  });

  group('AppEdgeInsets Tokens', () {
    test('edge insets match spacing tokens', () {
      expect(AppEdgeInsets.zero, equals(EdgeInsets.zero));
      expect(AppEdgeInsets.all4, equals(const EdgeInsets.all(4)));
      expect(AppEdgeInsets.all8, equals(const EdgeInsets.all(8)));
      expect(AppEdgeInsets.all12, equals(const EdgeInsets.all(12)));
      expect(AppEdgeInsets.all16, equals(const EdgeInsets.all(16)));
      expect(AppEdgeInsets.all20, equals(const EdgeInsets.all(20)));
      expect(AppEdgeInsets.all24, equals(const EdgeInsets.all(24)));

      expect(AppEdgeInsets.h8v4.horizontal, equals(16));
      expect(AppEdgeInsets.h8v4.vertical, equals(8));
      expect(AppEdgeInsets.h12v8.horizontal, equals(24));
      expect(AppEdgeInsets.h12v8.vertical, equals(16));
      expect(AppEdgeInsets.h16v8.horizontal, equals(32));
      expect(AppEdgeInsets.h16v8.vertical, equals(16));
      expect(AppEdgeInsets.h16v12.horizontal, equals(32));
      expect(AppEdgeInsets.h16v12.vertical, equals(24));
    });
  });
}
