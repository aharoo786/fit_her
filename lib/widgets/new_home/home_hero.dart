import 'package:flutter/material.dart';

import '../../data/services/cycle_engine.dart';
import 'hero_coming_up_row.dart';
import 'hero_greeting_block.dart';
import 'hero_live_section.dart';
import 'hero_top_bar.dart';

/// H-35 hero. Layered to match the HTML reference:
///   background: radial-gradient(ellipse 130% 90% at 105% -5%,
///               rgba(70,130,60,0.3) 0%, transparent 55%), #163220;
///   + a faint 220×220 accent ring at top:-70 right:-50, clipped by corners.
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
    const bg = Color(0xFF163220);
    const accent = Color(0xFF6DC55A);

    const radius = BorderRadius.only(
      bottomLeft: Radius.circular(36),
      bottomRight: Radius.circular(36),
    );

    return Container(
      decoration: const BoxDecoration(
        color: bg,
        borderRadius: radius,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
          child: Stack(
            children: [
              // 1. Radial-gradient overlay. Alpha-only fade so the bg below
              // shows through naturally — matches CSS "…,#163220" stacking.
              const Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(1.1, -1.05),
                        radius: 1.3,
                        colors: [
                          Color.fromRGBO(70, 130, 60, 0.30),
                          Color.fromRGBO(70, 130, 60, 0.00),
                        ],
                        stops: [0.0, 0.55],
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
              // 3. Content — the one non-positioned child, so the Stack sizes
              // to its height. SizedBox(width: double.infinity) guards against
              // the loose-constraint collapse we hit previously.
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
  }
}
