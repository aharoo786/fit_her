import 'dart:async';
import 'package:fitness_zone_2/UI/auth_module/walt_through/walk_through_screenn.dart';
import 'package:fitness_zone_2/data/services/notification_scheduler.dart';
import 'package:fitness_zone_2/helper/notification_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../data/api_provider/app_link_handler.dart';
import '../../data/controllers/auth_controller/auth_controller.dart';
import '../../values/constants.dart';
import '../../values/my_imgs.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // ── Colors from Light Green HTML variant ──
  static const Color _bg = Color(0xFFEAF7E4);
  static const Color _circleColor = Color(0xFFC8E8C0);
  static const Color _dividerColor = Color(0xFFC8E8C0);
  static const Color _textDark = Color(0xFF163220);
  static const Color _textSub = Color(0xFF5A7A56);
  static const Color _versionColor = Color(0xFF9AB09A);
  static const Color _green = Color(0xFF6DC55A);

  // Cycle dot colors
  static const List<Color> _dotColors = [
    Color(0xFFFF8A8A), // pink
    Color(0xFF6DC55A), // green
    Color(0xFFA8F0C0), // mint
    Color(0xFFFAC775), // gold
  ];

  // ── Animation controllers ──
  late final AnimationController _circleController;
  late final AnimationController _logoController;
  late final AnimationController _dividerController;
  late final AnimationController _taglineController;
  late final AnimationController _subtitleController;
  late final AnimationController _dotsController;
  late final AnimationController _loaderController;

  AuthController authController = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _setupAnimations();
    _runAnimationSequence();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && Get.context != null) {
        AppLinkHandler().init(Get.context!);
      }
    });

    // ── Original navigation logic ──
    NotificationServices().requestNotificationPermission();
    NotificationServices().firebaseInit(Get.context!);
    NotificationScheduler.initialize();

    Timer(const Duration(seconds: 3), () async {
      var share = authController.sharedPreferences;

      if (share.getString(Constants.email) == null ||
          share.getString(Constants.password) == null ||
          share.getString(Constants.loginAsa) == null) {
        Get.offAll(() => const WalkThroughScreen());
      } else {
        if (share.getString(Constants.password)!.isEmpty ||
            share.getString(Constants.password) == "google" ||
            share.getString(Constants.password) == "apple") {
          Get.find<AuthController>().signInUsingGoogle(
            share.getString(Constants.email) ?? "",
            "",
            "",
            userType: share.getString(Constants.loginAsa),
            fromLocal: true,
          );
        } else {
          Get.find<AuthController>().login(
            userType: share.getString(Constants.loginAsa),
            email: share.getString(Constants.email),
            password: share.getString(Constants.password),
          );
        }
      }
    });
  }

  void _setupAnimations() {
    // 1. Circles scale in (0–600ms)
    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // 2. Logo fade + bounce (200–900ms)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // 3. Divider grows from center (600–1000ms)
    _dividerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // 4. Tagline slides up (800–1300ms)
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // 5. Subtitle fades in (1100–1500ms)
    _subtitleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // 6. Dots pop in one by one (1300–1900ms)
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // 7. Loader pulses (1600ms onward, loops)
    _loaderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  void _runAnimationSequence() {
    _circleController.forward();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _logoController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _dividerController.forward();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _taglineController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) _subtitleController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1300), () {
      if (mounted) _dotsController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) _loaderController.repeat(reverse: true);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Get.log("in app resume");
    }
  }

  @override
  void dispose() {
    _circleController.dispose();
    _logoController.dispose();
    _dividerController.dispose();
    _taglineController.dispose();
    _subtitleController.dispose();
    _dotsController.dispose();
    _loaderController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Status-bar styling — declarative AnnotatedRegion replaces the
    // previous imperative `SystemChrome.setSystemUIOverlayStyle` call
    // that was here. The imperative version ran on every animation tick
    // (build is called multiple times during the 1.6s splash sequence)
    // and pushed `statusBarColor: _bg` (#EAF7E4 mint cream) to the OS
    // chrome layer. That value persisted at the OS level after splash
    // unmounted — overriding downstream screens' AnnotatedRegions on
    // Android and producing the "sticky mint band" at the top of every
    // subsequent screen. AnnotatedRegion auto-cleans up on unmount, so
    // PaidHomeV2's transparent overlay can take over cleanly afterward.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        // Transparent strip — splash bg paints under it (cream `_bg`).
        statusBarColor: Colors.transparent,
        // Android: dark icons render visible on the cream background.
        statusBarIconBrightness: Brightness.dark,
        // iOS: `Brightness.light` reads as "the surface is light" —
        // system renders status-bar content in dark/black. Inverted
        // naming relative to Android.
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // ── Background circles ──
              _buildCircles(),

              // ── Main content ──
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 22.w),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildLogo(),
                              SizedBox(height: 16.h),
                              _buildDivider(),
                              SizedBox(height: 16.h),
                              _buildTagline(),
                              SizedBox(height: 8.h),
                              _buildSubtitle(),
                              SizedBox(height: 20.h),
                              _buildCycleDots(),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Footer
                    Padding(
                      padding: EdgeInsets.only(bottom: 28.h),
                      child: Column(
                        children: [
                          _buildLoader(),
                          SizedBox(height: 7.h),
                          _buildVersionText(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Background decorative circles ──
  Widget _buildCircles() {
    return AnimatedBuilder(
      animation: _circleController,
      builder: (context, _) {
        final scale = CurvedAnimation(
          parent: _circleController,
          curve: Curves.easeOutBack,
        ).value;
        return Stack(
          children: [
            Positioned(
              top: -100.h,
              right: -80.w,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 280.w,
                  height: 280.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _circleColor.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -55.h,
              left: -55.w,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 190.w,
                  height: 190.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _circleColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Logo with fade + elastic bounce ──
  Widget _buildLogo() {
    final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );
    final bounceAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, _) {
        return Opacity(
          opacity: fadeAnim.value,
          child: Transform.scale(
            scale: bounceAnim.value,
            child: Image.asset(
              MyImgs.fitHerLogo,
              width: 180.w,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }

  // ── Divider grows from center ──
  Widget _buildDivider() {
    final widthAnim = CurvedAnimation(
      parent: _dividerController,
      curve: Curves.easeOutCubic,
    );

    return AnimatedBuilder(
      animation: _dividerController,
      builder: (context, _) {
        return Container(
          width: 32.w * widthAnim.value,
          height: 2.h,
          decoration: BoxDecoration(
            color: _dividerColor,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      },
    );
  }

  // ── Tagline slides up + fades in ──
  Widget _buildTagline() {
    final slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOutCubic),
    );
    final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeIn),
    );

    return SlideTransition(
      position: slideAnim,
      child: FadeTransition(
        opacity: fadeAnim,
        child: Text(
          'Your hormonal\nintelligence engine',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: _textDark,
            height: 1.45,
          ),
        ),
      ),
    );
  }

  // ── Subtitle fades in ──
  Widget _buildSubtitle() {
    final fadeAnim = CurvedAnimation(
      parent: _subtitleController,
      curve: Curves.easeIn,
    );

    return FadeTransition(
      opacity: fadeAnim,
      child: Text(
        'Built around every phase of you',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11.sp,
          fontWeight: FontWeight.w300,
          color: _textSub,
          height: 1.6,
        ),
      ),
    );
  }

  // ── 4 cycle dots pop in one by one ──
  Widget _buildCycleDots() {
    return AnimatedBuilder(
      animation: _dotsController,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (i) {
            final start = i * 0.2;
            final end = (start + 0.4).clamp(0.0, 1.0);
            final dotScale = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _dotsController,
                curve: Interval(start, end, curve: Curves.elasticOut),
              ),
            );
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Transform.scale(
                scale: dotScale.value,
                child: Container(
                  width: 7.w,
                  height: 7.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _dotColors[i],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // ── Loader: 3 pulsing dots ──
  Widget _buildLoader() {
    final pulseAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _loaderController, curve: Curves.easeInOut),
    );

    return AnimatedBuilder(
      animation: _loaderController,
      builder: (context, _) {
        final pulse = pulseAnim.value;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _green.withValues(alpha: pulse),
              ),
            ),
            SizedBox(width: 6.w),
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _green.withValues(alpha: pulse * 0.5),
              ),
            ),
            SizedBox(width: 6.w),
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _circleColor.withValues(alpha: pulse),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Version text ──
  Widget _buildVersionText() {
    final versionFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loaderController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    return AnimatedBuilder(
      animation: _loaderController,
      builder: (context, _) {
        return Opacity(
          opacity: versionFade.value.clamp(0.0, 1.0),
          child: Text(
            'V 2.0 \u00B7 LAUNCHING NOW',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 9.sp,
              letterSpacing: 0.1 * 9.sp,
              color: _versionColor,
            ),
          ),
        );
      },
    );
  }
}
