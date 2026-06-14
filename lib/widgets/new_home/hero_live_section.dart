import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../UI/plans_module/all_plans.dart';
import '../../data/controllers/auth_controller/auth_controller.dart';

class HeroLiveSection extends StatelessWidget {
  const HeroLiveSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF6DC55A);
    final w = MediaQuery.of(context).size.width;
    final double hPad = (w * 22 / 414).clamp(16.0, 24.0);
    return Padding(
      // Bottom was 0 because HeroComingUpRow used to handle the spacing
      // below the LIVE block. With upcomingSlots empty (HeroComingUpRow
      // self-hides), "Try free →" sat flush against the hero's bottom
      // curve. 28 of green below the button gives the CTA real breathing
      // room. Keep the inline upcoming spacing handled by HeroComingUpRow
      // itself when slots come back.
      padding: EdgeInsets.fromLTRB(hPad, 14, hPad, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // LIVE pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE24B4A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SizedBox(
                      width: 5,
                      height: 5,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '34 women · training now',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Obx(() {
            final activated =
                Get.find<AuthController>().trialActivated.value;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Flexible(
                        child: Text(
                          'Strength Training',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Lock emoji only when trial isn't activated yet.
                      if (!activated) ...const [
                        SizedBox(width: 7),
                        Opacity(
                          opacity: 0.55,
                          child: Text('🔒',
                              style: TextStyle(fontSize: 13)),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Pre-trial: "Try free →" (visual only, no nav — the main
                // Start-trial action lives on TrialCtaCard below).
                // Post-activation: "Explore more plans" → OurPlansScreen.
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: activated
                      ? () => Get.to<dynamic>(() => OurPlansScreen())
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withOpacity(0.33),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Text(
                      activated ? 'Explore more plans' : 'Try free →',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
