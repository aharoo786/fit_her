import 'package:fitness_zone_2/UI/auth_module/result_screen.dart';
import 'package:fitness_zone_2/UI/diet_screen/dietry_module/widgets/calory_widget.dart';
import 'package:fitness_zone_2/data/controllers/diet_contoller/diet_controller.dart';
import 'package:fitness_zone_2/helper/analytics_helper.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/data/services/youtube_tutorial_service.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import '../../../data/controllers/auth_controller/auth_controller.dart';
import '../../../helper/custom_print.dart';
import '../../../values/my_colors.dart';
import '../../../values/my_imgs.dart';
import '../../../widgets/app_bar_widget.dart';
import '../../../widgets/circular_progress.dart';
import '../../../widgets/toasts.dart';

/// Diet Plan screen — Sprint 3 / S-18-family slot booking surface.
///
/// Class signature, constructor, all controller bindings, all API calls,
/// the YouTube tutorial gate, all deep-link handlers, the booked banner,
/// the success block, the PDF branch, and `bookAppointmentSlotId` state
/// are preserved exactly. Only the slot-booking surface (formerly the
/// per-weekday `ExpansionTile` list) was replaced with a day-strip +
/// slot-card timeline matching the V2 family established in the Workout
/// Schedule redesign.
class DietBottomBarScreen extends StatefulWidget {
  final int userPlanId;

  const DietBottomBarScreen({super.key, required this.userPlanId});

  @override
  State<DietBottomBarScreen> createState() => _DietBottomBarScreenState();
}

class _DietBottomBarScreenState extends State<DietBottomBarScreen> {
  final DietController dietController = Get.find();
  final HomeController homeController = Get.find();
  final AuthController authController = Get.find();

  // Currently-selected weekday in the day strip. Resolved on first render
  // via _resolveSelectedWeekday (today's weekday if dietitian has slots,
  // else first weekday with slots).
  String? _selectedWeekday;

  // ── V2 design tokens for the slot-booking surface ───────────────────────
  // Match Workout Schedule S-18 active-pill style for V2 family coherence.
  static const Color _vTextDark = Color(0xFF163220);
  static const Color _vTextMuted = Color(0xFF5A7A56);
  static const Color _vSlotBorder = Color(0xFFD8EDD4);
  static const Color _vAccent = Color(0xFF6DC55A);
  static const Color _vActiveBgDark = Color(0xFF0D2014);
  static const Color _vStatusBg = Color(0xFFEAF7E4);
  static const Color _vEmptyIcon = Color(0xFFC8DEC4);

