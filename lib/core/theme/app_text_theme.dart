import 'package:shadcn_flutter/shadcn_flutter.dart';

import 'app_tokens.dart';

/// Flanki Semantic Typography Theme.
///
/// Tự động kết hợp font metrics tiêu chuẩn (BeVietnamPro / JetBrainsMono),
/// line heights chống lệch dòng tiếng Việt (`TextLeadingDistribution.even`),
/// và màu chữ thích ứng theo `ThemeData.colorScheme` hiện hành.
class AppTextTheme {
  final BuildContext context;

  const AppTextTheme._(this.context);

  /// Khởi tạo [AppTextTheme] từ [BuildContext].
  factory AppTextTheme.of(BuildContext context) => AppTextTheme._(context);

  ThemeData get _theme => Theme.of(context);
  ColorScheme get _colors => _theme.colorScheme;

  // Base font style cho text thông thường (BeVietnamPro)
  TextStyle get _baseSans => TextStyle(
    fontFamily: AppTypography.fontFamilySans,
    height: AppTypography.lineHeightNormal,
    leadingDistribution: TextLeadingDistribution.even,
    color: _colors.foreground,
  );

  // Base font style cho code / mono (JetBrainsMono)
  TextStyle get _baseMono => TextStyle(
    fontFamily: AppTypography.fontFamilyMono,
    height: AppTypography.lineHeightNormal,
    leadingDistribution: TextLeadingDistribution.even,
    color: _colors.foreground,
  );

  // ---------------------------------------------------------------------------
  // Headings & Displays
  // ---------------------------------------------------------------------------

  /// Display hero số liệu lớn (36px, w800, tight line-height).
  TextStyle get display => _baseSans.copyWith(
    fontSize: AppTypography.displayLarge,
    height: AppTypography.lineHeightTight,
    fontWeight: FontWeight.w800,
  );

  /// Tiêu đề section hoặc modal (24px, w600, tight line-height).
  TextStyle get h4 => _baseSans.copyWith(
    fontSize: AppTypography.h4,
    height: AppTypography.lineHeightTight,
    fontWeight: FontWeight.w600,
  );

  /// Tiêu đề card hoặc dialog header (20px, w700, tight line-height).
  TextStyle get h3 => _baseSans.copyWith(
    fontSize: AppTypography.xLarge,
    height: AppTypography.lineHeightTight,
    fontWeight: FontWeight.w700,
  );

  /// Chữ kích thước lớn (18px, regular w400).
  TextStyle get large => _baseSans.copyWith(
    fontSize: AppTypography.large,
    fontWeight: FontWeight.w400,
  );

  /// Chữ lớn nhấn mạnh vừa (18px, semi-bold w600).
  TextStyle get largeSemiBold => _baseSans.copyWith(
    fontSize: AppTypography.large,
    fontWeight: FontWeight.w600,
  );

  /// Chữ lớn nhấn mạnh đậm (18px, bold w700).
  TextStyle get largeBold => _baseSans.copyWith(
    fontSize: AppTypography.large,
    fontWeight: FontWeight.w700,
  );

  // ---------------------------------------------------------------------------
  // Body text
  // ---------------------------------------------------------------------------

  /// Chữ body mặc định (16px, regular).
  TextStyle get body => _baseSans.copyWith(
    fontSize: AppTypography.base,
    fontWeight: FontWeight.w400,
  );

  /// Chữ body có trọng số vừa (16px, medium w500).
  TextStyle get bodyMedium => _baseSans.copyWith(
    fontSize: AppTypography.base,
    fontWeight: FontWeight.w500,
  );

  /// Chữ body nhấn mạnh (16px, semi-bold w600).
  TextStyle get bodySemiBold => _baseSans.copyWith(
    fontSize: AppTypography.base,
    fontWeight: FontWeight.w600,
  );

  /// Chữ body phụ / mờ (16px, mutedForeground).
  TextStyle get bodyMuted => _baseSans.copyWith(
    fontSize: AppTypography.base,
    fontWeight: FontWeight.w400,
    color: _colors.mutedForeground,
  );

  /// Chữ câu hỏi, bài tập hoặc text kích thước 15px (regular w400).
  TextStyle get medium => _baseSans.copyWith(
    fontSize: AppTypography.medium,
    fontWeight: FontWeight.w400,
  );

  /// Chữ câu hỏi nhấn mạnh (15px, semi-bold w600).
  TextStyle get mediumSemiBold => _baseSans.copyWith(
    fontSize: AppTypography.medium,
    fontWeight: FontWeight.w600,
  );

