import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/controllers/consultation_controller/consultation_controller.dart';
import '../../../widgets/custom_button.dart';

/// `POPUP_DAILY_LOG_REMINDER` — fires after 2+ consecutive days with no
/// daily check-in. Per Decision 1, this is the ONE pop-up rendered in
/// the LEGACY visual style (it lives on the legacy free-tier home and
/// will be sunset alongside it). No V2 widgets — uses CustomButton +
/// Theme.textTheme so it visually blends with the surrounding screen.
class DailyLogReminderSheet extends StatelessWidget {
  static const String variable = 'POPUP_DAILY_LOG_REMINDER';

  /// Caller hooks the navigation to the existing daily-checkin tile.
  final VoidCallback onLogNow;

  const DailyLogReminderSheet({Key? key, required this.onLogNow})
      : super(key: key);

  /// Uses the legacy bottom-sheet shape (top-radius 20, white bg) — see
  /// review_bottom_sheet.dart for the same convention.
  static Future<void> show({required VoidCallback onLogNow}) {
    return Get.bottomSheet<void>(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: DailyLogReminderSheet(onLogNow: onLogNow),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final ctrl = Get.find<ConsultationController>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.keyboard_arrow_down, size: 32),
        const SizedBox(height: 8),
        Text(
          "Don't forget to log today",
          style: theme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          "It's been a couple of days since your last check-in. Logging mood, energy and water keeps your insights accurate.",
          style: theme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        CustomButton(
          text: 'Log now',
          onPressed: () {
            ctrl.completePopup(variable);
            Get.back<dynamic>();
            onLogNow();
          },
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            ctrl.dismissPopup(variable);
            Get.back<dynamic>();
          },
          child: Text(
            'Dismiss',
            style: theme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