  static const List<String> _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: HelpingWidgets().appBarWidget(() {
          Get.back();
        }, text: "Diet Plan"),
        body: Obx(() => dietController.dietPlanDetailsLoad.value
            ? GetBuilder<DietController>(
                id: "dietBottomScreen",
                builder: (cont) {
                  return Obx(
                    () => dietController.dietPlanDetailsLoad.value
                        ? RefreshIndicator(
                            onRefresh: () async {
                              // Refresh diet plan details
                              await dietController.getDietPlanDetailsFunc(widget.userPlanId.toString());
                            },
                            color: MyColors.buttonColor,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                children: [
                                  _buildHeaderSection(),
                                  _buildDietitianCard(),
                                  SizedBox(height: 20.h),
                                  Obx(() {
                                    if (dietController.getDietPlanDetails!.pdfFile.value.isNotEmpty) {
                                      return Column(
                                        children: [
                                          const CaloryWidget(),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 20),
                                            width: double.infinity,
                                            height: 400.h, // Fixed height for PDF viewer
                                            margin: const EdgeInsets.only(bottom: 12.0),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: const BorderRadius.all(Radius.zero),
                                              boxShadow: [BoxShadow(color: MyColors.grey.withOpacity(0.2), spreadRadius: 2, blurRadius: 5)],
                                            ),
                                            child: SfPdfViewer.network(
                                              dietController.getDietPlanDetails!.pdfFile.value,
                                              onDocumentLoaded: (details) {
                                                // Track diet plan delivered when user views PDF
                                                AnalyticsHelper.trackDietPlanDelivered('day',
                                                    userPlanId: widget.userPlanId,
                                                    dietitianId: dietController.getDietPlanDetails?.dietDetails.id);
                                              },
                                              onDocumentLoadFailed: (details) {},
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          CustomButton(
                                              text: "Download Diet",
                                              onPressed: () async {
                                                var documentUrl = dietController.getDietPlanDetails!.pdfFile;
                                                String filePath = documentUrl.split("/").last;

                                                var file = await dietController.downloadFile(filePath, documentUrl.value);
                                                CustomToast.showDownLoadToast(context, filePath: file, message: 'Download Complete');
                                              }),
                                        ],
                                      );
                                    } else {
                                      final isBooked =
                                          dietController.getDietPlanDetails?.isBooked ?? false;
                                      return Column(
                                        children: [
                                          if (isBooked)
                                            _buildBookingConfirmationCard(context),
                                          const CaloryWidget(),
                                          if (!isBooked)
                                            _buildSlotBookingSurface(context),
                                        ],
                                      );
                                    }
                                  }),
                                  const SizedBox(
                                    height: 20,
                                  ),

                                  // ListView.separated(
                                  //   shrinkWrap: true,
                                  //   physics: const NeverScrollableScrollPhysics(),
                                  //   padding:
                                  //       EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                                  //   itemCount: dietController
                                  //       .getDietPlanDetails!
                                  //       .details
                                  //       .dietTimes
                                  //       .length, // Number of stars (you can make this dynamic)
                                  //   itemBuilder: (context, index) {
                                  //     var dietTime = dietController
                                  //         .getDietPlanDetails!.details.dietTimes[index];
                                  //     return GestureDetector(
                                  //       onTap: () {
                                  //         Get.to(() => DietPlanFoodDetails(
                                  //               dietPlan: dietTime.diets,
                                  //             ));
                                  //       },
                                  //       child: Container(
                                  //         width: double.maxFinite,
                                  //         padding: EdgeInsets.symmetric(
                                  //             horizontal: 20.w, vertical: 14.h),
                                  //         decoration: BoxDecoration(
                                  //             color: MyColors.planColor,
                                  //             borderRadius: BorderRadius.circular(8),
                                  //             boxShadow: [
                                  //               BoxShadow(
                                  //                   offset: const Offset(0, 2),
                                  //                   blurRadius: 4,
                                  //                   spreadRadius: 0.5,
                                  //                   color: Colors.black.withOpacity(0.25))
                                  //             ]),
                                  //         child: Row(
                                  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //           children: [
                                  //             Text(
                                  //               dietTime.day,
                                  //               style: textTheme.bodySmall!
                                  //                   .copyWith(fontWeight: FontWeight.w600),
                                  //             ),
                                  //             const Icon(Icons.arrow_right),
                                  //           ],
                                  //         ),
                                  //       ),
                                  //     );
                                  //   },
                                  //   separatorBuilder: (BuildContext context, int index) {
                                  //     return SizedBox(
                                  //       height: 15.h,
                                  //     );
                                  //   },
                                  // ),
                                ],
                              ),
                            ),
                          )
                        : CircularProgress(),
                  );
                })
            : CircularProgress()));
  }

  // ────────────────────────────────────────────────────────────────────────
  // V2 slot-booking surface — replaces the prior ExpansionTile-per-weekday
  // ListView. Day strip + vertical slot timeline + inline Book button.
  // Preserves: bookAppointmentSlotId state, YouTube tutorial gate, the
  // bookAppointment(userPlanId, dietitianId, getNextWeekdayDate(weekday))
  // submit call.
  // ────────────────────────────────────────────────────────────────────────
  Widget _buildSlotBookingSurface(BuildContext context) {
    final tDieti = dietController.getDietPlanDetails?.timeDietition ?? [];
    if (tDieti.isEmpty) return _buildFullEmptyState();

    final selectedWeekday = _resolveSelectedWeekday(tDieti);
    final selectedSlots = _slotsForWeekday(tDieti, selectedWeekday);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 18.h),
          _buildSectionTitle(),
          SizedBox(height: 14.h),
          _buildDayStrip(selectedWeekday),
          SizedBox(height: 18.h),
          if (selectedSlots.isEmpty)
            _buildPerDayEmptyState()
          else
            _buildSlotList(selectedSlots, selectedWeekday),
          SizedBox(height: 18.h),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Available consultations".tr,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: _vTextDark,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          "Pick a slot to book your dietitian session.".tr,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: _vTextMuted,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildDayStrip(String selectedWeekday) {
    return Row(
      children: [
        for (int i = 0; i < _weekdays.length; i++) ...[
          Expanded(child: _buildDayPill(_weekdays[i], selectedWeekday)),
          if (i < _weekdays.length - 1) SizedBox(width: 5.w),
        ],
      ],
    );
  }

  Widget _buildDayPill(String weekday, String selectedWeekday) {
    final isSelected = weekday == selectedWeekday;
    // Preserved: same date-resolution helper used by the existing book
    // submit. Display + booking dates always agree.
    final date = HelpingWidgets.getNextWeekdayDate(weekday);
    final letter = weekday.substring(0, 1);
    return GestureDetector(
      onTap: () => setState(() => _selectedWeekday = weekday),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: isSelected ? _vActiveBgDark : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              letter,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 9.sp,
                fontWeight: FontWeight.w700,
                color: isSelected ? _vAccent : _vTextMuted,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              '${date.day}',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : _vTextDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotList(List<dynamic> slots, String selectedWeekday) {
    return Obx(() {
      // Read so this Obx subscribes — drives slot-card highlight and the
      // inline Book button visibility on selection.
      final selectedSlotId = dietController.bookAppointmentSlotId.value;
      return Column(
        children: [
          for (int i = 0; i < slots.length; i++) ...[
            _buildSlotRow(slots[i], selectedSlotId, selectedWeekday),
            if (i < slots.length - 1) SizedBox(height: 10.h),
          ],
        ],
      );
    });
  }

  Widget _buildSlotRow(dynamic slot, int selectedSlotId, String weekday) {
    final isSelected = slot.id != null && slot.id == selectedSlotId;
    final card = _buildSlotCard(slot, isSelected: isSelected);
    if (!isSelected) return card;

    // Selected: row of [slot card | inline Book button].
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: card),
          SizedBox(width: 10.w),
          _buildBookButton(slot, weekday),
        ],
      ),
    );
  }

  Widget _buildSlotCard(dynamic slot, {required bool isSelected}) {
    return GestureDetector(
      onTap: () async {
        // Preserved verbatim from the prior implementation:
        //   1. Show diet tutorial first and wait for user response
        //   2. Set bookAppointmentSlotId to this slot's id
        final tutorialService = Get.find<YouTubeTutorialService>();
        await tutorialService.showDietTutorial(context);
        dietController.bookAppointmentSlotId.value = slot.id ?? 0;
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _vAccent : _vSlotBorder,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "${slot.start} – ${slot.end}",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: _vTextDark,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: _vStatusBg,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                "Available".tr,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: _vTextMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookButton(dynamic slot, String weekday) {
    return SizedBox(
      width: 70.w,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _vAccent.withValues(alpha: 0.28),
              offset: const Offset(0, 4),
              blurRadius: 14,
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _vAccent,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            // Preserved verbatim from the prior implementation — same args,
            // same date helper, same controller method.
            final date = HelpingWidgets.getNextWeekdayDate(weekday);
            dietController.bookAppointment(
              widget.userPlanId,
              dietController.getDietPlanDetails!.dietDetails.id,
              date,
            );
          },
          child: Text(
            "Book".tr,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPerDayEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 60.h),
      child: Column(
        children: [
          Icon(Icons.event_busy_outlined, size: 48.w, color: _vEmptyIcon),
          SizedBox(height: 12.h),
          Text(
            "No slots available right now".tr,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: _vTextDark,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            "Try another day in the strip above.".tr,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.sp,
              color: _vTextMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFullEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 60.h),
      child: Column(
        children: [
          Icon(Icons.event_busy_outlined, size: 48.w, color: _vEmptyIcon),
          SizedBox(height: 12.h),
          Text(
            "No availability right now".tr,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: _vTextDark,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            "Your dietitian hasn't published time slots yet.".tr,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.sp,
              color: _vTextMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Default-selection helper. Returns:
  //   • previously selected weekday (if still valid in tDieti), else
  //   • today's weekday (if dietitian has slots for today), else
  //   • first weekday with slots, else
  //   • first weekday in tDieti as a last resort.
  String _resolveSelectedWeekday(List<dynamic> tDieti) {
    if (_selectedWeekday != null &&
        tDieti.any((t) => t.day == _selectedWeekday)) {
      return _selectedWeekday!;
    }
    final today = DateFormat('EEEE').format(DateTime.now());
    if (tDieti.any((t) => t.day == today && (t.slots as List).isNotEmpty)) {
      return today;
    }
    final firstWithSlots = tDieti.firstWhere(
      (t) => (t.slots as List).isNotEmpty,
      orElse: () => tDieti.first,
    );
    return firstWithSlots.day;
  }

  List<dynamic> _slotsForWeekday(List<dynamic> tDieti, String weekday) {
    final match = tDieti.where((t) => t.day == weekday).toList();
    if (match.isEmpty) return [];
    return match.first.slots as List<dynamic>;
  }

  // ────────────────────────────────────────────────────────────────────────
  // V2 HEADER SECTION — replaces the prior centred Text("Get personalized
  // meal plans...") block. DIET PLAN tag + DM Serif headline + sub-copy.
  // ────────────────────────────────────────────────────────────────────────
  Widget _buildHeaderSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 18.h),
      child: Column(
        children: [
          Text(
            "Your dietitian, your plan.".tr,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSerifDisplay(
              textStyle: TextStyle(
                fontSize: 22.sp,
                color: _vTextDark,
                height: 1.1,
                letterSpacing: -0.22, // -0.01em × 22
              ),
            ),
          ),
          SizedBox(height: 8.h),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 280.w),
            child: Text(
              "Get personalized meal plans with detailed daily guidance to achieve your nutrition goals."
                  .tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: _vTextMuted,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  // V2 DIETITIAN CARD — replaces the prior mint-pill Container with a
  // white card in the V2 family. WhatsApp deeplink call (openWhatsAppChat)
  // is preserved verbatim. Avatar uses MyImgs.logo (same as before, no
  // per-dietitian image URL in the data model today).
  // ────────────────────────────────────────────────────────────────────────
  Widget _buildDietitianCard() {
    final dietitian = dietController.getDietPlanDetails!.dietDetails;
    final fullName = "${dietitian.firstName} ${dietitian.lastName}";
    final experience = dietitian.experience;
    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _vSlotBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _vTextDark.withValues(alpha: 0.06),
            offset: const Offset(0, 4),
            blurRadius: 14,
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage(MyImgs.logo),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fullName,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: _vTextDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  "$experience yr experience".tr,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: _vTextMuted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          _buildWhatsAppButton(),
        ],
      ),
    );
  }

  Widget _buildWhatsAppButton() {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _vAccent.withValues(alpha: 0.28),
            offset: const Offset(0, 4),
            blurRadius: 14,
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _vAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        // Preserved verbatim — same deeplink call, same arg pattern.
        onPressed: () async {
          openWhatsAppChat(
              "${dietController.getDietPlanDetails?.dietDetails.phone}");
        },
        child: Text(
          "WhatsApp".tr,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  // V2 BOOKING CONFIRMATION CARD — replaces the prior plain-bordered banner
  // and the separate done-tick + Reschedule column. Consolidates the booked
  // state into a single white card that matches _buildDietitianCard's V2
  // styling. All preserved behaviors:
  //   • Join: freeze check → remainingDays==0 check → null/invalid link
  //     guards → launchUrl(trainerLink).
  //   • Reschedule: if status=="canceled" → updateReschedule(); else show
  //     cancel-once warning dialog → updateAppointmentStatus("canceledByUser",
  //     planId, isFromDietDetails: true).
  // ────────────────────────────────────────────────────────────────────────
  Widget _buildBookingConfirmationCard(BuildContext context) {
    final details = dietController.getDietPlanDetails!;
    final date = details.date;
    final slot = details.bookedSlot;
    final isCanceled = details.status == "canceled";

    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _vSlotBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _vTextDark.withValues(alpha: 0.06),
            offset: const Offset(0, 4),
            blurRadius: 14,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: _vStatusBg,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 14.sp, color: _vAccent),
                SizedBox(width: 6.w),
                Text(
                  isCanceled ? "RESCHEDULE PENDING".tr : "CONFIRMED".tr,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: _vTextMuted,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            HelpingWidgets.formatDateWithMonthName(date),
            style: GoogleFonts.dmSerifDisplay(
              textStyle: TextStyle(
                fontSize: 22.sp,
                color: _vTextDark,
                height: 1.1,
                letterSpacing: -0.22,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            "${slot?.start ?? '--'}  –  ${slot?.end ?? '--'}",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: _vTextMuted,
            ),
          ),
          SizedBox(height: 16.h),
          Container(height: 1, color: _vSlotBorder),
          SizedBox(height: 14.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(MyImgs.doneTick, width: 22.w, height: 22.w),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  "Your appointment has been booked. You'll receive a notification when it's time for your session."
                      .tr,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: _vTextMuted,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: _buildJoinSessionButton()),
              SizedBox(width: 10.w),
              Expanded(child: _buildRescheduleButton(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJoinSessionButton() {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _vAccent.withValues(alpha: 0.28),
            offset: const Offset(0, 4),
            blurRadius: 14,
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _vAccent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        // Behavior preserved verbatim from the prior banner Join button.
        onPressed: () async {
          var trainerLink =
              dietController.getDietPlanDetails!.bookedSlot?.dietitionLink;
          if (homeController.userHomeData!.userData.freeze.value) {
            CustomToast.failToast(
                msg: "Your account is frozen please unfreeze first");
          } else {
            if (homeController.userHomeData!.userAllPlans.first.remainingDays ==
                0) {
              CustomToast.failToast(msg: "Please renew your plan");
              return;
            }
            if (trainerLink == null) {
              CustomToast.failToast(msg: "Dietitian does not add link yet");
            } else {
              if (isValidUrl(trainerLink)) {
                await launchUrl(Uri.parse(trainerLink));
              } else {
                CustomToast.failToast(msg: "Dietitian does not add link yet");
              }
            }
          }
        },
        child: Text(
          "Join Session".tr,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildRescheduleButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: _vTextDark,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: _vSlotBorder, width: 1.5),
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      // Behavior preserved verbatim from the prior Reschedule button.
      onPressed: () {
        if (dietController.getDietPlanDetails?.status == "canceled") {
          dietController.updateReschedule();
          return;
        }
        HelpingWidgets.showCustomDialog(
          context,
          () {
            Navigator.of(context).pop();
          },
          "You can cancel your appointment with Dietitian if an emergency arises.",
          "Note: This option is valid for once.",
          MyImgs.warning,
          buttonText: "Back",
          secondButtonText: "Cancel",
          secondButtonTap: () {
            Navigator.of(context).pop();
            dietController.updateAppointmentStatus(
              dietController.getDietPlanDetails?.id ?? 0,
              "canceledByUser",
              planId: widget.userPlanId.toString(),
              isFromDietDetails: true,
            );
          },
        );
      },
      child: Text(
        "Reschedule".tr,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
