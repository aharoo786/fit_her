import 'package:fitness_zone_2/UI/free_trail/free_trail_question.dart';
import 'package:fitness_zone_2/UI/free_trail/free_trial_slots.dart';
import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/data/controllers/motivation_controller/motivation_controller.dart';
import 'package:fitness_zone_2/data/controllers/workout_controller/work_out_controller.dart';
import 'package:fitness_zone_2/data/controllers/zoom_controller.dart';
import 'package:fitness_zone_2/data/services/youtube_tutorial_service.dart';
import 'package:fitness_zone_2/utils/slot_input_builder.dart';
import 'package:fitness_zone_2/utils/slot_ui_state.dart';
import 'package:fitness_zone_2/widgets/review_bottom_sheet.dart';
import 'package:fitness_zone_2/widgets/toasts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../UI/plans_module/all_plans.dart';
import '../data/models/get_all_users/get_all_users_based_on_type.dart';
import '../data/models/get_user_plan/get_workout_user_plan_details.dart';
import '../values/constants.dart';
import '../values/my_colors.dart';
import '../values/my_imgs.dart';
import '../helper/analytics_helper.dart';
import 'custom_button.dart';
import 'package:intl/intl.dart';

enum StatusType { pending, delayed, completed, canceled, confirmed, canceledByUser }

