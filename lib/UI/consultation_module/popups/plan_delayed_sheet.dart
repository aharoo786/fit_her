import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/controllers/consultation_controller/consultation_controller.dart';
import '../../../widgets/toasts.dart';
import '../../../widgets/v2/v2_bottom_sheet.dart';
import '../../../widgets/v2/v2_buttons.dart';

/// `POPUP_PLAN_DELAYED` — Day 3 after consultation, no PdfDiet delivered.
/// Backend has already opened a server-side escalation; this sheet lets
/// the user add their own report (with reason) so the dietitian/admin
/// has a user-side acknowledgment in the queue.
class PlanDelayedSheet extends StatefulWidget {
  static const String variable = 'POPUP_PLAN_DELAYED';

  const PlanDelayedSheet({Key? key}) : super(key: key);

  static Future<void> show() {
    return V2BottomSheet.show(
      title: 'Your plan is taking longer than expected',
      child: const PlanDelayedSheet(),
    );
  }

  @override
  State<PlanDelayedSheet> createState() => _PlanDelayedSheetState();
}

class _PlanDelayedSheetState extends State<PlanDelayedSheet> {
  String? _reason;
  bool _busy = false;

  static const _reasons = [
    'Plan not received',
    'Wrong plan',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ConsultationController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Your plan was due 2 days after your consultation. We'll route this to your dietitian and the team.",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Color(0xFF7A8C78),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "What's happening?",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A3A22),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 8),
        ..._reasons.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ReasonOption(
                label: r,
                selected: _reason == r,
                onTap: () => setState(() => _reason = r),
              ),
            )),
        const SizedBox(height: 12),
        V2PrimaryButton(
          label: 'Report',
          busy: _busy,
          onPressed: _reason == null
              ? null
              : () async {
                  setState(() => _busy = true);
                  final ok = await ctrl.reportPlanDelayed(reason: _reason);
                  if (!mounted) return;
                  setState(() => _busy = false);
                  await ctrl.completePopup(PlanDelayedSheet.variable,
                      metadata: {'reason': _reason});
                  Get.back<dynamic>();
                  if (ok) {
                    CustomToast.successToast(
                        msg: "Reported. We'll be in touch shortly.");
                  } else {
                    CustomToast.failToast(
                        msg: 'Could not send. Please try again.');
                  }
                },
        ),
        const SizedBox(height: 8),
        V2GhostButton(
          label: 'Wait a bit longer',
          onPressed: _busy
              ? null
              : () {
                  ctrl.dismissPopup(PlanDelayedSheet.variable);
                  Get.back<dynamic>();
                },
        ),
      ],
    );
  }
}

class _ReasonOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ReasonOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFE4F9D7)
                : const Color(0xFFF5FDF2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? const Color(0xFF6DC55A)
                  : const Color(0xFFC8DEC4),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected
                    ? const Color(0xFF6DC55A)
                    : const Color(0xFF9AB09A),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A3A22),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
