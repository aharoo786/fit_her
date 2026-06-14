import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/controllers/cycle_theme_controller/cycle_theme_controller.dart';
import '../../data/services/cycle_engine.dart';
import 'hero_coming_up_row.dart';
import 'hero_greeting_block.dart';
import 'hero_live_section.dart';
import 'hero_top_bar.dart';
import 'phase_theme.dart';

/// Hero widget used by both paid and unpaid home screens.
/// Colors are read from [CycleThemeController] — a globally registered
/// GetX controller that restores the last known phase from SharedPreferences
/// on `onInit()`. This means the correct phase colors are displayed on the
/// very first frame, with no green→phase flicker while the API call is in
/// flight. The [cycleInfo] param is still used for the day label and phase
/// text in [HeroGreetingBlock]; it just no longer drives colors.
class HomeHero extends StatelessWidget {
  final String? firstName;
  final CycleInfo? cycleInfo;
  final List<UpcomingSlot> upcomingSlots;

  const HomeHero({
    Key? key,
    this.firstName,
    this.cycleInfo,
    this.upcomingSlots = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final phaseTheme = Get.find<CycleThemeController>().theme.value;
      final bg = phaseTheme.heroBackground;
      final accent = phaseTheme.accent;

    const radius = BorderRadius.only(
      bottomLeft: Radius.circular(36),
      bottomRight: Radius.circular(36),
    );

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
          child: Stack(
            children: [
              // 1. Radial-gradient overlay tinted with phase accent.
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(1.1, -1.05),
                        radius: 1.3,
                        colors: [
                          accent.withOpacity(0.30),
                          accent.withOpacity(0.00),
                        ],
                        stops: const [0.0, 0.55],
                      ),
                    ),
                  ),
                ),
              ),
              // 2. Faint accent ring (clipped by the hero's rounded corners).
              Positioned(
                top: -70,
                right: -50,
                child: IgnorePointer(
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accent.withOpacity(0.07),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              // 3. Content
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const HeroTopBar(),
                    HeroGreetingBlock(
                      firstName: firstName,
                      cycleInfo: cycleInfo,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 22),
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            accent.withOpacity(0.18),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const HeroLiveSection(),
                    HeroComingUpRow(upcoming: upcomingSlots),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    }); // closes Obx
  }
}
