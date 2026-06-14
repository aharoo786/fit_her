import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../values/my_imgs.dart';
import '../login/login.dart';
import '../sign_up_screen/signup_screen_user.dart';

/// Sprint 1 / SA-00 V3 Refined — Welcome / Get Started landing.
///
/// Class name + constructor signature are preserved so existing callers
/// (splash.dart, app_link_handler.dart, auth_controller.dart) keep
/// working unchanged. Only the widget tree was replaced.
class WalkThroughScreen extends StatelessWidget {
  const WalkThroughScreen({Key? key}) : super(key: key);

  // ── V3 design tokens ───────────────────────────────────────────────────
  // Sourced from new screens/S01_Welcome_V3_Refined.html.
  static const Color _bgTop = Color(0xFFFAFDF9);
  static const Color _bgBottom = Color(0xFFEAF7E4);
  static const Color _textDark = Color(0xFF163220);
  static const Color _textSub = Color(0xFF5A7A56);
  static const Color _primaryGreen = Color(0xFF6DC55A);

  // Cycle-phase colors — wheel arcs + matching pill text colors.
  static const Color _menstrualArc = Color(0xFFFF8A8A);
  static const Color _follicularArc = Color(0xFF6DC55A);
  static const Color _ovulationArc = Color(0xFFA8F0C0);
  static const Color _lutealArc = Color(0xFFFAC775);
  static const Color _menstrualLabel = Color(0xFFC45A5A);
  static const Color _follicularLabel = Color(0xFF3A8A3A);
  static const Color _ovulationLabel = Color(0xFF5A8C66);
  static const Color _lutealLabel = Color(0xFF9C7430);

