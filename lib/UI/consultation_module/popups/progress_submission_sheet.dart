import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/controllers/consultation_controller/consultation_controller.dart';
import '../../../helper/device_only_photo_picker.dart';
import '../../../widgets/toasts.dart';
import '../../../widgets/v2/before_after_compare.dart';
import '../../../widgets/v2/measurement_input.dart';
import '../../../widgets/v2/rating_star_row.dart';
import '../../../widgets/v2/v2_bottom_sheet.dart';
import '../../../widgets/v2/v2_buttons.dart';
import 'photo_privacy_notice_sheet.dart';

/// `POPUP_DAY15_PROGRESS` / `POPUP_DAY30_PROGRESS` — single sheet
/// parameterised on `cycle` (15 or 30). Mandatory submission per
/// Section 9; rendered with `dismissible: false` (soft-block —
/// dismissable swipe is off but the user can hit a "Save & exit"
/// gesture by submitting partial then re-opening; build plan risk #5
/// chose soft-block over hard-block).
///
/// Photos NEVER touch the server. They're stored device-only via
/// [DeviceOnlyPhotoPicker] and surfaced inside the app for the user's
/// own before/after view (Section 10). First photo upload triggers
/// `POPUP_PHOTO_PRIVACY_NOTICE` once per user.
class ProgressSubmissionSheet extends StatefulWidget {
  final String planType; // diet | workout | combined
  final int userPlanId;
  final int cycle;       // 15 or 30

  const ProgressSubmissionSheet({
    Key? key,
    required this.planType,
    required this.userPlanId,
    required this.cycle,
  }) : super(key: key);

  static String popupVariableForCycle(int cycle) =>
      cycle == 15 ? 'POPUP_DAY15_PROGRESS' : 'POPUP_DAY30_PROGRESS';

  static const _photoPrivacyShownKey = 'photoPrivacyNoticeShown';
  static const _bucket = 'progress';

  static Future<void> show({
    required String planType,
    required int userPlanId,
    required int cycle,
  }) {
    return V2BottomSheet.show(
      title: cycle == 15 ? 'Day 15 progress' : 'Day 30 progress',
      // Soft-block: drag-down disabled, no close button. Submitting or
      // tapping the Save Draft + later re-fetch is the only exit.
      dismissible: false,
      child: ProgressSubmissionSheet(
        planType: planType,
        userPlanId: userPlanId,
        cycle: cycle,
      ),
    );
  }

  @override
  State<ProgressSubmissionSheet> createState() =>
      _ProgressSubmissionSheetState();
}

class _ProgressSubmissionSheetState extends State<ProgressSubmissionSheet> {
  late final ConsultationController _ctrl;

  // Measurements
  final TextEditingController _weight = TextEditingController();
  final TextEditingController _waist = TextEditingController();
  final TextEditingController _hips = TextEditingController();
  final TextEditingController _chest = TextEditingController();
  final TextEditingController _arms = TextEditingController();
  final TextEditingController _thighs = TextEditingController();

  // Diet section
  String? _clothesFit;
  int? _sleepQuality;
  int? _satisfaction;

  // Workout section
  final TextEditingController _strengthNotes = TextEditingController();

  // Photos (device-only)
  List<String> _photoPaths = const [];
  bool _busy = false;
  bool _addingPhoto = false;

  bool get _showsDiet =>
      widget.planType == 'diet' || widget.planType == 'combined';
  bool get _showsWorkout =>
      widget.planType == 'workout' || widget.planType == 'combined';

  static const _clothesFitOptions = [
    ('tighter', 'Tighter'),
    ('same', 'Same'),
    ('looser', 'Looser'),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<ConsultationController>();
    _loadPhotos();
  }

  @override
  void dispose() {
    _weight.dispose();
    _waist.dispose();
    _hips.dispose();
    _chest.dispose();
    _arms.dispose();
    _thighs.dispose();
    _strengthNotes.dispose();
    super.dispose();
  }

  Future<void> _loadPhotos() async {
    final paths = await DeviceOnlyPhotoPicker.listBucket(
        ProgressSubmissionSheet._bucket);
    if (!mounted) return;
    setState(() => _photoPaths = paths);
  }

  Future<void> _maybeShowPrivacyNotice() async {
    final prefs = await SharedPreferences.getInstance();
    final shown =
        prefs.getBool(ProgressSubmissionSheet._photoPrivacyShownKey) ?? false;
    if (shown) return;
    await PhotoPrivacyNoticeSheet.show();
    await prefs.setBool(
        ProgressSubmissionSheet._photoPrivacyShownKey, true);
  }