class HelpingWidgets {
  PreferredSizeWidget appBarWidget(onTap,
      {String? text, TextAlign? textAlign, Color backGroundColor = Colors.white, Widget? actionWidget, PreferredSizeWidget? bottom}) {
    return AppBar(
      backgroundColor: backGroundColor,
      // leadingWidth: 70.w,
      elevation: 0,
      automaticallyImplyLeading: false,
      systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: backGroundColor),
      title: text != null
          ? Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 20.sp,
                color: Colors.black,
              ),
              textAlign: textAlign ?? TextAlign.start,
            )
          : null,
      centerTitle: true,
      leading: onTap == null
          ? null
          : GestureDetector(
              onTap: onTap,
              child: Icon(
                Icons.arrow_back,
                color: MyColors.iconColor2,
              ),
            ),
      actions: [actionWidget ?? const SizedBox()],
      bottom: bottom,
    );
  }

  static String formatDateWithMonthName(DateTime date) {
    final day = date.day.toString().padLeft(2, '0'); // 2-digit day
    final year = (date.year % 100).toString().padLeft(2, '0'); // last 2 digits of year
    final monthName = DateFormat('MMMM').format(date); // Full month name (e.g., July)

    return '$day $monthName $year';
  }

  static DateTime getNextWeekdayDate(String selectedDayName) {
    // Map weekday names to DateTime weekday numbers
    final Map<String, int> weekdayMap = {
      'Monday': DateTime.monday,
      'Tuesday': DateTime.tuesday,
      'Wednesday': DateTime.wednesday,
      'Thursday': DateTime.thursday,
      'Friday': DateTime.friday,
      'Saturday': DateTime.saturday,
      'Sunday': DateTime.sunday,
    };

    int? selectedDay = weekdayMap[selectedDayName];
    if (selectedDay == null) throw Exception('Invalid weekday name: $selectedDayName');

    DateTime today = DateTime.now();
    int currentWeekday = today.weekday;

    // Calculate how many days to add to get to the next selected day
    int daysToAdd = (selectedDay - currentWeekday + 7) % 7;
    if (daysToAdd == 0) daysToAdd = 7; // if today is the selected day, pick next week's day

    return today.add(Duration(days: daysToAdd));
  }

  Widget appBarText(String text) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.w500,
          //  fontStyle: FontStyle.normal,
          fontFamily: "Roboto"),
    );
  }

  Widget notSubscribed() {
    return const Center(child: Text("Please subscribe our plan to get started"));
  }

  Widget bottomBarButtonWidget({String text = "Submit", VoidCallback? onTap}) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: CustomButton(
        text: text,
        onPressed: onTap ?? () => Get.back(),
      ),
    );
  }

  Widget iconPlusMinus({IconData icon = Icons.add, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.h,
        width: 40.h,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: MyColors.buttonColor, width: 2)),
        child: Icon(
          icon,
          color: MyColors.buttonColor,
        ),
      ),
    );
  }

  Widget getOurPlans(BuildContext context, TextTheme textTheme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration:
              BoxDecoration(color: MyColors.planColor, borderRadius: BorderRadius.circular(5), border: Border.all(color: MyColors.primaryGradient1)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(MyImgs.freeTrial),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Free Trial",
                    style: textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(
                height: 7,
              ),
              Text(
                "Get Fit, Feel Strong — Start Your FREE Fither Trial Today!",
                style: textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500, color: Colors.black.withOpacity(0.3)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const Spacer(),
        CustomButton(
          text: "Start Free Trial",
          onPressed: () async {
            Get.find<WorkOutController>().getWorkoutAllPlansFunc(isFree: true);
          },
          color: Colors.white,
          textColor: MyColors.primaryGradient1,
        ),
        SizedBox(
          height: 18.h,
        ),
        CustomButton(
            text: "Subscribe Now",
            onPressed: () async {
              // Track subscribe click
              await AnalyticsHelper.trackSubscribeClick(screenName: 'home_screen');

              // Show subscribe tutorial first and wait for user response
              final tutorialService = Get.find<YouTubeTutorialService>();
              await tutorialService.showSubscribeTutorial(context);

              // Then proceed with subscription
              Get.find<HomeController>().getPlansUser();
              Get.to(() => OurPlansScreen());
            }),
        SizedBox(
          height: 20.h,
        )
      ],
    );
  }

  Widget list(List<UserTypeData> list, RxInt variable, TextTheme textTheme) {
    return ListView.separated(
      // shrinkWrap: true,
      itemCount: list.length,
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(vertical: 10),
      itemBuilder: (BuildContext context, int index) {
        var diet = list[index];

        return GestureDetector(
          onTap: () {
            variable.value = diet.id;
          },
          child: Obx(
            () => Container(
              width: 300.w,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: variable.value == diet.id ? MyColors.buttonColor : Colors.white),
                  boxShadow: [BoxShadow(offset: const Offset(0, 2), blurRadius: 4, color: Colors.black.withOpacity(0.1))]),
              child: Row(children: [
                Container(
                  width: 70.w,
                  height: 80,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: MyColors.primaryGradient1,
                      image: const DecorationImage(image: AssetImage(MyImgs.logo))),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${diet.firstName} ${diet.lastName}",
                          style: textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          diet.email,
                          style: textTheme.bodySmall!.copyWith(),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                )
              ]),
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(
          width: 10.h,
        );
      },
    );
  }

  static showCustomDialog(
    BuildContext context,
    Function()? onTap,
    String firstText,
    String secondText,
    String? image, {
    String? buttonText,
    String? secondButtonText,
    Function()? secondButtonTap,
  }) {
    var textTheme = Theme.of(context).textTheme;
    showDialog(
        context: context,
        builder: (context) => Dialog(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (image != null) image.contains("svg") ? SvgPicture.asset(image) : Image.asset(image),
                    const SizedBox(
                      height: 14,
                    ),
                    Text(
                      firstText,
                      style: textTheme.bodyMedium!.copyWith(color: MyColors.black, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      secondText,
                      style: textTheme.titleLarge!.copyWith(fontSize: 13, color: MyColors.black.withOpacity(0.5), fontWeight: FontWeight.w400),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        if (secondButtonTap != null)
                          Expanded(
                            child: CustomButton(
                              text: secondButtonText ?? "Ok",
                              onPressed: secondButtonTap,
                              color: Colors.white,
                              textColor: MyColors.buttonColor,
                              height: 40,
                              fontSize: 14,
                              roundCorner: 25,
                            ),
                          ),
                        if (secondButtonTap != null)
                          SizedBox(
                            width: 14,
                          ),
                        if (onTap != null)
                          Expanded(
                            child: CustomButton(
                              text: buttonText ?? "Start",
                              onPressed: onTap,
                              height: 40,
                              fontSize: 14,
                              roundCorner: 25,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ));
  }

  /// Bottom-sheet popup. Opens for ANY slot tap (per UX spec). The Join
  /// button inside is rendered straight from [presentationForState] —
  /// this widget makes no decisions of its own about color, label, or
  /// action. Add a state in the resolver, this surface follows.
  ///
  /// [anchorDate] is the calendar date the slot's wall-clock times
  /// belong to (today by default; the workout schedule passes its
  /// selected date). Without it, tomorrow's 8am would be misclassified
  /// as today's 8am.
  static showWorkoutBottomSheet({
    required BuildContext context,
    required Slot? slot,
    required HomeController homeController,
    DateTime? anchorDate,
  }) {
    final anchor = anchorDate ?? DateTime.now();
    final access = buildUserAccess(homeController);
    final input = slot != null ? buildSlotInput(slot, anchor) : null;
    final state = input != null
        ? resolveSlotUIState(
            slot: input,
            now: DateTime.now(),
            user: access,
          )
        : SlotUIState.upcomingFar;
    final mins = (state == SlotUIState.upcomingSoon && input != null)
        ? minutesUntilStart(input.start, DateTime.now())
        : null;
    final presentation = presentationForState(
      state,
      minutesUntilStart: mins,
      blockReason: blockReasonFor(access),
    );

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        final textTheme = Theme.of(sheetContext).textTheme;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.keyboard_arrow_down, size: 32),
            if (state == SlotUIState.cancelled)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text('This class was cancelled.',
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600)),
              ),
            if (state == SlotUIState.endedNotAttended)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text('You missed this session.',
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.w600)),
              ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Icon(Icons.access_time, color: Colors.green, size: 32),
                    SizedBox(height: 8),
                    Text(
                      '50 Min',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Time'),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.local_fire_department, color: Colors.green, size: 32),
                    SizedBox(height: 8),
                    Text(
                      '254',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Calories'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                slot?.description ?? "",
                style: textTheme.bodySmall,
                maxLines: 4,
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.access_time_sharp),
              title: Text(
                '${slot?.start}-${slot?.end}',
                style: textTheme.bodySmall,
              ),
              visualDensity: const VisualDensity(vertical: -4),
            ),
            ListTile(
              leading: const Icon(Icons.fitness_center),
              title: Text(slot?.level ?? 'High Intensity Workout Session', style: textTheme.bodySmall),
              visualDensity: const VisualDensity(vertical: -4),
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundImage: AssetImage(MyImgs.profilePicture),
                maxRadius: 10,
              ),
              title: Text('with ${slot?.trainer?.firstName} ${slot?.trainer?.lastName}', style: textTheme.bodySmall),
              visualDensity: const VisualDensity(vertical: -4),
            ),
            const SizedBox(height: 16),
            if (presentation.appearance != SlotButtonAppearance.hidden)
              _buildPopupActionButton(
                context: sheetContext,
                slot: slot,
                presentation: presentation,
                homeController: homeController,
              ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  static Widget _buildPopupActionButton({
    required BuildContext context,
    required Slot? slot,
    required SlotPresentation presentation,
    required HomeController homeController,
  }) {
    final bg = switch (presentation.buttonColor) {
      SlotButtonColor.accent => Colors.green,
      SlotButtonColor.grey => Colors.grey,
      SlotButtonColor.none => Colors.transparent,
    };
    return ElevatedButton.icon(
      onPressed: slot == null
          ? null
          : () => dispatchSlotAction(
                context: context,
                homeController: homeController,
                presentation: presentation,
                slot: slot,
              ),
      icon: const Icon(Icons.video_call),
      label: Text(presentation.buttonLabel ?? ''),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        backgroundColor: bg,
        disabledBackgroundColor: bg,
        foregroundColor: Colors.white,
        disabledForegroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
    );
  }

  /// Single dispatch path used by the schedule live card and the popup
  /// button. Switches purely on [SlotPresentation.action] — no slot
  /// inspection, no status checks. Both surfaces share this so they
  /// can never disagree on what a tap means.
  static Future<void> dispatchSlotAction({
    required BuildContext context,
    required HomeController homeController,
    required SlotPresentation presentation,
    required Slot slot,
  }) async {
    switch (presentation.action) {
      case SlotButtonAction.joinClass:
        final link = slot.trainerLink ?? '';
        if (link.isEmpty) return;
        try {
          if (link.contains('https')) {
            await launchUrl(Uri.parse(link));
          } else {
            await startMeeting(link, slot.id.toString());
          }
          homeController.sharedPreferences
              .setBool(Constants.giveReview, true);
        } catch (_) {
          showError('Could not start the session. Please try again.');
        }
        break;
      case SlotButtonAction.showToast:
        final msg = presentation.toastMessage;
        if (msg != null && msg.isNotEmpty) showError(msg);
        break;
      case SlotButtonAction.none:
        break;
    }
  }

  static startMeeting(
    String meetingNumber,
    String slotId,
  ) async {
    final authController = Get.find<AuthController>();
    final homeController = Get.find<HomeController>();
    final displayName = _buildMeetingDisplayName(
      authController: authController,
      homeController: homeController,
    );

    var success = await Get.find<ZoomMeetingGetxController>()
        .joinMeeting(meetingNumber, displayName);
    if (success) {
      Future.delayed(Duration(minutes: 5), () {
        Get.bottomSheet(isScrollControlled: true, FeedbackBottomSheet("0", "0"));
      });
    }
    Get.find<MotivationController>().markAttendance(slotId: slotId);
  }

  static String _buildMeetingDisplayName({
    required AuthController authController,
    required HomeController homeController,
  }) {
    final loginUser = authController.logInUser;
    final baseName = (loginUser?.fullName.trim().isNotEmpty ?? false)
        ? loginUser!.fullName.trim()
        : 'User';

    final tags = <String>[];
    final goal = loginUser?.mainGoal?.trim();
    final hasFreeTrial = homeController.userHomeData?.userAllPlans.any(
          (plan) => plan.title.trim().toLowerCase() == 'free trial',
        ) ??
        false;

    if (hasFreeTrial) {
      tags.add('Free Trial');
    }
    if (goal != null && goal.isNotEmpty) {
      tags.add(goal);
    }

    if (tags.isEmpty) return baseName;
    return '$baseName (${tags.join(', ')})';
  }

  static StatusType getStatusTypeFromString(String status) {
    switch (status) {
      case 'completed':
        return StatusType.completed;
      case 'canceled':
        return StatusType.canceled;
      case 'canceledByUser':
        return StatusType.canceledByUser;
      case 'pending':
        return StatusType.pending;
      case 'confirmed':
        return StatusType.confirmed;
      case 'delayed':
        return StatusType.delayed;
      default:
        return StatusType.pending; // fallback
    }
  }

  static getStatusColorAndIcon(String status) {
    StatusType statusType = getStatusTypeFromString(status ?? "");
    print('HelpingWidgets.getStatusColorAndIcon ${statusType}');
    print('HelpingWidgets.getStatusColorAndIcon ${status}');

    IconData icon;
    Color color;

    switch (statusType) {
      case StatusType.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case StatusType.canceled:
        icon = Icons.phone_missed;
        color = Colors.red;
        break;
      case StatusType.canceledByUser:
        icon = Icons.phone_missed;
        color = Colors.red;
        break;
      case StatusType.pending:
        icon = Icons.access_time;
        color = Colors.orange;
        break;
      case StatusType.confirmed:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case StatusType.delayed:
        icon = Icons.timelapse;
        color = Colors.orange;
        break;
    }
    return [icon, color];
  }

  static getDateFromTimeStamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate(); // Convert to Dart DateTime

    String formatted = DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    return formatted;
  }

  static bool isSessionValid(Slot slot, HomeController homeController) {
    if (!homeController.checkTiming(slot.start, slot.end)) {
      //   showError("The class has not started yet or has already passed.");
      return false;
    }
    return true;
  }

  static showError(String message) {
    CustomToast.failToast(msg: message);
  }
}
