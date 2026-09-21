import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flanki/core/config/app_config.dart';
import 'package:flanki/core/gen/assets.gen.dart';
import 'package:flanki/core/gen/fonts.gen.dart';
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

  group('AppTypography Tokens', () {
    test('font families are defined', () {
      expect(AppTypography.fontFamilySans, equals('BeVietnamPro'));
      expect(AppTypography.fontFamilyMono, equals('JetBrainsMono'));
    });

    test('font sizes are monotonically non-decreasing', () {
      expect(AppTypography.badge, equals(9));
      expect(AppTypography.caption, equals(10));
      expect(AppTypography.captionPlus, equals(10.5));
      expect(AppTypography.sub, equals(11));
      expect(AppTypography.subPlus, equals(11.5));
      expect(AppTypography.xSmall, equals(12));
      expect(AppTypography.xSmallPlus, equals(12.5));
      expect(AppTypography.nav, equals(13));
      expect(AppTypography.navPlus, equals(13.5));
      expect(AppTypography.small, equals(14));
      expect(AppTypography.medium, equals(15));
      expect(AppTypography.base, equals(16));
      expect(AppTypography.large, equals(18));
      expect(AppTypography.xLarge, equals(20));
      expect(AppTypography.h4, equals(24));
      expect(AppTypography.displayLarge, equals(36));

      const sizes = [
        AppTypography.badge,
        AppTypography.caption,
        AppTypography.captionPlus,
        AppTypography.sub,
        AppTypography.subPlus,
        AppTypography.xSmall,
        AppTypography.xSmallPlus,
        AppTypography.nav,
        AppTypography.navPlus,
        AppTypography.small,
        AppTypography.medium,
        AppTypography.base,
        AppTypography.large,
        AppTypography.xLarge,
        AppTypography.h4,
        AppTypography.displayLarge,
      ];

      for (var i = 0; i < sizes.length - 1; i++) {
        expect(sizes[i] <= sizes[i + 1], isTrue);
      }
    });

    test('line heights are valid', () {
      expect(AppTypography.lineHeightNormal, equals(1.35));
      expect(AppTypography.lineHeightTight, equals(1.2));
      expect(AppTypography.lineHeightBadge, equals(1.1));
    });
  });

  group('AppColors Tokens', () {
    test('study rating colors are distinct', () {
      final ratings = {
        AppColors.ratingAgain,
        AppColors.ratingHard,
        AppColors.ratingGood,
        AppColors.ratingEasy,
      };
      expect(ratings.length, equals(4));
    });

    test('semantic alert colors are defined', () {
      expect(AppColors.success, equals(const Color(0xFF4CAF50)));
      expect(AppColors.warning, equals(const Color(0xFFFF9800)));
      expect(AppColors.error, equals(const Color(0xFFF44336)));
      expect(AppColors.info, equals(const Color(0xFF2196F3)));
      expect(AppColors.streakFlame, equals(const Color(0xFFFF5722)));
    });
  });

  group('AppNavIndex Tokens', () {
    test('navigation indexes are sequential from 0 to 5', () {
      expect(AppNavIndex.decks, equals(0));
      expect(AppNavIndex.browser, equals(1));
      expect(AppNavIndex.grammar, equals(2));
      expect(AppNavIndex.exams, equals(3));
      expect(AppNavIndex.stats, equals(4));
      expect(AppNavIndex.settings, equals(5));
    });
  });

  group('AppDimensions Tokens', () {
    test('dimensions are strictly positive', () {
      expect(AppDimensions.sidebarWidth > 0, isTrue);
      expect(AppDimensions.navRailWidth > 0, isTrue);
      expect(AppDimensions.cardMaxWidth > 0, isTrue);
      expect(AppDimensions.statsMaxWidth > 0, isTrue);
      expect(AppDimensions.typeInputMaxWidth > 0, isTrue);
      expect(AppDimensions.typeResultMaxWidth > 0, isTrue);
      expect(AppDimensions.modalDesktopMaxWidth > 0, isTrue);
      expect(AppDimensions.audioButtonSize > 0, isTrue);
      expect(AppDimensions.speedDialFabSize > 0, isTrue);
      expect(AppDimensions.ratingButtonMinHeight > 0, isTrue);
    });
  });

  group('AppDurations Tokens', () {
    test('durations are strictly increasing', () {
      const durations = [
        AppDurations.quick,
        AppDurations.short,
        AppDurations.normal,
        AppDurations.switchSlide,
        AppDurations.modal,
        AppDurations.medium,
        AppDurations.snap,
        AppDurations.shake,
        AppDurations.long,
        AppDurations.celebration,
        AppDurations.celebrationBounce,
      ];

      for (var i = 0; i < durations.length - 1; i++) {
        expect(durations[i] < durations[i + 1], isTrue);
      }
    });

    test('calendar and time intervals are valid', () {
      expect(AppDurations.second1.inSeconds, equals(1));
      expect(AppDurations.day1.inDays, equals(1));
    });
  });

  group('AppLimits & AppThemeValues Tokens', () {
    test('limits are consistent', () {
      expect(AppLimits.badgeMaxCount, equals(99));
      expect(AppLimits.badgeOverflowText, equals('99+'));
    });

    test('theme values are within reasonable bounds', () {
      expect(AppThemeValues.shadcnRadiusFactor, equals(0.5));
      expect(AppThemeValues.ratingButtonPressedScale < 1.0, isTrue);
      expect(AppThemeValues.speedDialRotationTurns, equals(0.125));
      expect(AppThemeValues.cardFlipPerspective > 0, isTrue);
    });
  });

  group('AppColors Tokens', () {
    test('basic utility colors are valid', () {
      expect(AppColors.transparent.a, equals(0.0));
      expect(AppColors.white, equals(const Color(0xFFFFFFFF)));
      expect(AppColors.black, equals(const Color(0xFF000000)));
      expect(AppColors.mutedGrey, equals(const Color(0xFF9E9E9E)));
    });

    test('rating colors are distinct', () {
      final ratings = [
        AppColors.ratingAgain,
        AppColors.ratingHard,
        AppColors.ratingGood,
        AppColors.ratingEasy,
      ];
      expect(ratings.toSet().length, equals(4));
    });

    test('semantic & accent colors are defined', () {
      expect(AppColors.success, isNotNull);
      expect(AppColors.successDark, isNotNull);
      expect(AppColors.warning, isNotNull);
      expect(AppColors.error, isNotNull);
      expect(AppColors.info, isNotNull);
      expect(AppColors.streakFlame, isNotNull);
      expect(AppColors.cramAmber, isNotNull);
      expect(AppColors.cramAmberBg.a > 0, isTrue);
    });

    test('Anki flag palette has 7 distinct colors', () {
      final flags = [
        AppColors.flagRed,
        AppColors.flagOrange,
        AppColors.flagGreen,
        AppColors.flagBlue,
        AppColors.flagPink,
        AppColors.flagTurquoise,
        AppColors.flagPurple,
      ];
      expect(flags.toSet().length, equals(7));
    });

    test('scratchpad colors are defined', () {
      expect(AppColors.scratchAmber, isNotNull);
      expect(AppColors.scratchCyan, isNotNull);
      expect(AppColors.scratchWhite, isNotNull);
      expect(AppColors.scratchRed, isNotNull);
      expect(AppColors.scratchBorder, isNotNull);
    });

    test('heatmap light and dark levels are defined', () {
      expect(AppColors.heatmapL1Light, isNotNull);
      expect(AppColors.heatmapL1Dark, isNotNull);
      expect(AppColors.heatmapL2Light, isNotNull);
      expect(AppColors.heatmapL2Dark, isNotNull);
      expect(AppColors.heatmapL3Light, isNotNull);
      expect(AppColors.heatmapL3Dark, isNotNull);
    });
  });

  group('FlutterGen Integration', () {
    test('typography font families match generated FontFamily constants', () {
      expect(AppTypography.fontFamilySans, equals(FontFamily.beVietnamPro));
      expect(AppTypography.fontFamilyMono, equals(FontFamily.jetBrainsMono));
    });

    test('config asset paths match generated Assets getters', () {
      expect(AppConfig.desktopIconWindows, equals(Assets.icons.appIconIco));
      expect(
        AppConfig.desktopIconDefault,
        equals(Assets.icons.appIconPng.path),
      );
      expect(
        AppConfig.sampleMockExamAssetPath,
        equals(Assets.data.exams.jlptN3Mock01),
      );
      expect(Assets.data.grammar.values.length, equals(36));
      expect(Assets.icons.flanki.path, equals('assets/icons/flanki.png'));
    });
  });

  group('AppWidgetKeys & AppSymbols', () {
    test('widget keys have expected stable identifiers', () {
      expect(AppWidgetKeys.ratingBar.value, equals('rating_bar'));
      expect(AppWidgetKeys.flipButton.value, equals('flip_button'));
      expect(AppWidgetKeys.card('123').value, equals('card_123'));
      expect(AppWidgetKeys.card(null).value, equals('card_none'));
      expect(AppWidgetKeys.deck('abc').value, equals('deck_abc'));
      expect(
        AppWidgetKeys.deckGroup('japanese').value,
        equals('group_japanese'),
      );
      expect(AppWidgetKeys.licensePkg('flutter').value, equals('pkg_flutter'));
      expect(
        AppWidgetKeys.explanationSheet('q1').value,
        equals('explanation_sheet_q1'),
      );
    });

    test('symbols have expected values', () {
      expect(AppSymbols.markCorrect, equals('✅ '));
      expect(AppSymbols.markIncorrect, equals('❌ '));
    });

    test('AppConfig test env and cram defaults', () {
      expect(AppConfig.envFlutterTest, equals('FLUTTER_TEST'));
      expect(AppConfig.defaultCramTag, equals('all'));
    });
  });
}
