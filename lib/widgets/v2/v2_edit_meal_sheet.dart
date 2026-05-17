import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../data/models/diet_plan_v2/diet_plan_v2_models.dart';
import 'v2_bottom_sheet.dart';
import 'v2_buttons.dart';

const Color _kCardBorder = Color(0xFFD8EDD4);
const Color _kHeroDark = Color(0xFF163220);
const Color _kAccent = Color(0xFF6DC55A);
const Color _kSage = Color(0xFF9AB09A);
const Color _kBodyMuted = Color(0xFF6F8B7A);
const Color _kCream = Color(0xFFEAF7E4);
const Color _kDanger = Color(0xFFE07B7B);

final RegExp _kHHMM = RegExp(r'^\d{2}:\d{2}$');

/// Save callback: returns true on success, false on failure.
/// The sheet stays open on failure so the dietitian can correct + retry.
typedef EditMealSaveCallback = Future<bool> Function({
  String? foodName,
  int? calories,
  String? time,
  String? notes,
  MealTypeV2? mealType,
});

/// V2 edit-meal bottom sheet. Pre-fills from [meal] and only sends the
/// fields that actually changed back through [onSave] — minimises the
/// PATCH payload and avoids the day-total churning when only a label
/// changed.
class V2EditMealSheet extends StatefulWidget {
  final DietPlanMealV2 meal;
  final EditMealSaveCallback onSave;

  const V2EditMealSheet({
    super.key,
    required this.meal,
    required this.onSave,
  });

  static Future<void> show({
    required DietPlanMealV2 meal,
    required EditMealSaveCallback onSave,
  }) {
    return V2BottomSheet.show<void>(
      title: 'Edit meal',
      child: V2EditMealSheet(meal: meal, onSave: onSave),
    );
  }

  @override
  State<V2EditMealSheet> createState() => _V2EditMealSheetState();
}

class _V2EditMealSheetState extends State<V2EditMealSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _foodCtrl;
  late final TextEditingController _calCtrl;
  late final TextEditingController _timeCtrl;
  late final TextEditingController _notesCtrl;
  late MealTypeV2 _mealType;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _foodCtrl = TextEditingController(text: widget.meal.foodName);
    _calCtrl = TextEditingController(text: widget.meal.calories.toString());
    _timeCtrl = TextEditingController(text: widget.meal.time);
    _notesCtrl = TextEditingController(text: widget.meal.notes ?? '');
    _mealType = widget.meal.mealType;
  }

  @override
  void dispose() {
    _foodCtrl.dispose();
    _calCtrl.dispose();
    _timeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    // Diff against the original meal — the controller's PATCH only
    // wants fields that actually changed. Sending unchanged fields
    // would trigger an unnecessary day-total recompute server-side.
    String? foodName;
    int? calories;
    String? time;
    String? notes;
    MealTypeV2? mealType;

    final newFood = _foodCtrl.text.trim();
    if (newFood != widget.meal.foodName) foodName = newFood;

    final parsedCal = int.tryParse(_calCtrl.text.trim());
    if (parsedCal != null && parsedCal != widget.meal.calories) {
      calories = parsedCal;
    }

    final newTime = _timeCtrl.text.trim();
    if (newTime != widget.meal.time) time = newTime;

    final newNotes = _notesCtrl.text.trim();
    final originalNotes = widget.meal.notes ?? '';
    if (newNotes != originalNotes) notes = newNotes;

    if (_mealType != widget.meal.mealType) mealType = _mealType;

    final hasChanges = foodName != null ||
        calories != null ||
        time != null ||
        notes != null ||
        mealType != null;
    if (!hasChanges) {
      Get.back<dynamic>();
      return;
    }

    setState(() => _saving = true);
    final ok = await widget.onSave(
      foodName: foodName,
      calories: calories,
      time: time,
      notes: notes,
      mealType: mealType,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) Get.back<dynamic>();
    // On failure: snackbar fires from the controller; sheet stays open
    // so the dietitian can adjust the inputs and retry.
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label('FOOD NAME'),
          SizedBox(height: 6.h),
          _textField(
            controller: _foodCtrl,
            hint: 'e.g. Oats Porridge with Banana',
            enabled: !_saving,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              return null;
            },
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('CALORIES'),
                    SizedBox(height: 6.h),
                    _textField(
                      controller: _calCtrl,
                      hint: '450',
                      enabled: !_saving,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (v) {
                        final n = int.tryParse((v ?? '').trim());
                        if (n == null || n <= 0) {
                          return 'Positive integer';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('TIME'),
                    SizedBox(height: 6.h),
                    _textField(
                      controller: _timeCtrl,
                      hint: 'HH:MM',
                      enabled: !_saving,
                      keyboardType: TextInputType.datetime,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                        LengthLimitingTextInputFormatter(5),
                      ],
                      validator: (v) {
                        if (v == null || !_kHHMM.hasMatch(v.trim())) {
                          return 'HH:MM';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _label('MEAL TYPE'),
          SizedBox(height: 6.h),
          _mealTypeSelector(),
          SizedBox(height: 14.h),
          _label('NOTES (OPTIONAL)'),
          SizedBox(height: 6.h),
          _textField(
            controller: _notesCtrl,
            hint: 'Short tip explaining the choice…',
            enabled: !_saving,
            maxLines: 3,
          ),
          SizedBox(height: 22.h),
          Row(
            children: [
              Expanded(
                child: V2GhostButton(
                  label: 'Cancel',
                  onPressed: _saving ? null : () => Get.back<dynamic>(),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 2,
                child: V2PrimaryButton(
                  label: 'Save changes',
                  busy: _saving,
                  onPressed: _saving ? null : _onSave,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 11.sp,
        fontWeight: FontWeight.w800,
        color: _kSage,
        letterSpacing: 0.84,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    bool enabled = true,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14.sp,
        color: _kHeroDark,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13.sp,
          color: _kBodyMuted,
        ),
        filled: true,
        fillColor: _kCream,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kCardBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kCardBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kAccent, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kDanger, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kDanger, width: 1.4),
        ),
      ),
    );
  }

  Widget _mealTypeSelector() {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: MealTypeV2.values.map((t) {
        final selected = t == _mealType;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _saving ? null : () => setState(() => _mealType = t),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: selected ? _kAccent : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? _kAccent : _kCardBorder,
                width: 1,
              ),
            ),
            child: Text(
              t.label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : _kHeroDark,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
