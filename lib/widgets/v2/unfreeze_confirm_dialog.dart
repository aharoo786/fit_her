import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shared "Resume your plan now?" confirmation.
///
/// Originally written inline inside profile_screen_user.dart's
/// _showUnfreezeDialog(). Pulled out here so the paid home screen's new
/// "Unfreeze" link (on the "Classes are paused..." line, added per
/// Shaista's request) can show the exact same day-refund explanation
/// instead of a second, drifting copy of it. The Profile screen's own
/// dialog is left as-is for now (already verified working) -- this is
/// additive, not a refactor of tested code.
///
/// Returns true via Get.back(result: true) if the user confirms "Unfreeze
/// now", or false if they tap "Not yet" / dismiss.
class UnfreezeConfirmDialog extends StatelessWidget {
  final DateTime? resumeOn;

  const UnfreezeConfirmDialog({super.key, this.resumeOn});

  static const _kAccent = Color(0xFF6DC55A);
  static const _kTextMuted = Color(0xFF5A7258);

  String _formatShortDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final resumeText = resumeOn != null
        ? " It was already due to resume on ${_formatShortDate(resumeOn!)}."
        : '';
    return AlertDialog(
      title: const Text('Resume your plan now?'),
      content: Text(
        "You'll pick up right where you left off -- classes and your "
        "diet plan become active again immediately.$resumeText Any "
        // Verified against the actual backend mechanism (applyUnfreeze in
        // planFreezeController.js): freezing adds the full selected days
        // to your plan's end date right away; unfreezing early gives back
        // only the days you didn't end up using, pulling your end date
        // back by that unused amount -- so you're only ever charged,
        // day-for-day, for the pause you actually took.
        "days you don't end up using are added back onto your plan's "
        "end date, and stay available if you want to freeze again "
        "later.",
        style: const TextStyle(fontSize: 13, color: _kTextMuted),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Not yet'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _kAccent,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Get.back(result: true),
          child: const Text(
            'Unfreeze now',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