  /// Chữ câu hỏi đậm (15px, bold w700).
  TextStyle get mediumBold => _baseSans.copyWith(
    fontSize: AppTypography.medium,
    fontWeight: FontWeight.w700,
  );

  // ---------------------------------------------------------------------------
  // Compact & Secondary text
  // ---------------------------------------------------------------------------

  /// Chữ kích thước nhỏ cho form input, button, secondary label (14px, regular).
  TextStyle get small => _baseSans.copyWith(
    fontSize: AppTypography.small,
    fontWeight: FontWeight.w400,
  );

  /// Chữ nhỏ nhấn mạnh (14px, semi-bold w600).
  TextStyle get smallSemiBold => _baseSans.copyWith(
    fontSize: AppTypography.small,
    fontWeight: FontWeight.w600,
  );

  /// Chữ nhỏ đậm (14px, bold w700).
  TextStyle get smallBold => _baseSans.copyWith(
    fontSize: AppTypography.small,
    fontWeight: FontWeight.w700,
  );

  /// Chữ nhỏ phụ / mờ (14px, mutedForeground).
  TextStyle get smallMuted => _baseSans.copyWith(
    fontSize: AppTypography.small,
    fontWeight: FontWeight.w400,
    color: _colors.mutedForeground,
  );

  /// Subdeck, tag label, compact pill text (11px, w500).
  TextStyle get sub => _baseSans.copyWith(
    fontSize: AppTypography.sub,
    height: AppTypography.lineHeightTight,
    fontWeight: FontWeight.w500,
  );

  /// Subdeck, tag label bán đậm (11px, w600).
  TextStyle get subSemiBold => _baseSans.copyWith(
    fontSize: AppTypography.sub,
    height: AppTypography.lineHeightTight,
    fontWeight: FontWeight.w600,
  );

  /// Subdeck, tag label đậm (11px, w700).
  TextStyle get subBold => _baseSans.copyWith(
    fontSize: AppTypography.sub,
    height: AppTypography.lineHeightTight,
    fontWeight: FontWeight.w700,
  );

  /// Subdeck breadcrumbs / path mờ (11px, w500, mutedForeground).
  TextStyle get subMuted => _baseSans.copyWith(
    fontSize: AppTypography.sub,
    height: AppTypography.lineHeightTight,
    fontWeight: FontWeight.w500,
    color: _colors.mutedForeground,
  );

  /// Subdeck, badge vi mô 11.5px (w500).
  TextStyle get subPlus => _baseSans.copyWith(
    fontSize: AppTypography.subPlus,
    height: AppTypography.lineHeightTight,
    fontWeight: FontWeight.w500,
  );

  /// Subdeck, badge vi mô 11.5px bán đậm (w600).
  TextStyle get subPlusSemiBold => _baseSans.copyWith(
    fontSize: AppTypography.subPlus,
    height: AppTypography.lineHeightTight,
    fontWeight: FontWeight.w600,
  );

  /// Subdeck, badge vi mô 11.5px đậm (w700).
  TextStyle get subPlusBold => _baseSans.copyWith(
    fontSize: AppTypography.subPlus,
    height: AppTypography.lineHeightTight,
    fontWeight: FontWeight.w700,
  );

  /// Navigation, tab label, hoặc compact button text (13px, w600).
  TextStyle get nav => _baseSans.copyWith(
    fontSize: AppTypography.nav,
    fontWeight: FontWeight.w600,
  );

  /// Navigation nhấn mạnh (13px, w700).
  TextStyle get navBold => _baseSans.copyWith(
    fontSize: AppTypography.nav,
    fontWeight: FontWeight.w700,
  );

  /// Navigation mở rộng hoặc tag option (13.5px, w600).
  TextStyle get navPlus => _baseSans.copyWith(
    fontSize: AppTypography.navPlus,
    fontWeight: FontWeight.w600,
  );

  /// Navigation mở rộng nhấn mạnh đậm (13.5px, w700).
  TextStyle get navPlusBold => _baseSans.copyWith(
    fontSize: AppTypography.navPlus,
    fontWeight: FontWeight.w700,
  );

  /// Chữ compact cỡ 12px (regular w400).
  TextStyle get xSmall => _baseSans.copyWith(
    fontSize: AppTypography.xSmall,
    fontWeight: FontWeight.w400,
  );

  /// Chữ compact cỡ 12px có trọng số vừa (medium w500).
  TextStyle get xSmallMedium => _baseSans.copyWith(
    fontSize: AppTypography.xSmall,
    fontWeight: FontWeight.w500,
  );

