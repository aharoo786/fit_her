import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shared cancellation dialog — used by both the Profile screen's real
/// subscription card (profile_screen_user.dart, the one users actually
/// see) and the V2 assigned-plan card (v2_assigned_plan_card.dart).
///
/// Was originally written as a private class inside v2_assigned_plan_card
/// only — pulled out to here once it became clear that widget was never
/// actually wired into the live Profile screen, so profile_screen_user.dart
/// needed its own "Cancel plan" entry point using the same dialog rather
/// than a second, drifting copy of it.
///
/// Both a category (single-select, for clean analytics/reporting) and a
/// written comment (free text, for the actual verbatim feedback) are
/// required before "Cancel plan" becomes tappable — no silent or
/// reason-less cancels. Returns the combined "Category: comment" string
/// via Get.back(result: ...), or null if the user backed out via "Keep
/// plan" or the system back gesture.
const List<String> kCancelReasons = [
  'Too expensive',
  "Not using it enough",
  "Didn't see the results I wanted",
  "Class timings don't work for me",
  'Health or medical reason',
  'Switching to a different plan',
  'Technical issues with the app',
  'Other',
];

class CancelPlanDialog extends StatefulWidget {
  const CancelPlanDialog({super.key});

  @override
  State<CancelPlanDialog> createState() => _CancelPlanDialogState();
}

class _CancelPlanDialogState extends State<CancelPlanDialog> {
  static const _textMuted = Color(0xFF6F8B7A);
  static const _textPrimary = Color(0xFF163220);
  static const _danger = Color(0xFFE07B7B);

  String? _selectedReason;
  final _commentController = TextEditingController();
  bool _triedSubmit = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  bool get _commentFilled => _commentController.text.trim().isNotEmpty;
  bool get _canSubmit => _selectedReason != null && _commentFilled;

  void _onSubmit() {
    if (!_canSubmit) {
      setState(() => _triedSubmit = true);
      return;
    }
    final combined = '$_selectedReason: ${_commentController.text.trim()}';
    Get.back<String>(result: combined);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cancel your plan?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "This ends your access to live sessions and your diet plan right away — it can't be undone from the app. "
              "If you paid recently and think you're owed a refund, reach out to support separately.",
              style: TextStyle(fontSize: 13, color: _textMuted),
            ),
            const SizedBox(height: 14),
            const Text(
              "What's the main reason? *",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _textPrimary),
            ),
            ...kCancelReasons.map(
              (r) => RadioListTile<String>(
                value: r,
                groupValue: _selectedReason,
                onChanged: (v) => setState(() => _selectedReason = v),
                title: Text(r, style: const TextStyle(fontSize: 13)),
                dense: true,
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
            if (_triedSubmit && _selectedReason == null)
              const Padding(
                padding: EdgeInsets.only(top: 2, bottom: 6),
                child: Text('Please pick a reason',
                    style: TextStyle(fontSize: 11, color: _danger)),
              ),
            const SizedBox(height: 10),
            const Text(
              'Tell us a bit more *',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _textPrimary),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _commentController,
              maxLines: 3,
              maxLength: 300,
              onChanged: (_) {
                if (_triedSubmit) setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'What happened, in your own words — this goes straight to the founders.',
                border: const OutlineInputBorder(),
                errorText: (_triedSubmit && !_commentFilled)
                    ? 'Please tell us a bit more before cancelling'
                    : null,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Get.back(), child: const Text('Keep plan')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: _danger),
          onPressed: _onSubmit,
          child: const Text('Cancel plan'),
        ),
      ],
    );
  }
}
