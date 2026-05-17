import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/controllers/consultation_controller/consultation_controller.dart';
import '../../../widgets/toasts.dart';
import '../../../widgets/v2/v2_bottom_sheet.dart';
import '../../../widgets/v2/v2_buttons.dart';

/// `POPUP_MEDICAL_CONCERN` — user-triggered via the floating button
/// (Phase 2D wires `MedicalConcernFAB` to call `MedicalConcernSheet.show`).
/// Opens a MEDICAL escalation server-side; backend fans out to dietitian
/// + admin immediately (no SLA delay).
class MedicalConcernSheet extends StatefulWidget {
  static const String variable = 'POPUP_MEDICAL_CONCERN';

  const MedicalConcernSheet({Key? key}) : super(key: key);

  static Future<void> show() {
    return V2BottomSheet.show(
      title: 'Need urgent help?',
      child: const MedicalConcernSheet(),
    );
  }

  @override
  State<MedicalConcernSheet> createState() => _MedicalConcernSheetState();
}

class _MedicalConcernSheetState extends State<MedicalConcernSheet> {
  final TextEditingController _descriptionCtrl = TextEditingController();
  String? _category;
  int _severity = 3;
  bool _busy = false;

  static const _categories = [
    'Pain',
    'Allergy / reaction',
    'Dizziness / fainting',
    'Other',
  ];

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ConsultationController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1EE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFCDB8)),
          ),
          child: const Row(
            children: [
              Icon(Icons.medical_services_rounded,
                  color: Color(0xFFE24B4A), size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "If this is a life-threatening emergency, call your local emergency number first.",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A3A22),
                    height: 1.5,
                  ),
                ),
              ),
            ],
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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories
              .map((c) => GestureDetector(
                    onTap: () => setState(() => _category = c),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: _category == c
                            ? const Color(0xFF1A3A22)
                            : const Color(0xFFF5FDF2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _category == c
                              ? const Color(0xFF1A3A22)
                              : const Color(0xFFC8DEC4),
                        ),
                      ),
                      child: Text(
                        c,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _category == c
                              ? Colors.white
                              : const Color(0xFF1A3A22),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descriptionCtrl,
          maxLines: 3,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: 'Describe what you are experiencing',
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
              borderSide: const BorderSide(color: Color(0xFFC8DEC4)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFC8DEC4)),
            ),
            counterText: '',
          ),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Color(0xFF1A3A22),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'How serious is it?',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A3A22),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (i) {
            final n = i + 1;
            final selected = _severity == n;
            return GestureDetector(
              onTap: () => setState(() => _severity = n),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? const Color(0xFFE24B4A)
                      : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? const Color(0xFFE24B4A)
                        : const Color(0xFFC8DEC4),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$n',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : const Color(0xFF1A3A22),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        V2PrimaryButton(
          label: 'Send to dietitian + admin',
          busy: _busy,
          onPressed: _category == null
              ? null
              : () async {
                  setState(() => _busy = true);
                  final ok = await ctrl.openMedicalConcern(
                    description: [
                      if (_category != null) 'Category: $_category',
                      if (_descriptionCtrl.text.trim().isNotEmpty)
                        _descriptionCtrl.text.trim(),
                    ].join('\n'),
                    severity: _severity,
                  );
                  if (!mounted) return;
                  setState(() => _busy = false);
                  Get.back<dynamic>();
                  if (ok) {
                    CustomToast.successToast(
                        msg: "Sent. Your dietitian + admin are notified.");
                  } else {
                    CustomToast.failToast(
                        msg: 'Could not send. Please try again.');
                  }
                },
        ),
        const SizedBox(height: 8),
        V2GhostButton(
          label: 'Cancel',
          onPressed: _busy ? null : () => Get.back<dynamic>(),
        ),
      ],
    );
  }
}
