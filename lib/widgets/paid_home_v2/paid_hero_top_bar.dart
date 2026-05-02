import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../UI/dashboard_module/profile_screen/profile_screen_user.dart';
import '../new_home/phase_theme.dart';

/// H-01 top bar, right-anchored: bell (with red dot) + avatar.
/// No fake "9:41" — the phone OS renders the real clock above the status bar.
/// Top padding includes `MediaQuery.padding.top` so bell + avatar clear the
/// system UI since the hero paints edge-to-edge under the status bar.
class PaidHeroTopBar extends StatelessWidget {
  final PhaseTheme theme;
  final String initial;

  const PaidHeroTopBar({
    Key? key,
    required this.theme,
    required this.initial,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final topInset = mq.padding.top + 14;
    return Padding(
      padding: EdgeInsets.fromLTRB(22, topInset, 22, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(
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
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE24B4A),
                    shape: BoxShape.circle,
                    // Border matches hero bg so the dot looks "cut" into the
                    // bell circle, not floating on top of it.
                    border: Border.all(
                      color: theme.heroBackground,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            // Same navigation the old UserHomeScreen uses at
            // lib/widgets/user_home_screen.dart:373. Logout lives inside
            // ProfileScreenUser (at profile_screen_user.dart:47).
            onTap: () => Get.to(() => ProfileScreenUser()),
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.accent,
              ),
              child: Text(
                initial,
                style: const TextStyle(
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
