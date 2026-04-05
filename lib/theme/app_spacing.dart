import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Fit Her Design System — Spacing & Radius Tokens
///
/// 4px-based spacing scale. Use .w/.h for responsive sizing.
/// Replaces the 200-value Dimens class with a structured scale.
///
/// Usage:
///   SizedBox(height: AppSpacing.md)        // 12px gap
///   EdgeInsets.all(AppSpacing.base)         // 16px padding
///   BorderRadius.circular(AppRadius.sm)     // 8px radius
class AppSpacing {
  AppSpacing._();

  // ─── Spacing Scale (4px base) ─────────────────────────────
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double base = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;
  static const double xxxxl = 48.0;

  // ─── Common Component Sizes ───────────────────────────────
  static const double buttonHeight = 60.0;
  static const double inputHeight = 56.0;
  static const double otpFieldHeight = 72.0;
  static const double otpFieldWidth = 48.0;
  static const double iconButtonSize = 44.0;

  // ─── Screen Padding ───────────────────────────────────────
  /// Standard horizontal padding for screen content
  static const double screenHorizontal = 20.0;

  // ─── Responsive Helpers ───────────────────────────────────
  /// Vertical gap — use in Column/ListView for consistent spacing
  static SizedBox verticalGap(double height) => SizedBox(height: height.h);
  static SizedBox horizontalGap(double width) => SizedBox(width: width.w);

  // ─── Common Gaps (convenience) ────────────────────────────
  static SizedBox get gapXs => SizedBox(height: xs.h);
  static SizedBox get gapSm => SizedBox(height: sm.h);
  static SizedBox get gapMd => SizedBox(height: md.h);
  static SizedBox get gapBase => SizedBox(height: base.h);
  static SizedBox get gapLg => SizedBox(height: lg.h);
  static SizedBox get gapXl => SizedBox(height: xl.h);
  static SizedBox get gapXxl => SizedBox(height: xxl.h);
}

/// Border radius tokens — extracted from actual usage in widgets.
class AppRadius {
  AppRadius._();

  // ─── Radius Scale ─────────────────────────────────────────
  static const double xs = 4.0;     // OTP fields, small elements
  static const double sm = 8.0;     // Buttons, text fields (standard)
  static const double md = 10.0;    // Icon buttons
  static const double base = 12.0;  // Dropdowns
  static const double lg = 15.0;    // Gradient containers
  static const double xl = 20.0;    // Cards, plan widgets
  static const double xxl = 25.0;   // Bottom sheet tops
  static const double pill = 30.0;  // Pill-shaped containers

  // ─── Pre-built BorderRadius (convenience) ─────────────────
  static final BorderRadius smAll = BorderRadius.circular(sm);
  static final BorderRadius baseAll = BorderRadius.circular(base);
  static final BorderRadius xlAll = BorderRadius.circular(xl);
  static final BorderRadius sheetTop = const BorderRadius.only(
    topLeft: Radius.circular(25.0),
    topRight: Radius.circular(25.0),
  );
}