  // Arc wedges match S01_Welcome_V3_Refined.html exactly. The HTML uses
  // `conic-gradient(from -90deg, …)` so pink/red starts at 9 o'clock and
  // sweeps clockwise. Flutter's SweepGradient CLAMPS angles outside the
  // [startAngle, endAngle] range (doesn't wrap), so we can't just rotate
  // the startAngle — we keep it at -π/2 (12 o'clock) and instead shift
  // the colour stops so each phase lands in the right visual quadrant:
  //
  //   gradient position → visual angle (clockwise from 12 o'clock)
  //   0.00 → 0.25         12 → 3 o'clock         → green  (follicular)
  //   0.25 → 0.3056       3 → just past 3        → mint   (ovulation, 5.55%)
  //   0.3056 → 0.75       rest of bottom + left  → orange (luteal, 44.44%)
  //   0.75 → 1.00         9 → 12 o'clock         → pink   (menstrual, 25%)
  // Duplicate stops produce hard arc boundaries.
  static const List<double> _wheelStops = [
    0.0, 0.25,
    0.25, 0.3056,
    0.3056, 0.75,
    0.75, 1.0,
  ];
  static const List<Color> _wheelColors = [
    _follicularArc, _follicularArc,
    _ovulationArc, _ovulationArc,
    _lutealArc, _lutealArc,
    _menstrualArc, _menstrualArc,
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: _bgTop,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgTop, _bgBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Brand mark — small wordmark sitting at the top.
              Padding(
                padding: EdgeInsets.only(top: 16.h),
                child: Opacity(
                  opacity: 0.92,
                  child: Image.asset(
                    MyImgs.fitHerLogo,
                    height: 18.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Cycle wheel — vertically centred in remaining space.
              Expanded(
                child: Center(child: _buildWheel()),
              ),

              // Bottom body block — headline, sub-copy, CTAs.
              Padding(
                padding: EdgeInsets.fromLTRB(32.w, 0, 32.w, 48.h),
                child: Column(
                  children: [
                    Text(
                      'Welcome to your rhythm.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSerifDisplay(
                        textStyle: TextStyle(
                          fontSize: 38.sp,
                          fontWeight: FontWeight.w400,
                          color: _textDark,
                          letterSpacing: -1.14, // -0.03em × 38
                          height: 1.05,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 280.w),
                      child: Text(
                        'Made for every part of you.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: _textSub,
                          height: 1.55,
                        ),
                      ),
                    ),
                    SizedBox(height: 28.h),
                    _buildPrimaryButton(),
                    SizedBox(height: 10.h),
                    _buildSecondaryButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Cycle wheel ────────────────────────────────────────────────────────
  // 280-px conic ring + 244-px white inner mask + 4 phase pills positioned
  // to match S01_Welcome_V3_Refined.html (top/right/bottom/left offsets,
  // not on a uniform polar rim).
  Widget _buildWheel() {
    return SizedBox(
      // 280 wheel + 40-px buffer on each side so the pills can extend
      // past the arc rim without being clipped by Stack bounds.
      width: 320.w,
      height: 320.w,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: 280.w,
            height: 280.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // startAngle stays at -π/2 (12 o'clock); the visual rotation
              // to match CSS `from -90deg` is encoded in _wheelStops instead.
              // See the _wheelStops comment for the full quadrant mapping.
              gradient: const SweepGradient(
                startAngle: -math.pi / 2,
                endAngle: 3 * math.pi / 2,
                stops: _wheelStops,
                colors: _wheelColors,
              ),
              boxShadow: [
                BoxShadow(
                  color: _primaryGreen.withValues(alpha: 0.15),
                  offset: const Offset(0, 30),
                  blurRadius: 60,
                ),
                BoxShadow(
                  color: _textDark.withValues(alpha: 0.08),
                  offset: const Offset(0, 12),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Inner white mask + "28 DAYS · YOUR CYCLE"
                Center(
                  child: Container(
                    width: 244.w,
                    height: 244.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _bgTop,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '28',
                            style: GoogleFonts.fraunces(
                              textStyle: TextStyle(
                                fontSize: 60.sp,
                                fontWeight: FontWeight.w300,
                                color: _textDark,
                                letterSpacing: -2.4, // -0.04em × 60
                                height: 1.0,
                              ),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'DAYS · YOUR CYCLE',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                              color: _textSub,
                              letterSpacing: 1.62, // 0.18em × 9
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Phase pills — positioned to match HTML .pl-1..4 exactly.
                // pl-1 Menstrual: top:8 inside wheel, centred horizontally.
                Positioned(
                  top: 8.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _buildPhasePill('MENSTRUAL', _menstrualLabel),
                  ),
                ),
                // pl-2 Follicular: right:-12 (sticks out past wheel), centred vertically.
                Positioned(
                  right: -12.w,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _buildPhasePill('FOLLICULAR', _follicularLabel),
                  ),
                ),
                // pl-3 Ovulation: bottom:8 inside wheel, centred horizontally.
                Positioned(
                  bottom: 8.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _buildPhasePill('OVULATION', _ovulationLabel),
                  ),
                ),
                // pl-4 Luteal: left:-8 (sticks out past wheel), centred vertically.
                Positioned(
                  left: -8.w,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _buildPhasePill('LUTEAL', _lutealLabel),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhasePill(String label, Color color) {
    // Solid 85% white instead of CSS backdrop-blur (Q6: skip blur for
    // mid-range Android performance).
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 9.sp,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 1.35, // 0.15em × 9
        ),
      ),
    );
  }

  // ── Primary CTA → existing destination preserved ───────────────────────
  Widget _buildPrimaryButton() {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _primaryGreen.withValues(alpha: 0.32),
              offset: const Offset(0, 8),
              blurRadius: 24,
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.symmetric(vertical: 17.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () {
            Get.to(() => SignUpNewUser());
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Get started',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '→',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Secondary CTA → existing destination preserved ─────────────────────
  Widget _buildSecondaryButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: _textSub,
          padding: EdgeInsets.symmetric(vertical: 14.h),
        ),
        onPressed: () {
          Get.to(() => Login());
        },
        child: Text(
          'I already have an account',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
