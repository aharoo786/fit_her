import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Floating button per Decision 8: bottom-right above bottom nav, paid
/// surfaces only (Home, Programme, Nutrition, Progress), hidden during
/// full-screen modals (video call, payment, screeners). Wraps the page
/// body in a Stack — drop one of these at the root of each paid screen.
///
/// Visibility is governed by `showOnRoutes` (allow-list) and a global
/// `MedicalConcernFAB.suppress` static flag callers can flip when they
/// open a fullscreen modal.
///
///   MedicalConcernFAB(
///     child: const PaidHomeScreenV2(),
///     onTap: () => V2BottomSheet.show(child: const MedicalConcernSheet()),
///   )
class MedicalConcernFAB extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool visible;

  /// Caller-flipped suppression — set true while pushing a fullscreen
  /// modal (video call, payment WebView, screener) and back to false
  /// when it pops. Avoids covering OS-critical UI.
  static final RxBool suppress = false.obs;

  static const Color _bg = Color(0xFFE24B4A); // V2 live-red
  static const Color _ring = Color(0x33E24B4A);

  const MedicalConcernFAB({
    Key? key,
    required this.child,
    required this.onTap,
    this.visible = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(
          right: 16,
          // 84 ≈ bottom nav height + clearance. Adjust per nav bar in
          // the screen that hosts the FAB if needed.
          bottom: 84,
          child: Obx(() {
            if (!visible || suppress.value) return const SizedBox.shrink();
            return Material(
              elevation: 0,
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: _bg,
                    boxShadow: [
                      BoxShadow(
                        color: _ring,
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.medical_services_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
