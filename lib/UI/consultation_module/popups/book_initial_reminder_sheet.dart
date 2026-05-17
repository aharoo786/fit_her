import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/controllers/consultation_controller/consultation_controller.dart';
import '../../../widgets/v2/v2_bottom_sheet.dart';
import '../../../widgets/v2/v2_buttons.dart';

/// `POPUP_BOOK_INITIAL_REMINDER` — fires every 2 days while the user
/// hasn't booked their initial consultation, capped at 5 nags. After
/// 5 dismissals the eligibility helper opens a BOOKING_REMINDER_5X
/// escalation for admin manual outreach.
class BookInitialReminderSheet extends StatelessWidget {
  static const String variable = 'POPUP_BOOK_INITIAL_REMINDER';

  /// Caller passes a `onBookNow` that opens the actual booking sheet
  /// (`BookConsultationSheet.show(...)` from popup #1). We don't import
  /// it here to keep file dependencies tight.
  final VoidCallback onBookNow;

  const BookInitialReminderSheet({Key? key, required this.onBookNow})
      : super(key: key);

  static Future<void> show({required VoidCallback onBookNow}) {
    return V2BottomSheet.show(
      title: "Let's get you started",
      child: BookInitialReminderSheet(onBookNow: onBookNow),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ConsultationController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "You haven't booked your first consultation yet. Your dietitian needs ~20 minutes to build a plan that actually fits you — pick a slot that works.",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Color(0xFF7A8C78),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        V2PrimaryButton(
          label: 'Book now',
          onPressed: () {
            ctrl.completePopup(variable);
            Get.back<dynamic>();
            onBookNow();
          },
        ),
        const SizedBox(height: 8),
        V2GhostButton(
          label: 'Maybe later',
          onPressed: () {
            ctrl.dismissPopup(variable);
            Get.back<dynamic>();
          },
        ),
      ],
    );
  }
}