  /// Chữ compact cỡ 12px nhấn mạnh (semi-bold w600).
  TextStyle get xSmallSemiBold => _baseSans.copyWith(
    fontSize: AppTypography.xSmall,
    fontWeight: FontWeight.w600,
  );

  /// Chữ compact cỡ 12px đậm (bold w700).
  TextStyle get xSmallBold => _baseSans.copyWith(
    fontSize: AppTypography.xSmall,
    fontWeight: FontWeight.w700,
  );

  /// Chữ compact cỡ 12px mờ (mutedForeground).
  TextStyle get xSmallMuted => _baseSans.copyWith(
    fontSize: AppTypography.xSmall,
    fontWeight: FontWeight.w400,
    color: _colors.mutedForeground,
  );

  /// Chữ compact 12.5px (regular w400).
  TextStyle get xSmallPlus => _baseSans.copyWith(
    fontSize: AppTypography.xSmallPlus,
    fontWeight: FontWeight.w400,
  );

  /// Chữ compact 12.5px bán đậm (semi-bold w600).
  TextStyle get xSmallPlusSemiBold => _baseSans.copyWith(
    fontSize: AppTypography.xSmallPlus,
    fontWeight: FontWeight.w600,
  );

  /// Chữ compact 12.5px đậm (bold w700).
  TextStyle get xSmallPlusBold => _baseSans.copyWith(
    fontSize: AppTypography.xSmallPlus,
    fontWeight: FontWeight.w700,
  );

  // ---------------------------------------------------------------------------
  // Micro / Metadata text
  // ---------------------------------------------------------------------------

  /// Chú thích, shortcut hint, timestamp (10px, w500, mutedForeground).
  TextStyle get caption => _baseSans.copyWith(
    fontSize: AppTypography.caption,
    height: AppTypography.lineHeightTight,
    fontWeight: FontWeight.w500,
    color: _colors.mutedForeground,
  );

  /// Chú thích có màu mờ (alias của [caption]).
  TextStyle get captionMuted => caption;

  /// Chú thích bán đậm (10px, w600).
  TextStyle get captionSemiBold => _baseSans.copyWith(
    fontSize: AppTypography.caption,
    height: AppTypography.lineHeightTight,
    fontWeight: FontWeight.w600,
  );

  /// Chú thích có độ tương phản cao (10px, w700, foreground).
  TextStyle get captionBold => _baseSans.copyWith(
    fontSize: AppTypography.caption,
    height: AppTypography.lineHeightTight,
    fontWeight: FontWeight.w700,
  );

  /// Chú thích mở rộng 10.5px (w500, mutedForeground).
  TextStyle get captionPlus => _baseSans.copyWith(
    fontSize: AppTypography.captionPlus,
    height: AppTypography.lineHeightTight,
    fontWeight: FontWeight.w500,
    color: _colors.mutedForeground,
  );

  /// Chú thích mở rộng 10.5px bán đậm (w600).
  TextStyle get captionPlusSemiBold => _baseSans.copyWith(
    fontSize: AppTypography.captionPlus,
    height: AppTypography.lineHeightTight,
    fontWeight: FontWeight.w600,
  );

  /// Chú thích mở rộng 10.5px đậm (w700).
  TextStyle get captionPlusBold => _baseSans.copyWith(
    fontSize: AppTypography.captionPlus,
    height: AppTypography.lineHeightTight,
    fontWeight: FontWeight.w700,
  );

  /// Counter badge cho Due/New cards, trạng thái số lượng (9px, w700, tight badge line-height).
  TextStyle get badge => _baseSans.copyWith(
    fontSize: AppTypography.badge,
    height: AppTypography.lineHeightBadge,
    fontWeight: FontWeight.w700,
  );

  // ---------------------------------------------------------------------------
  // Monospace & Code
  // ---------------------------------------------------------------------------

  /// Monospace code thông dụng (14px, JetBrainsMono).
  TextStyle get code => _baseMono.copyWith(
    fontSize: AppTypography.small,
    fontWeight: FontWeight.w500,
  );

  /// Monospace code kích thước nhỏ cho IDs, hash, keyboard shortcut keys (11px, JetBrainsMono).
  TextStyle get codeSmall => _baseMono.copyWith(
    fontSize: AppTypography.sub,
    height: AppTypography.lineHeightTight,
    fontWeight: FontWeight.w500,
  );
}

/// Tiện ích lấy [AppTextTheme] trực tiếp từ [BuildContext].
extension AppTypographyExtension on BuildContext {
  /// Truy xuất Typography chuẩn hóa của Flanki.
  AppTextTheme get textStyles => AppTextTheme.of(this);
}
