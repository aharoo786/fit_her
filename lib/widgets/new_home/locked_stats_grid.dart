import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/controllers/auth_controller/auth_controller.dart';

/// Water + Sleep two-tile row beneath the locked insight card.
/// • Pre-activation: dimmed to 0.45 opacity, padlock value, no real numbers.
/// • Post-activation: full opacity, zero-state values ("0 mL" / "0h") so
///   the user sees real tracking surfaces ready to take data.
class LockedStatsGrid extends StatelessWidget {
  const LockedStatsGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final activated =
          Get.find<AuthController>().trialActivated.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Opacity(
          // 1.0 once unlocked so the tiles read as live tracking widgets.
          opacity: activated ? 1.0 : 0.45,
          child: Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: '💧 Water',
                  value: activated ? '0 mL' : '🔒',
                  unlocked: activated,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatTile(
                  label: '🌙 Sleep',
                  value: activated ? '0h' : '🔒',
                  unlocked: activated,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final bool unlocked;
  const _StatTile({
    required this.label,
    required this.value,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD8EDD4), width: 1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF163220).withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: unlocked
                  ? const Color(0xFF4A6B4A)
                  : const Color(0xFF9AB09A),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: unlocked ? 16 : 18,
              fontWeight: FontWeight.w800,
              color: unlocked
                  ? const Color(0xFF163220)
                  : const Color(0xFF9AB09A),
            ),
          ),
        ],
      ),
    );
  }
}
