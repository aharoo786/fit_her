import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../UI/dashboard_module/home_screen/notification_screen.dart';
import '../../UI/dashboard_module/profile_screen/profile_screen_user.dart';
import '../../data/controllers/auth_controller/auth_controller.dart';
import '../../data/controllers/home_controller/home_controller.dart';

/// Hero top bar for H-35: bell + tappable avatar on the right.
/// Avatar opens the same ProfileScreenUser used by the paid home (logout
/// lives inside that screen).
class HeroTopBar extends StatelessWidget {
  const HeroTopBar({Key? key}) : super(key: key);

  String get _initial {
    if (Get.isRegistered<AuthController>()) {
      final name =
          Get.find<AuthController>().logInUser?.firstName?.trim() ?? '';
      if (name.isNotEmpty) return name[0].toUpperCase();
    }
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    // Shared hPad formula — matches HeroGreetingBlock / HeroLiveSection, so
    // the avatar's right edge lines up with the greeting's right edge and
    // the greeting's left edge sits on the same vertical grid.
    final double hPad = (mq.size.width * 22 / 414).clamp(16.0, 24.0);
    // Hero extends behind the status bar now (HTML-faithful edge-to-edge).
    // Push the bell + avatar below the system UI so they don't overlap.
    final double topInset = mq.padding.top + 14;
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, topInset, hPad, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (Get.isRegistered<HomeController>()) {
                Get.find<HomeController>().showDotHome.value = false;
              }
              Get.to(() => const NotificationScreen());
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.07),
                  ),
                  child: const Text('🔔', style: TextStyle(fontSize: 13)),
                ),
                Positioned(
                  top: 1,
                  right: 1,
                  child: Obx(() {
                    final show = Get.isRegistered<HomeController>()
                        ? Get.find<HomeController>().showDotHome.value
                        : false;
                    if (!show) return const SizedBox.shrink();
                    return const _NotificationDot();
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Get.to(() => ProfileScreenUser()),
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF6DC55A),
              ),
              child: Text(
                _initial,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationDot extends StatelessWidget {
  const _NotificationDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: const Color(0xFFE24B4A),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF163220), width: 2),
      ),
    );
  }
}
