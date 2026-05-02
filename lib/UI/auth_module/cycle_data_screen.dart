import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../values/dimens.dart';
import '../../values/my_colors.dart';
import '../../widgets/custom_button.dart';

class CycleDataScreen extends StatefulWidget {
  final void Function(Map<String, dynamic> cycleData) onContinue;
  final void Function() onSkip;

  const CycleDataScreen({
    Key? key,
    required this.onContinue,
    required this.onSkip,
  }) : super(key: key);

  @override
  State<CycleDataScreen> createState() => _CycleDataScreenState();
}

class _CycleDataScreenState extends State<CycleDataScreen> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _cycleLengthController =
      TextEditingController(text: '28');
  String? _selectedRegularity;
  bool _notSure = false;

  @override
  void dispose() {
    _cycleLengthController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get cycleData => {
        'lastPeriodDate': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'averageCycleLength':
            int.tryParse(_cycleLengthController.text) ?? 28,
        'isRegular': _selectedRegularity,
        'dataProvided': 1,
      };

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final earliest = now.subtract(const Duration(days: 60));

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: earliest,
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: MyColors.buttonColor,
              onPrimary: Colors.white,
              onSurface: MyColors.textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _onNotSureTapped() {
    setState(() {
      _notSure = true;
      _cycleLengthController.text = '28';
    });
  }

  void _showSkipBottomSheet() {
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you sure?',
                style: textTheme.headlineSmall!.copyWith(
                  fontSize: 20.sp,
                  color: MyColors.textColor3,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Your cycle data makes everything 10x more accurate \u2014 your insights, workout recommendations, and reports. This data is encrypted and 100% private. Only you can see it. We never share it.',
                style: textTheme.titleLarge!.copyWith(
                  color: MyColors.textColorLow,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              CustomButton(
                text: 'I will add it now',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 12.h),
              CustomButton(
                text: 'Skip for now',
                color: Colors.white,
                textColor: MyColors.textColor3,
                borderColor: MyColors.buttonColor,
                onPressed: () {
                  Navigator.pop(context);
                  widget.onSkip();
                },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: Dimens.size20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),

                // Heading
                Text(
                  'Your Cycle',
                  style: textTheme.headlineSmall!.copyWith(
                    fontSize: 24.sp,
                    color: MyColors.textColor3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: Dimens.size5.h),

                // Subtitle
                Text(
                  'This powers your daily insights and recommendations',
                  style: textTheme.titleLarge!.copyWith(
                    color: MyColors.textColorLow,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 30.h),

                // --- Field 1: Last period start date ---
                Text(
                  'Last period start date',
                  style: textTheme.bodyMedium!.copyWith(
                    color: MyColors.textColor3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    height: 48,
                    width: double.infinity,
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: MyColors.textFieldColor,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: MyColors.textColor, width: 1),
                    ),
                    child: Row(
                      children: [
                        Text(
                          DateFormat('MMM dd, yyyy')
                              .format(_selectedDate),
                          style: textTheme.bodyMedium!.copyWith(
                            color: MyColors.textColor3,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.calendar_today_outlined,
                            color: MyColors.textColorLow, size: 20),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // --- Field 2: Average cycle length ---
                Text(
                  'Average cycle length',
                  style: textTheme.bodyMedium!.copyWith(
                    color: MyColors.textColor3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _cycleLengthController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  enabled: !_notSure,
                  onChanged: (_) {
                    setState(() {
                      _notSure = false;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: MyColors.textFieldColor,
                    suffixText: 'days',
                    suffixStyle: textTheme.bodyMedium!.copyWith(
                      color: MyColors.textColorLow,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 12.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: MyColors.textColor, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: MyColors.textColor, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: MyColors.buttonColor, width: 1),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                          color: MyColors.textColor, width: 1),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                GestureDetector(
                  onTap: _onNotSureTapped,
                  child: Container(
                    height: 40,
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: _notSure
                          ? MyColors.buttonColor.withOpacity(0.15)
                          : MyColors.textFieldColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _notSure
                            ? MyColors.buttonColor
                            : MyColors.textColor,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Not sure',
                        style: textTheme.bodyMedium!.copyWith(
                          color: _notSure
                              ? MyColors.buttonColor
                              : MyColors.textColorLow,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 28.h),

                // --- Field 3: Is your cycle regular? ---
                Text(
                  'Is your cycle regular?',
                  style: textTheme.bodyMedium!.copyWith(
                    color: MyColors.textColor3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: ['Yes', 'Somewhat', 'No']
                      .map((option) => Padding(
                            padding: EdgeInsets.only(right: 10.w),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedRegularity =
                                      _selectedRegularity ==
                                              option.toLowerCase()
                                          ? null
                                          : option.toLowerCase();
                                });
                              },
                              child: Container(
                                height: 40,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.w),
                                decoration: BoxDecoration(
                                  color: _selectedRegularity ==
                                          option.toLowerCase()
                                      ? MyColors.buttonColor
                                              .withOpacity(0.15)
                                      : MyColors.textFieldColor,
                                  borderRadius:
                                      BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _selectedRegularity ==
                                            option.toLowerCase()
                                        ? MyColors.buttonColor
                                        : MyColors.textColor,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    option,
                                    style: textTheme.bodyMedium!
                                        .copyWith(
                                      color: _selectedRegularity ==
                                              option.toLowerCase()
                                          ? MyColors.buttonColor
                                          : MyColors.textColorLow,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                SizedBox(height: 24.h),

                // --- Privacy note ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 16.sp,
                      color: MyColors.buttonColor,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Your cycle data is private and protected. Only used to understand your body more accurately. We never share it.',
                        style: textTheme.bodySmall!.copyWith(
                          color: MyColors.textColorLow,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // --- Continue button ---
                CustomButton(
                  text: 'Continue',
                  onPressed: () {
                    final length =
                        int.tryParse(_cycleLengthController.text) ?? 28;
                    if (length < 21 || length > 45) {
                      Get.snackbar(
                        'Invalid cycle length',
                        'Please enter a value between 21 and 45 days',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: MyColors.error,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    widget.onContinue(cycleData);
                  },
                ),
                SizedBox(height: 16.h),

                // --- Skip text ---
                Center(
                  child: GestureDetector(
                    onTap: _showSkipBottomSheet,
                    child: Text(
                      'Skip',
                      style: textTheme.bodyMedium!.copyWith(
                        fontSize: 16.sp,
                        color: MyColors.textColorLow,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