  Future<void> _onAddPhoto() async {
    setState(() => _addingPhoto = true);
    await _maybeShowPrivacyNotice();
    if (!mounted) {
      setState(() => _addingPhoto = false);
      return;
    }
    // Show source picker — gallery vs camera. Keeping inline (small)
    // rather than another shared widget.
    final source = await Get.bottomSheet<ImageSource>(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: Color(0xFF6DC55A)),
              title: const Text('Pick from gallery'),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded,
                  color: Color(0xFF6DC55A)),
              title: const Text('Take a new photo'),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (!mounted) {
      setState(() => _addingPhoto = false);
      return;
    }
    if (source == null) {
      setState(() => _addingPhoto = false);
      return;
    }
    final path = await DeviceOnlyPhotoPicker.pickAndStore(
      bucket: ProgressSubmissionSheet._bucket,
      source: source,
    );
    if (!mounted) return;
    setState(() => _addingPhoto = false);
    if (path != null) {
      await _loadPhotos();
    }
  }

  Future<void> _onDeletePhoto(String path) async {
    final ok = await DeviceOnlyPhotoPicker.delete(path);
    if (!mounted) return;
    if (ok) await _loadPhotos();
  }

  void _openCompare() {
    if (_photoPaths.length < 2) return;
    // Newest is _photoPaths[0] (listBucket sorts newest-first); pair it
    // with the oldest for the most informative compare.
    final after = _photoPaths.first;
    final before = _photoPaths.last;
    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: BeforeAfterCompare(
                beforePath: before,
                afterPath: after,
              ),
            ),
            Positioned(
              right: 4,
              top: 4,
              child: IconButton(
                onPressed: () => Get.back<dynamic>(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _canSubmit {
    // Minimum required: weight. Other measurements are optional but
    // strongly encouraged. Diet section requires clothesFit.
    if (_weight.text.trim().isEmpty) return false;
    if (_showsDiet && (_clothesFit == null || _satisfaction == null)) {
      return false;
    }
    return true;
  }

  double? _parseDouble(String text) {
    final t = text.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  Map<String, dynamic> _buildBody() {
    return {
      'userPlanId': widget.userPlanId,
      'cycle': widget.cycle,
      if (_parseDouble(_weight.text) != null)
        'weightKg': _parseDouble(_weight.text),
      if (_parseDouble(_waist.text) != null)
        'waistCm': _parseDouble(_waist.text),
      if (_parseDouble(_hips.text) != null) 'hipsCm': _parseDouble(_hips.text),
      if (_parseDouble(_chest.text) != null)
        'chestCm': _parseDouble(_chest.text),
      if (_parseDouble(_arms.text) != null) 'armsCm': _parseDouble(_arms.text),
      if (_parseDouble(_thighs.text) != null)
        'thighsCm': _parseDouble(_thighs.text),
      if (_showsDiet) ...{
        'clothesFit': _clothesFit,
        if (_sleepQuality != null) 'sleepQuality': _sleepQuality,
        if (_satisfaction != null) 'satisfaction': _satisfaction,
      },
      if (_showsWorkout && _strengthNotes.text.trim().isNotEmpty)
        'strengthNotes': _strengthNotes.text.trim(),
    };
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _busy = true);
    final ok = await _ctrl.submitProgress(_buildBody());
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) return;
    // Server retires the matching popup variable on success; mirror
    // client-side as defence in depth.
    await _ctrl.completePopup(
      ProgressSubmissionSheet.popupVariableForCycle(widget.cycle),
      metadata: {'cycle': widget.cycle, 'userPlanId': widget.userPlanId},
    );
    Get.back<dynamic>();
    CustomToast.successToast(
        msg: 'Saved. Thank you — your dietitian will see this.');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.cycle == 15
              ? "We need this to plan your next 15 days."
              : "We need this to plan your renewal and next cycle.",
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: Color(0xFF7A8C78),
            height: 1.5,
          ),
        ),

        // ── Measurements grid ─────────────────────────────
        const SizedBox(height: 22),
        const _SectionHeader('Measurements'),
        const SizedBox(height: 12),
        MeasurementInput(
          label: 'Current weight',
          unit: 'kg',
          controller: _weight,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: MeasurementInput(
                label: 'Waist',
                unit: 'cm',
                controller: _waist,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MeasurementInput(
                label: 'Hips',
                unit: 'cm',
                controller: _hips,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MeasurementInput(
                label: 'Chest',
                unit: 'cm',
                controller: _chest,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MeasurementInput(
                label: 'Arms',
                unit: 'cm',
                controller: _arms,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        MeasurementInput(
          label: 'Thighs',
          unit: 'cm',
          controller: _thighs,
        ),

        // ── Diet-specific ─────────────────────────────────
        if (_showsDiet) ...[
          const SizedBox(height: 22),
          const _SectionHeader('How are you feeling?'),
          const SizedBox(height: 12),
          const _SectionLabel('Clothes are fitting'),
          const SizedBox(height: 6),
          Row(
            children: _clothesFitOptions
                .map((o) => Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(right: 8),
                        child: _PillChoice(
                          label: o.$2,
                          selected: _clothesFit == o.$1,
                          onTap: () =>
                              setState(() => _clothesFit = o.$1),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 14),
          const _SectionLabel('Sleep quality this cycle'),
          const SizedBox(height: 8),
          RatingStarRow(
            value: _sleepQuality,
            onChanged: (v) => setState(() => _sleepQuality = v),
          ),
          const SizedBox(height: 14),
          const _SectionLabel('Overall satisfaction'),
          const SizedBox(height: 8),
          RatingStarRow(
            value: _satisfaction,
            onChanged: (v) => setState(() => _satisfaction = v),
          ),
        ],

        // ── Workout-specific ──────────────────────────────
        if (_showsWorkout) ...[
          const SizedBox(height: 22),
          const _SectionHeader('Strength + stamina'),
          const SizedBox(height: 12),
          const _SectionLabel(
              'What feels different from when you started?'),
          const SizedBox(height: 6),
          TextField(
            controller: _strengthNotes,
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  'e.g. "I can hold plank twice as long" or "stairs are easier"',
              hintStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Color(0xFF9AB09A),
              ),
              filled: true,
              fillColor: const Color(0xFFF5FDF2),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
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
        ],

        // ── Photos (optional, device-only) ────────────────
        const SizedBox(height: 22),
        Row(
          children: [
            const Expanded(child: _SectionHeader('Photos (optional)')),
            if (_photoPaths.length >= 2)
              TextButton.icon(
                onPressed: _openCompare,
                icon: const Icon(Icons.compare_arrows_rounded,
                    size: 16, color: Color(0xFF6DC55A)),
                label: const Text(
                  'Compare',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6DC55A),
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 32),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Stored only on your phone. Not uploaded.',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            color: Color(0xFF9AB09A),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _photoPaths.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              if (i == 0) {
                return _AddPhotoTile(
                  busy: _addingPhoto,
                  onTap: _onAddPhoto,
                );
              }
              final path = _photoPaths[i - 1];
              return _PhotoThumb(
                path: path,
                onDelete: () => _onDeletePhoto(path),
              );
            },
          ),
        ),

        // ── Submit ────────────────────────────────────────
        const SizedBox(height: 24),
        V2PrimaryButton(
          label: widget.cycle == 15
              ? 'Submit Day 15 progress'
              : 'Submit Day 30 progress',
          busy: _busy,
          onPressed: _canSubmit ? _submit : null,
        ),
      ],
    );
  }
}

// ── Private helpers ──────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1A3A22),
          letterSpacing: -0.2,
        ),
      );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A3A22),
          letterSpacing: 0.4,
        ),
      );
}

class _PillChoice extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PillChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF1A3A22)
              : const Color(0xFFF5FDF2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? const Color(0xFF1A3A22)
                : const Color(0xFFC8DEC4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF1A3A22),
          ),
        ),
      ),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  final bool busy;
  final VoidCallback onTap;
  const _AddPhotoTile({required this.busy, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: const Color(0xFFF5FDF2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFC8DEC4),
            style: BorderStyle.solid,
            width: 1.2,
          ),
        ),
        child: busy
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF6DC55A)),
                  ),
                ),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_rounded,
                      color: Color(0xFF6DC55A), size: 26),
                  SizedBox(height: 4),
                  Text(
                    'Add',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A3A22),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  final String path;
  final VoidCallback onDelete;
  const _PhotoThumb({required this.path, required this.onDelete});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            File(path),
            width: 96,
            height: 96,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          right: 4,
          top: 4,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xCC1A3A22),
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
