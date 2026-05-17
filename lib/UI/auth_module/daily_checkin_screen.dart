import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';

class DailyCheckinScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;
  final VoidCallback onDismiss;

  const DailyCheckinScreen({
    Key? key,
    required this.onSubmit,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<DailyCheckinScreen> createState() => _DailyCheckinScreenState();
}

class _DailyCheckinScreenState extends State<DailyCheckinScreen> {
  int _currentStep = 0;
  int? _energyLevel;
  int? _moodLevel;
  double _sleepHours = 7.0;
  String? _cravingType;
  final TextEditingController _noteController = TextEditingController();

  static const _totalSteps = 5;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _selectEnergy(int level) {
    setState(() => _energyLevel = level);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _currentStep = 1);
    });
  }

  void _selectMood(int level) {
    setState(() => _moodLevel = level);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _currentStep = 2);
    });
  }

  void _selectCraving(String type) {
    setState(() => _cravingType = type);
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _submit() {
    widget.onSubmit({
      'energyLevel': _energyLevel,
      'moodLevel': _moodLevel,
      'sleepHours': _sleepHours,
      'cravingType': _cravingType,
      'note': _noteController.text.isEmpty ? null : _noteController.text,
    });
    setState(() => _currentStep = 5);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _currentStep == 5
            ? _buildConfirmation()
            : Column(
                children: [
                  _buildTopBar(),
                  SizedBox(height: 8.h),
                  _buildProgressDots(),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: _buildStep(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        children: [
          if (_currentStep > 0)
            GestureDetector(
              onTap: _goBack,
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: const Icon(Icons.arrow_back_ios_new, size: 20),
              ),
            )
          else
            const SizedBox(width: 48),
          const Spacer(),
          GestureDetector(
            onTap: widget.onDismiss,
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              child: const Icon(Icons.close, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_totalSteps, (index) {
        final isActive = index == _currentStep;
        final isCompleted = index < _currentStep;
        final size = isActive ? 8.0 : 6.0;
        final color = (isActive || isCompleted)
            ? AppColors.primary
            : AppColors.divider;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildStep() {
    switch (_currentStep) {
      case 0:
        return _buildEnergyStep();
      case 1:
        return _buildMoodStep();
      case 2:
        return _buildSleepStep();
      case 3:
        return _buildCravingsStep();
      case 4:
        return _buildNoteStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEnergyStep() {
    return _buildSelectionStep(
      question: 'How was your energy today?',
      selectedValue: _energyLevel,
      onSelect: _selectEnergy,
    );
  }

  Widget _buildMoodStep() {
    return _buildSelectionStep(
      question: 'How was your mood today?',
      selectedValue: _moodLevel,
      onSelect: _selectMood,
    );
  }

  Widget _buildSelectionStep({
    required String question,
    required int? selectedValue,
    required Function(int) onSelect,
  }) {
    const labels = ['Very Low', 'Low', 'Moderate', 'High', 'Very High'];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          question,
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 48.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final value = index + 1;
            final isSelected = selectedValue == value;

            return GestureDetector(
              onTap: () => onSelect(value),
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? null
                          : Border.all(color: AppColors.divider, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        '$value',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    labels[index],
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSleepStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'How did you sleep last night?',
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 48.h),
        Text(
          '${_sleepHours.toStringAsFixed(_sleepHours == _sleepHours.roundToDouble() ? 0 : 1)} hours',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 24.h),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.divider,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.15),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: _sleepHours,
            min: 2,
            max: 12,
            divisions: 20,
            onChanged: (value) => setState(() => _sleepHours = value),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('2h', style: TextStyle(fontSize: 11.sp, color: AppColors.textHint)),
              Text('12h', style: TextStyle(fontSize: 11.sp, color: AppColors.textHint)),
            ],
          ),
        ),
        SizedBox(height: 48.h),
        CustomButton(
          text: 'Continue',
          onPressed: () => setState(() => _currentStep = 3),
        ),
      ],
    );
  }

  Widget _buildCravingsStep() {
    const cravings = ['sweet', 'salty', 'carbs', 'comfort', 'none'];
    const labels = ['Sweet', 'Salty', 'Carbs', 'Comfort food', 'No cravings'];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Any cravings today?',
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 48.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          alignment: WrapAlignment.center,
          children: List.generate(cravings.length, (index) {
            final isSelected = _cravingType == cravings[index];

            return GestureDetector(
              onTap: () => _selectCraving(cravings[index]),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  labels[index],
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 48.h),
        CustomButton(
          text: 'Continue',
          onPressed: _cravingType != null
              ? () => setState(() => _currentStep = 4)
              : () {},
        ),
      ],
    );
  }

  Widget _buildNoteStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Anything else to note?',
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12.h),
        Text(
          'Optional \u2014 100 characters max',
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.textHint,
          ),
        ),
        SizedBox(height: 32.h),
        TextField(
          controller: _noteController,
          maxLength: 100,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'e.g. felt dizzy after lunch...',
            hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13.sp),
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.divider, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.divider, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding: EdgeInsets.all(16.w),
          ),
        ),
        SizedBox(height: 32.h),
        CustomButton(
          text: 'Done',
          onPressed: _submit,
        ),
      ],
    );
  }

  Widget _buildConfirmation() {
    return GestureDetector(
      onTap: widget.onDismiss,
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: 40.sp,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Got it!',
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Text(
                  'Your insights are getting smarter.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textTertiary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
