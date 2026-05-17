import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/controllers/consultation_controller/consultation_controller.dart';
import '../../../widgets/v2/v2_bottom_sheet.dart';

/// `POPUP_EARLY_CHECKIN` — fires Day 3-4 after a plan is delivered.
/// Three quick-tap options, no primary CTA — taps directly close + route.
class EarlyCheckinSheet extends StatelessWidget {
  static const String variable = 'POPUP_EARLY_CHECKIN';

  /// Caller hooks for the two follow-up routes.
  final VoidCallback onOpenChat;
  final VoidCallback onOpenFaq;

  const EarlyCheckinSheet({
    Key? key,
    required this.onOpenChat,
    required this.onOpenFaq,
  }) : super(key: key);

  static Future<void> show({
    required VoidCallback onOpenChat,
    required VoidCallback onOpenFaq,
  }) {
    return V2BottomSheet.show(
      title: "How's your plan going?",
      child: EarlyCheckinSheet(onOpenChat: onOpenChat, onOpenFaq: onOpenFaq),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ConsultationController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Tell us in one tap — we use this to know who needs help right now.",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: Color(0xFF7A8C78),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        _CheckinOption(
          icon: Icons.thumb_up_alt_rounded,
          label: 'Going well',
          color: const Color(0xFF6DC55A),
          onTap: () {
            ctrl.completePopup(variable, metadata: {'response': 'going_well'});
            Get.back<dynamic>();
          },
        ),
        const SizedBox(height: 10),
        _CheckinOption(
          icon: Icons.chat_bubble_rounded,
          label: 'Having issues',
          color: const Color(0xFFFAC775),
          onTap: () {
            ctrl.completePopup(variable, metadata: {'response': 'having_issues'});
            Get.back<dynamic>();
            onOpenChat();
          },
        ),
        const SizedBox(height: 10),
        _CheckinOption(
          icon: Icons.help_outline_rounded,
          label: 'Need help',
          color: const Color(0xFFFF8A8A),
          onTap: () {
            ctrl.completePopup(variable, metadata: {'response': 'need_help'});
            Get.back<dynamic>();
            onOpenFaq();
          },
        ),
      ],
    );
  }
}

class _CheckinOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CheckinOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.32)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A3A22),
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
