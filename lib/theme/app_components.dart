import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Fit Her Design System — Component Styles
///
/// Centralized style specs for buttons, inputs, and containers.
/// Existing widgets (custom_button.dart, custom_textfield.dart, etc.)
/// will adopt these specs in Phase 3 migration.
///
/// Usage:
///   Container(decoration: AppButtonStyle.primaryDecoration)
///   Container(decoration: AppInputStyle.decoration)

// ─────────────────────────────────────────────────────────────
// BUTTONS
// ─────────────────────────────────────────────────────────────

class AppButtonStyle {
  AppButtonStyle._();

  // ─── Primary Button (green gradient) ─────────────────────
  /// was: CustomButton defaults
  static const double height = 60.0;
  static double get width => 390.w;
  static const double borderRadius = 8.0;
  static double get fontSize => 20.sp;
  static const FontWeight fontWeight = FontWeight.w600;
  static const Color textColor = AppColors.textOnPrimary;

  static const LinearGradient gradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: AppColors.primaryGradient,
  );

  static List<BoxShadow> get shadow => [
        BoxShadow(
          spreadRadius: 0,
          blurRadius: 4,
          offset: const Offset(0, 2),
          color: AppColors.textPrimary.withOpacity(0.2),
        ),
      ];

  /// Full primary button decoration (gradient + shadow)
  static BoxDecoration get primaryDecoration => BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadow,
      );

  /// Outline-only button decoration (no fill, colored border)
  static BoxDecoration outlineDecoration({Color? borderColor}) =>
      BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor ?? AppColors.primary),
      );

  /// Primary button text style
  static TextStyle get textStyle => TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: textColor,
        fontFamily: AppTypography.fontFamily,
      );

  // ─── Icon Button (small, compact) ────────────────────────
  /// was: CustomIconButton defaults
  static const double iconButtonRadius = 10.0;
  static const EdgeInsets iconButtonPadding =
      EdgeInsets.symmetric(horizontal: 7, vertical: 7);
}

// ─────────────────────────────────────────────────────────────
// INPUT FIELDS
// ─────────────────────────────────────────────────────────────

class AppInputStyle {
  AppInputStyle._();

  // ─── Text Field ──────────────────────────────────────────
  /// was: CustomTextField defaults
  static const double height = 56.0;
  static const double borderRadius = 8.0;
  static const Color backgroundColor = AppColors.inputBackground;
  static const Color borderColor = AppColors.textPrimary;
  static double get fontSize => 16.sp;
  static const FontWeight fontWeight = FontWeight.w400;
  static const Color textColor = AppColors.textPrimary;
  static const Color hintColor = AppColors.textHint;
  static double get hintFontSize => 14.sp;
  static const Color cursorColor = AppColors.textPrimary;
  static const EdgeInsets contentPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 15);
  static const double prefixIconPadding = 13.0;

  /// Full input field container decoration
  static BoxDecoration get decoration => BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor),
      );

  /// Input text style
  static TextStyle get textStyle => TextStyle(
        color: textColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontFamily: AppTypography.fontFamily,
      );

  /// Hint text style
  static TextStyle get hintStyle => TextStyle(
        color: hintColor,
        fontWeight: FontWeight.normal,
        fontSize: hintFontSize,
        fontFamily: AppTypography.fontFamily,
      );

  // ─── OTP Field ───────────────────────────────────────────
  /// was: CustomPinEntryField defaults
  static const double otpHeight = 72.0;
  static const double otpWidth = 48.0;
  static const double otpBorderRadius = 4.0;
  static const double otpSpacing = 10.0;
}

// ─────────────────────────────────────────────────────────────
// CONTAINERS
// ─────────────────────────────────────────────────────────────

class AppContainerStyle {
  AppContainerStyle._();

  // ─── Gradient Border Container ───────────────────────────
  /// was: GradientBorderContainer defaults
  static const LinearGradient borderGradient = LinearGradient(
    colors: [
      AppColors.primaryDark,
      AppColors.primaryMedium,
      AppColors.primaryDeep,
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static const double gradientBorderRadius = 15.0;

  // ─── Card ────────────────────────────────────────────────
  static const double cardRadius = 20.0;
  static const double cardElevation = 5.0;

  // ─── Bottom Sheet ────────────────────────────────────────
  static const BorderRadius sheetTopRadius = BorderRadius.only(
    topLeft: Radius.circular(25),
    topRight: Radius.circular(25),
  );
}
