import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/controllers/meal_log_controller/meal_log_controller.dart';
import '../../../data/models/meal_log/meal_log.dart';
import '../../../widgets/v2/undo_snackbar.dart';
import '../../../widgets/v2/v2_bottom_sheet.dart';
import '../../../widgets/v2/v2_buttons.dart';

/// `POPUP_MEAL_LOG_OPTIONS` — opens when the user taps a meal tile on
/// the home screen. Three big tap targets per Section 6.2; secondary
/// flows for "alternative" and "skipped" capture reason + optional text.
class MealLogOptionsSheet extends StatefulWidget {
  static const String variable = 'POPUP_MEAL_LOG_OPTIONS';

  final MealLog meal;
  const MealLogOptionsSheet({Key? key, required this.meal}) : super(key: key);

  static Future<void> show({required MealLog meal}) {
    return V2BottomSheet.show(
      title: _titleFor(meal.mealType),
      child: MealLogOptionsSheet(meal: meal),
    );
  }

  static String _titleFor(MealType t) {
    switch (t) {
      case MealType.breakfast: return 'Breakfast';
      case MealType.lunch: return 'Lunch';
      case MealType.dinner: return 'Dinner';
    }
  }

  @override
  State<MealLogOptionsSheet> createState() => _MealLogOptionsSheetState();
}

enum _SubFlow { root, alternative, skipped }

class _MealLogOptionsSheetState extends State<MealLogOptionsSheet> {
  _SubFlow _flow = _SubFlow.root;
  String? _reason;
  final TextEditingController _alternativeText = TextEditingController();
  bool _busy = false;

  static const _alternativeReasons = [
    ('traveling', 'Traveling'),
    ('no_ingredients', 'No ingredients'),
    ('didnt_like_plan', "Didn't like plan meal"),
    ('hungry', 'Was hungry'),
    ('family_meal', 'Family meal'),
    ('other', 'Other'),
  ];

  static const _skippedReasons = [
    ('not_hungry', 'Not hungry'),
    ('forgot', 'Forgot'),
    ('busy', 'Busy'),
    ('felt_unwell', 'Felt unwell'),
    ('other', 'Other'),
  ];

  @override
  void dispose() {
    _alternativeText.dispose();
    super.dispose();
  }

  Future<void> _save({
    required MealStatus status,
    String? reasonCode,
    String? alternativeText,
  }) async {
    final ctrl = Get.find<MealLogController>();
    setState(() => _busy = true);
    final ok = await ctrl.upsertToday(
      mealType: widget.meal.mealType,
      status: status,
      reasonCode: reasonCode,
      alternativeText: alternativeText,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) return;
    Get.back<dynamic>();
    showUndoSnackbar(
      message: '${MealLogOptionsSheet._titleFor(widget.meal.mealType)} '
          'logged as ${_statusLabel(status)}',
      onUndo: ctrl.undoLast,
    );
    // Auto-clear the undo snapshot after the 5-second window so a
    // later undo tap can't accidentally revert old work.
    Future.delayed(const Duration(seconds: 6), ctrl.clearUndoSnapshot);
  }

  static String _statusLabel(MealStatus s) {
    switch (s) {
      case MealStatus.followed: return 'Followed';
      case MealStatus.alternative: return 'Alternative';
      case MealStatus.skipped: return 'Skipped';
      case MealStatus.pending: return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_flow) {
      case _SubFlow.root:
        return _buildRoot();
      case _SubFlow.alternative:
        return _buildAlternative();
      case _SubFlow.skipped:
        return _buildSkipped();
    }
  }

  Widget _buildRoot() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'How did this meal go?',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: Color(0xFF7A8C78),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        _BigOption(
          icon: Icons.check_circle_rounded,
          label: 'Followed plan',
          color: const Color(0xFF6DC55A),
          onTap: _busy
              ? null
              : () => _save(status: MealStatus.followed),
        ),
        const SizedBox(height: 10),
        _BigOption(
          icon: Icons.swap_horiz_rounded,
          label: 'Had alternative',
          color: const Color(0xFFFAC775),
          onTap: _busy
              ? null
              : () {
                  setState(() {
                    _flow = _SubFlow.alternative;
                    _reason = null;
                  });
                },
        ),
        const SizedBox(height: 10),
        _BigOption(
          icon: Icons.skip_next_rounded,
          label: 'Skipped',
          color: const Color(0xFF7A8C78),
          onTap: _busy
              ? null
              : () {
                  setState(() {
                    _flow = _SubFlow.skipped;
                    _reason = null;
                  });
                },
        ),
      ],
    );
  }

  Widget _buildAlternative() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionLabel('What did you eat?'),
        const SizedBox(height: 6),
        TextField(
          controller: _alternativeText,
          decoration: _inputDecoration('e.g. paratha and yogurt'),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Color(0xFF1A3A22),
          ),
        ),
        const SizedBox(height: 14),
        const _SectionLabel('Why?'),
        const SizedBox(height: 6),
        _ReasonPicker(
          options: _alternativeReasons,
          selected: _reason,
          onSelect: (v) => setState(() => _reason = v),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: V2SecondaryButton(
                label: 'Back',
                onPressed: _busy
                    ? null
                    : () => setState(() => _flow = _SubFlow.root),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: V2PrimaryButton(
                label: 'Save',
                busy: _busy,
                onPressed: _reason == null
                    ? null
                    : () => _save(
                          status: MealStatus.alternative,
                          reasonCode: _reason,
                          alternativeText:
                              _alternativeText.text.trim().isEmpty
                                  ? null
                                  : _alternativeText.text.trim(),
                        ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSkipped() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionLabel('Why did you skip?'),
        const SizedBox(height: 6),
        _ReasonPicker(
          options: _skippedReasons,
          selected: _reason,
          onSelect: (v) => setState(() => _reason = v),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: V2SecondaryButton(
                label: 'Back',
                onPressed: _busy
                    ? null
                    : () => setState(() => _flow = _SubFlow.root),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: V2PrimaryButton(
                label: 'Save',
                busy: _busy,
                onPressed: _reason == null
                    ? null
                    : () => _save(
                          status: MealStatus.skipped,
                          reasonCode: _reason,
                        ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
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
      );
}

class _BigOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _BigOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.32)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A3A22),
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color, size: 22),
            ],
          ),
        ),
      ),
    );
  }
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

class _ReasonPicker extends StatelessWidget {
  final List<(String, String)> options;
  final String? selected;
  final ValueChanged<String> onSelect;
  const _ReasonPicker({
    required this.options,
    required this.selected,
    required this.onSelect,
  });
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((o) {
        final on = selected == o.$1;
        return GestureDetector(
          onTap: () => onSelect(o.$1),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: on
                  ? const Color(0xFF1A3A22)
                  : const Color(0xFFF5FDF2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: on
                    ? const Color(0xFF1A3A22)
                    : const Color(0xFFC8DEC4),
              ),
            ),
            child: Text(
              o.$2,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: on ? Colors.white : const Color(0xFF1A3A22),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
