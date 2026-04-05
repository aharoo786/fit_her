import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../data/controllers/auth_controller/auth_controller.dart';
import '../UI/auth_module/cycle_data_screen.dart';
import '../UI/dashboard_module/bottom_bar_screen/bottom_bar_screen.dart';
import '../data/Repos/cycle_repo/cycle_data_repository.dart';
import '../values/constants.dart';
import '../values/my_colors.dart';

class MigrationBanner extends StatefulWidget {
  const MigrationBanner({Key? key}) : super(key: key);

  @override
  State<MigrationBanner> createState() => _MigrationBannerState();
}

class _MigrationBannerState extends State<MigrationBanner> {
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _dismissed = Get.find<AuthController>().sharedPreferences.getBool('cycle_banner_dismissed') ?? false;
  }

  void _dismiss() {
    Get.find<AuthController>().sharedPreferences.setBool('cycle_banner_dismissed', true);
    setState(() {
      _dismissed = true;
    });
  }

  void _openCycleData() {
    Get.to(() => CycleDataScreen(
      onContinue: (cycleData) async {
        final repo = Get.find<CycleDataRepository>();
        final token = Get.find<AuthController>().sharedPreferences.getString(Constants.accessToken) ?? '';
        await repo.saveCycleData(accessToken: token, body: cycleData);
        Get.offAll(() => BottomBarScreen());
      },
      onSkip: () async {
        final repo = Get.find<CycleDataRepository>();
        final token = Get.find<AuthController>().sharedPreferences.getString(Constants.accessToken) ?? '';
        await repo.saveCycleData(accessToken: token, body: {'dataProvided': 0});
        Get.offAll(() => BottomBarScreen());
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: _openCycleData,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: MyColors.buttonColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(color: MyColors.buttonColor, width: 3),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Unlock your body\u2019s rhythm \u2014 set up cycle tracking \u2192',
                style: textTheme.bodyMedium!.copyWith(
                  color: MyColors.textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: _dismiss,
              child: Icon(
                Icons.close,
                size: 18.sp,
                color: MyColors.buttonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
