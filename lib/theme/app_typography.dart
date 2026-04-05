import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

/// Fit Her Design System — Typography
///
/// Font: Poppins (Regular 400, Medium 500, SemiBold 600, Bold 700)
/// All sizes use .sp for responsive scaling via flutter_screenutil.
///
/// Existing type scale from styles.dart mapped to semantic names:
///   headlineLarge  (32 Bold)   → h1
///   headlineMedium (24 Regular)→ h2
///   headlineSmall  (20 Bold)   → h3
///   bodyLarge      (18 Medium) → bodyLarge
///   bodyMedium     (16 Regular)→ body
///   bodySmall      (14 Regular)→ bodySmall
///   titleLarge     (12 Bold)   → label
///   titleMedium    (10 Regular)→ labelSmall
///   titleSmall     (8 Regular) → caption
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Poppins';

  // ─── Font Weights ─────────────────────────────────────────
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // ─── Type Scale ───────────────────────────────────────────
  // Each getter returns a fresh TextStyle (required because .sp is runtime).
  // Override color/weight at call site: AppTypography.body.copyWith(color: ...)

  /// 32sp Bold — hero text, large headlines
  static TextStyle get h1 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 32.sp,
        fontWeight: bold,
        color: AppColors.textPrimary,
      );

  /// 24sp Regular — section headers
  static TextStyle get h2 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 24.sp,
        fontWeight: regular,
        color: AppColors.textPrimary,
      );

  /// 20sp Bold — screen titles, app bar
  static TextStyle get h3 => TextStyle(
        fontFamily: fontFamily,
        fontSize: 20.sp,
        fontWeight: bold,
        color: AppColors.textPrimary,
      );

  /// 18sp Medium — large body, emphasis
  static TextStyle get bodyLarge => TextStyle(
        fontFamily: fontFamily,
        fontSize: 18.sp,
        fontWeight: medium,
        color: AppColors.textPrimary,
      );

  /// 16sp Regular — default body text, inputs
  static TextStyle get body => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16.sp,
        fontWeight: regular,
        color: AppColors.textPrimary,
      );

  /// 14sp Regular — secondary body text
  static TextStyle get bodySmall => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14.sp,
        fontWeight: regular,
        color: AppColors.textPrimary,
      );

  /// 12sp Bold — labels, tags
  static TextStyle get label => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12.sp,
        fontWeight: bold,
        color: AppColors.textPrimary,
      );

  /// 10sp Regular — small labels, metadata
  static TextStyle get labelSmall => TextStyle(
        fontFamily: fontFamily,
        fontSize: 10.sp,
        fontWeight: regular,
        color: AppColors.textPrimary,
      );

  /// 8sp Regular — captions, timestamps
  static TextStyle get caption => TextStyle(
        fontFamily: fontFamily,
        fontSize: 8.sp,
        fontWeight: regular,
        color: AppColors.textTertiary,
      );
}
