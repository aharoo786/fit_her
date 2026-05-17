import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/controllers/consultation_controller/consultation_controller.dart';
import '../../../widgets/v2/v2_bottom_sheet.dart';
import '../../../widgets/v2/v2_buttons.dart';

/// `POPUP_INACTIVITY_REMINDER` — workout/combined plans only, fires when
/// the user hasn't joined any session for 3+ consecutive days. Per
/// Section 5: notification only — session access is NEVER frozen.
class InactivityReminderSheet extends StatelessWidget {
  static const String variable = 'POPUP_INACTIVITY_REMINDER';

  final VoidCallback onViewClasses;

  const InactivityReminderSheet({Key? key, required this.onViewClasses})
      : super(key: key);

  static Future<void> show({required VoidCallback onViewClasses}) {
    return V2BottomSheet.show(
      title: 'We miss you',
      child: InactivityReminderSheet(onViewClasses: onViewClasses),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ConsultationController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "It's been a few days since your last session. No pressure — your access stays active. Want to peek at today's classes?",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Color(0xFF7A8C78),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        V2PrimaryButton(
          label: "View today's classes",
          onPressed: () {
            ctrl.completePopup(variable);
            Get.back<dynamic>();
            onViewClasses();
          },
        ),
        const SizedBox(height: 8),
        V2GhostButton(
          label: 'Not today',
          onPressed: () {
            ctrl.dismissPopup(variable);
            Get.back<dynamic>();
          },
        ),
      ],
    );
  }
}
