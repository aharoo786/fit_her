import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../../widgets/custom_button.dart';

class WeeklyCheckinScreen extends StatefulWidget {
  final double? lastWeight;
  final String? currentPhase;
  final double? lastWeekWeight;
  final Function(Map<String, dynamic>) onSubmit;
  final VoidCallback onDismiss;

  const WeeklyCheckinScreen({
    Key? key,
    this.lastWeight,
    this.currentPhase,
    this.lastWeekWeight,
    required this.onSubmit,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<WeeklyCheckinScreen> createState() => _WeeklyCheckinScreenState();
}

class _WeeklyCheckinScreenState extends State<WeeklyCheckinScreen> {
  int _currentStep = 0;
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();
  final TextEditingController _hipController = TextEditingController();
  int? _weekRating;

  static const _totalSteps = 3;

  @override
  void initState() {
    super.initState();
    if (widget.lastWeight != null) {
      _weightController.text = widget.lastWeight!.toStringAsFixed(1);
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _waistController.dispose();
    _hipController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _submit() {
    final weight = double.tryParse(_weightController.text);
    final waist = double.tryParse(_waistController.text);
    final hip = double.tryParse(_hipController.text);

    widget.onSubmit({
      'weightKg': weight,
      'waistCm': waist,
      'hipCm': hip,
      'weekRating': _weekRating,
    });
    setState(() => _currentStep = 3);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) widget.onDismiss();
    });
  }

  bool get _isLutealWeightFluctuation {
    if (widget.currentPhase != 'luteal') return false;
    if (widget.lastWeekWeight == null) return false;
    final currentWeight = double.tryParse(_weightController.text);
    if (currentWeight == null) return false;
    final diff = currentWeight - widget.lastWeekWeight!;
    return diff >= 0.5 && diff <= 2.5;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _currentStep == 3
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
        return _buildWeightStep();
      case 1:
        return _buildMeasurementsStep();
      case 2:
        return _buildRatingStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWeightStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Current weight',
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 48.h),
        SizedBox(
          width: 160.w,
          child: TextField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}\.?\d{0,1}')),
            ],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              suffixText: 'kg',
              suffixStyle: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textHint,
              ),
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
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            ),
          ),
        ),
        SizedBox(height: 48.h),
        CustomButton(
          text: 'Continue',
          onPressed: _weightController.text.isNotEmpty
              ? () => setState(() => _currentStep = 1)
              : () {},
        ),
      ],
    );
  }

  Widget _buildMeasurementsStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Optional measurements',
          style: TextStyle(
            fontSize: 19.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 48.h),
        _buildMeasurementField(
          controller: _waistController,
          label: 'Waist',
          unit: 'cm',
        ),
        SizedBox(height: 16.h),
        _buildMeasurementField(
          controller: _hipController,
          label: 'Hip',
          unit: 'cm',
        ),
        SizedBox(height: 48.h),
        CustomButton(
          text: 'Continue',
          onPressed: () => setState(() => _currentStep = 2),
        ),
        SizedBox(height: 16.h),
        GestureDetector(
          onTap: () => setState(() => _currentStep = 2),
          child: Text(
            'Skip',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textHint,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMeasurementField({
    required TextEditingController controller,
    required String label,
    required String unit,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 60.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}\.?\d{0,1}')),
            ],
            decoration: InputDecoration(
              suffixText: unit,
              suffixStyle: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textHint,
              ),
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
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingStep() {
    const labels = ['Very Hard', 'Hard', 'Okay', 'Good', 'Great'];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'How was your week overall?',
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
            final isSelected = _weekRating == value;

            return GestureDetector(
              onTap: () => setState(() => _weekRating = value),
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
        SizedBox(height: 48.h),
        CustomButton(
          text: 'Done',
          onPressed: _weekRating != null ? _submit : () {},
        ),
      ],
    );
  }

  Widget _buildConfirmation() {
    final message = _isLutealWeightFluctuation
        ? 'Weight fluctuation this week is hormonal \u2014 totally normal. Water retention during the luteal phase typically resolves after your period starts.'
        : 'Your trends have been updated.';

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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: _isLutealWeightFluctuation
                        ? AppColors.textTertiary
                        : AppColors.textPrimary,
                    fontWeight: _isLutealWeightFluctuation
                        ? FontWeight.w400
                        : FontWeight.w600,
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
