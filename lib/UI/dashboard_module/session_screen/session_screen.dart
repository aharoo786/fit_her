import 'package:fitness_zone_2/data/controllers/workout_controller/work_out_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/controllers/home_controller/home_controller.dart';
import '../../../values/dimens.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../values/my_colors.dart';
import '../../../widgets/app_bar_widget.dart';
import '../../../widgets/circular_progress.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../widgets/toasts.dart';

class SessionScreen extends StatelessWidget {
  SessionScreen(
      {Key? key,
      required this.slotId,
      this.planId,
      this.link,
      this.isDiet = false,
      required this.userId,
      required this.token})
      : super(key: key);
  final int slotId;
  final String token;
  final bool isDiet;
  final int userId;
  final String? planId;
  String? link;
  final WorkOutController workOutController = Get.find();
  late TextEditingController googleMeet;
  // final TextEditingController googleMeet = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    googleMeet = TextEditingController(text: link ?? "");
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: ""),
      body: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: Dimens.size20.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Attach a link to your session "),
            SizedBox(
              height: 5,
            ),
            CustomTextField(
                text: "Paste Link",
                length: 10000,
                keyboardType: TextInputType.text,
                controller: googleMeet,
                inputFormatters:
                    FilteringTextInputFormatter.singleLineFormatter),
            SizedBox(
              height: 20.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CustomButton(
                        text: "Confirm",
                        width: 80,
                        height: 40,
                        fontSize: 12,
                        onPressed: () async {
                          Get.find<HomeController>()
                              .updateSlotStatus(slotId.toString(), "Confirmed");
                        }),
                    SizedBox(
                      width: 10,
                    ),
                    CustomButton(
                        text: "Cancel",
                        width: 80,
                        height: 40,
                        color: Colors.red,
                        borderColor: Colors.red,
                        fontSize: 12,
                        onPressed: () async {
                          Get.find<HomeController>()
                              .updateSlotStatus(slotId.toString(), "Cancelled");
                        }),
                  ],
                ),
                CustomButton(
                    text: "Update",
                    width: 80,
                    height: 40,
                    fontSize: 12,
                    onPressed: () async {
                      if (googleMeet.text.isEmpty) {
                        CustomToast.failToast(
                            msg: "Please provide link to update");
                      } else {
                        Get.find<HomeController>().updateLinkFunc(
                            googleMeet, slotId, isDiet, userId, planId ?? "");
                      }
                    }),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            CustomButton(
                text: "Start Session",
                onPressed: () async {
                  if (googleMeet.text.isEmpty) {
                    CustomToast.failToast(msg: "Please provide link to join");
                    return;
                  }
                  await Get.find<HomeController>()
                      .updateSlotStatus(slotId.toString(), "In Progress");
                  await launchUrl(Uri.parse(googleMeet.text));
                }),
            const SizedBox(
              height: 20,
            ),
            Text(
              "Free Trial Clients",
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
                child: Obx(
              () => workOutController.getFreeTrialUserDetailsLoad.value
                  ? ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        var report = workOutController.freeTrialUser[index];

                        return Container(
                          padding: EdgeInsets.all(20.h),
                          decoration: BoxDecoration(
                            color: MyColors.appBackground,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.black.withOpacity(0.6)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              reportRow(
                                "Name",
                                "${report.freeUserId?.firstName ?? ""} ${report.freeUserId?.lastName ?? ""}",
                                context,
                              ),
                              reportRow("Email", report.freeUserId?.email ?? "",
                                  context),
                              reportRow(
                                  "Main Goal", report.mainGoal ?? "", context),
                              reportRow("Any Specific Issue",
                                  report.specificIssues ?? "", context),
                              reportRow("Preference", report.prefrences ?? "",
                                  context),
                              reportRow("BMI Result",
                                  report.freeUserId?.bmiResult ?? "", context),
                              reportRow(
                                  "Requested Date",
                                  DateFormat("dd/MM/yyyy hh:mm a")
                                          .format(report.createdAt!) ??
                                      "",
                                  context),

                              if (report.freeUserSlots != null &&
                                  report.freeUserSlots!.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                const Text("Selected Slots",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                ...report.freeUserSlots!
                                    .map((slot) => Text(
                                        "${slot.slot?.start ?? ""} - ${slot.slot?.end ?? ""}"))
                                    .toList(),
                              ],

                              // Uncomment if needed later
                              // reportRow("1st Day Weight", report.weight, context),
                              // reportRow("Current Day Weight", report.currentWeight, context),
                            ],
                          ),
                        );
                      },
                      itemCount: workOutController.freeTrialUser.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          height: 20.h,
                        );
                      },
                    )
                  : CircularProgress(),
            ))
          ],
        ),
      ),
    );
  }

  Widget reportRow(String text1, String text2, context) {
    var textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Row(
          // crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text1,
              style: textTheme.bodyMedium!.copyWith(
                  color: MyColors.textColor.withOpacity(0.6),
                  fontWeight: FontWeight.w400),
            ),
            Text(
              text2,
              style: textTheme.bodySmall!.copyWith(
                  color: MyColors.textColor, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        SizedBox(
          height: 5.h,
        )
      ],
    );
  }

  // Future<void> _handleCameraAndMic(Permission permission) async {
  //   final status = await permission.request();
  //   print(status);
  // }
}

// Future<void> _pickVideo(BuildContext context) async {
//   try {
//     PermissionOfPhotos().getFromGallery(context).then((value) async {
//       if (value) {
//         XFile? pickedVideo =
//             await ImagePicker().pickVideo(source: ImageSource.gallery);
//         if (pickedVideo != null) {
//           Get.find<HomeController>()
//               .uploadBytesToFirebaseStorage(pickedVideo.path);
//         }
//       }
//     });
//   } catch (e) {
//     print('Error picking video: $e');
//   }
// }
