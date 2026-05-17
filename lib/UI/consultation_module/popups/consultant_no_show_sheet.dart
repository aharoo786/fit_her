import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/controllers/consultation_controller/consultation_controller.dart';
import '../../../widgets/toasts.dart';
import '../../../widgets/v2/v2_bottom_sheet.dart';
import '../../../widgets/v2/v2_buttons.dart';

/// `POPUP_CONSULTANT_NO_SHOW` — fires 10 min after the booked slot if
/// the dietitian hasn't flipped status to "In Progress". User may either
/// report (opens CONSULT_NO_SHOW escalation + auto-reschedule UX in a
/// later phase) or wait.
class ConsultantNoShowSheet extends StatefulWidget {
  static const String variable = 'POPUP_CONSULTANT_NO_SHOW';
  final int appointmentId;

  const ConsultantNoShowSheet({Key? key, required this.appointmentId})
      : super(key: key);

  static Future<void> show({required int appointmentId}) {
    return V2BottomSheet.show(
      title: "Consultant hasn't joined",
      child: ConsultantNoShowSheet(appointmentId: appointmentId),
      dismissible: false, // user must take an action — wait or report
    );
  }

  @override
  State<ConsultantNoShowSheet> createState() => _ConsultantNoShowSheetState();
}

class _ConsultantNoShowSheetState extends State<ConsultantNoShowSheet> {
  final TextEditingController _reasonCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ConsultationController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "It's been more than 10 minutes past your scheduled slot. Want to report this?",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Color(0xFF7A8C78),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _reasonCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Anything you want us to know? (optional)',
            hintStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Color(0xFF9AB09A),
            ),
            filled: true,
            fillColor: const Color(0xFFF5FDF2),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Color(0xFFC8DEC4)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Color(0xFFC8DEC4)),
            ),
          ),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Color(0xFF1A3A22),
          ),
        ),
        const SizedBox(height: 16),
        V2PrimaryButton(
          label: 'Report',
          busy: _busy,
          onPressed: () async {
            setState(() => _busy = true);
            final ok = await ctrl.reportConsultantNoShow(
              appointmentId: widget.appointmentId,
              reason: _reasonCtrl.text.trim().isEmpty
                  ? null
                  : _reasonCtrl.text.trim(),
            );
            if (!mounted) return;
            setState(() => _busy = false);
            await ctrl.completePopup(ConsultantNoShowSheet.variable,
                metadata: {'appointmentId': widget.appointmentId});
            Get.back<dynamic>();
            if (ok) {
              CustomToast.successToast(
                  msg: "Reported. We'll reschedule with you shortly.");
            } else {
              CustomToast.failToast(msg: 'Could not send. Please try again.');
            }
          },
        ),
        const SizedBox(height: 8),
        V2GhostButton(
          label: 'Wait 5 more minutes',
          onPressed: _busy
              ? null
              : () {
                  ctrl.dismissPopup(ConsultantNoShowSheet.variable);
                  Get.back<dynamic>();
                },
        ),
      ],
    );
  }
}
