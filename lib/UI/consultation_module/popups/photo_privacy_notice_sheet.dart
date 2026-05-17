import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/controllers/consultation_controller/consultation_controller.dart';
import '../../../widgets/v2/v2_bottom_sheet.dart';
import '../../../widgets/v2/v2_buttons.dart';

/// `POPUP_PHOTO_PRIVACY_NOTICE` — one-time notice shown when the user
/// uploads their first progress / meal photo. Per Section 10:
/// device-only storage. Caller is responsible for setting a local
/// SharedPreferences flag so it doesn't show again.
class PhotoPrivacyNoticeSheet extends StatelessWidget {
  static const String variable = 'POPUP_PHOTO_PRIVACY_NOTICE';

  const PhotoPrivacyNoticeSheet({Key? key}) : super(key: key);

  static Future<void> show() {
    return V2BottomSheet.show(
      title: 'Your photos stay on your phone',
      child: const PhotoPrivacyNoticeSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ConsultationController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE4F9D7),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lock_rounded, size: 22, color: Color(0xFF2D6B26)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Your photos are saved only on this phone — not on our servers, not visible to your dietitian, not visible to admin.",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A3A22),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "If you uninstall the app or change phones, your photos won't transfer. You can use the in-app before/after view anytime to see your progress.",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: Color(0xFF7A8C78),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        V2PrimaryButton(
          label: 'Got it',
          onPressed: () {
            ctrl.completePopup(variable);
            Get.back<dynamic>();
          },
        ),
      ],
    );
  }
}
