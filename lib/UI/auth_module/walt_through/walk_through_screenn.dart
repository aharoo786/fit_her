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

  // Real cycle proportions matching CyclePhaseCalculator's 0.18/0.46/0.57
  // boundaries (founder Q5 fix vs the mockup's eyeballed wedges):
  //   menstrual  0–18%   →   0° →  65°
  //   follicular 18–46%  →  65° → 165°
  //   ovulation  46–57%  → 165° → 205°
  //   luteal     57–100% → 205° → 360°
  // Duplicate stops produce hard arc boundaries.
  static const List<double> _wheelStops = [
    0.0, 0.1806,
    0.1806, 0.4583,
    0.4583, 0.5694,
    0.5694, 1.0,
  ];
  static const List<Color> _wheelColors = [
    _menstrualArc, _menstrualArc,
    _follicularArc, _follicularArc,
    _ovulationArc, _ovulationArc,
    _lutealArc, _lutealArc,
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
  // at the midpoint angle of each arc (real-cycle proportions per Q5).
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
            child: Center(
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
          ),

          // Phase labels at midpoint angles of each real-proportion arc.
          //   menstrual mid  =  32.5° (between   0° and  65°)
          //   follicular mid = 115°  (between  65° and 165°)
          //   ovulation mid  = 185°  (between 165° and 205°)
          //   luteal mid     = 282.5°(between 205° and 360°)
          _positionPill(
            angleDeg: 32.5,
            label: 'MENSTRUAL',
            color: _menstrualLabel,
          ),
          _positionPill(
            angleDeg: 115.0,
            label: 'FOLLICULAR',
            color: _follicularLabel,
          ),
          _positionPill(
            angleDeg: 185.0,
            label: 'OVULATION',
            color: _ovulationLabel,
          ),
          _positionPill(
            angleDeg: 282.5,
            label: 'LUTEAL',
            color: _lutealLabel,
          ),
        ],
      ),
    );
  }

  Widget _positionPill({
    required double angleDeg,
    required String label,
    required Color color,
  }) {
    // Place the pill's centre on the wheel's outer rim (radius 140).
    // Angle is measured clockwise from the 12 o'clock (top) position,
    // so x = sin θ and y = -cos θ.
    final theta = angleDeg * math.pi / 180.0;
    final dx = 140.w * math.sin(theta);
    final dy = -140.w * math.cos(theta);

    return Transform.translate(
      offset: Offset(dx, dy),
      child: _buildPhasePill(label, color),
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
