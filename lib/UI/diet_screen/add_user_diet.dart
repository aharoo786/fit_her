import 'package:fitness_zone_2/data/controllers/diet_contoller/diet_controller.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/widgets/toasts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/controllers/auth_controller/auth_controller.dart';
import '../../../values/my_imgs.dart';
import '../../../widgets/app_bar_widget.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../widgets/custom_button.dart';
import 'package:file_picker/file_picker.dart';
import '../../data/models/get_all_dietitian_trainers/add_diet_of_user.dart';
import '../../helper/validators.dart';
import '../../values/my_colors.dart';
import 'dart:io';

import '../../widgets/custom_textfield.dart';

class AddUserDiet extends StatelessWidget {
  AddUserDiet({Key? key, required this.userId, required this.planId})
      : super(key: key);
  final AuthController authController = Get.find();
  final HomeController homeController = Get.find();
  final DietController dietController = Get.find();
  final String userId;
  final String planId;

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () {
          return Future.value(true);
        },
        child: Scaffold(
          appBar: HelpingWidgets().appBarWidget(() {
            Get.back();
          }, text: "Add User Diet"),
          body:
          GetBuilder<DietController>(
            builder: (cont) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (dietController.addDietPdfFil == null) ...{
                      GestureDetector(
                        onTap: () {
                          pickPdf();
                        },
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              MyImgs.upload,
                            ),
                            SizedBox(
                              width: 190,
                              child: Text(
                                "Upload User Diet",
                                style: textTheme.titleLarge!.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    } else
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(bottom: 12.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.all(Radius.zero),
                                boxShadow: [
                                  BoxShadow(
                                      color: MyColors.grey.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 5)
                                ],
                              ),
                              child: SfPdfViewer.file(
                                dietController.addDietPdfFil!,
                                onDocumentLoadFailed: (details) {},
                              ),
                            ),
                              Padding(
                               padding: EdgeInsets.all(8.0),
                               child: GestureDetector(
                                 onTap: (){
                                   dietController.addDietPdfFil=null;
                                   dietController.update();
                                 },
                                 child: CircleAvatar(
                                   backgroundColor: Colors.white,
                                   child: Icon(Icons.clear,color: Colors.black,),
                                 ),
                               ),
                             )
                          ],
                        ),
                      ),
                  ],
                ),
              );
            }
          ),

          // GetBuilder<HomeController>(builder: (homeController) {
          //   return ListView.separated(
          //       // physics: const NeverScrollableScrollPhysics(),
          //       shrinkWrap: true,
          //       padding: EdgeInsets.symmetric(horizontal: 20),
          //       itemBuilder: (context, int index) {
          //         var dayDiet = homeController.dietOfUserByDiet[index];
          //         return ExpansionTile(
          //           onExpansionChanged: (bool value) {
          //             if (value) {}
          //           },
          //           trailing: const Icon(Icons.keyboard_arrow_down_rounded),
          //           collapsedIconColor: Colors.black,
          //           iconColor: Colors.black,
          //           tilePadding: EdgeInsets.zero,
          //           title: Text(
          //             dayDiet.day,
          //             style: textTheme.bodyLarge,
          //           ),
          //           children: [
          //             ListView.separated(
          //                 shrinkWrap: true,
          //                 physics: const NeverScrollableScrollPhysics(),
          //                 itemBuilder: (context, int timeIndex) {
          //                   var slotDiet = dayDiet.meals[timeIndex];
          //                   return Column(
          //                     children: [
          //                       Column(
          //                         crossAxisAlignment: CrossAxisAlignment.start,
          //                         children: [
          //                           CustomTextField(
          //                             text: "Diet Name",
          //                             length: 500,
          //                             controller: slotDiet.dietName,
          //                             validator: (value) =>
          //                                 Validators.firstNameValidation(
          //                                     value!.toString()),
          //                             keyboardType: TextInputType.emailAddress,
          //                             inputFormatters:
          //                                 FilteringTextInputFormatter
          //                                     .singleLineFormatter,
          //                           ),
          //                           SizedBox(
          //                             height: 16.h,
          //                           ),
          //                           CustomTextField(
          //                             text: "Description",
          //                             controller: slotDiet.description,
          //                             length: 500,
          //                             onChanged: (String value) {
          //                               slotDiet.addText =
          //                                   "food=${slotDiet.dietName.text}&description=${slotDiet.description.text}&alternatives=${slotDiet.alternatives.text}";
          //                             },
          //                             validator: (value) =>
          //                                 Validators.emailValidator(
          //                                     value!.toString()),
          //                             keyboardType: TextInputType.text,
          //                             inputFormatters:
          //                                 FilteringTextInputFormatter
          //                                     .singleLineFormatter,
          //                           ),
          //                           SizedBox(
          //                             height: 16.h,
          //                           ),
          //                           CustomTextField(
          //                             text: "Alternatives",
          //                             length: 500,
          //                             onChanged: (String value) {
          //                               slotDiet.addText =
          //                                   "food=${slotDiet.dietName.text}&description=${slotDiet.description.text}&alternatives=${slotDiet.alternatives.text}";
          //                             },
          //                             controller: slotDiet.alternatives,
          //                             validator: (value) =>
          //                                 Validators.emailValidator(
          //                                     value!.toString()),
          //                             keyboardType: TextInputType.text,
          //                             inputFormatters:
          //                                 FilteringTextInputFormatter
          //                                     .singleLineFormatter,
          //                           ),
          //                           SizedBox(
          //                             height: 16.h,
          //                           ),
          //                           CustomTextField(
          //                             text: "KCAL",
          //                             length: 500,
          //                             controller: slotDiet.kcal,
          //                             validator: (value) =>
          //                                 Validators.emailValidator(
          //                                     value!.toString()),
          //                             keyboardType: TextInputType.number,
          //                             inputFormatters:
          //                                 FilteringTextInputFormatter
          //                                     .digitsOnly,
          //                           ),
          //                           SizedBox(
          //                             height: 16.h,
          //                           ),
          //                         ],
          //                       ),
          //                       Row(
          //                           mainAxisAlignment:
          //                               MainAxisAlignment.spaceBetween,
          //                           children: [
          //                             GestureDetector(
          //                                 onTap: () async {
          //                                   TimeOfDay? time =
          //                                       await showTimePicker(
          //                                     context: context,
          //                                     initialTime: TimeOfDay.now(),
          //                                     builder: (BuildContext context,
          //                                         Widget? child) {
          //                                       return Theme(
          //                                         data: ThemeData.light()
          //                                             .copyWith(
          //                                           primaryColor: Colors
          //                                               .blue, // Change the primary color
          //                                           dialogBackgroundColor: Colors
          //                                               .white, // Change the dialog background color
          //                                           textTheme: const TextTheme(
          //                                             bodyLarge: TextStyle(
          //                                                 color: Colors
          //                                                     .black), // Change the text color
          //                                           ),
          //                                         ),
          //                                         child: child!,
          //                                       );
          //                                     },
          //                                   );
          //                                   if (time != null) {
          //                                     slotDiet.time =
          //                                         time.format(context);
          //                                     homeController.update();
          //                                   }
          //                                 },
          //                                 child: Container(
          //                                   height: 56.h,
          //                                   width: 140.w,
          //                                   padding: EdgeInsets.symmetric(
          //                                       horizontal: 12.w),
          //                                   alignment: Alignment.centerLeft,
          //                                   decoration: BoxDecoration(
          //                                       color: MyColors.textFieldColor,
          //                                       borderRadius:
          //                                           BorderRadius.circular(8),
          //                                       border: Border.all(
          //                                           color: Colors.black)),
          //                                   child: Text(
          //                                     slotDiet.time,
          //                                     style: slotDiet.time == "Time"
          //                                         ? TextStyle(
          //                                             color: MyColors.hintText,
          //                                             fontWeight:
          //                                                 FontWeight.normal,
          //                                             fontSize: 14.sp)
          //                                         : TextStyle(
          //                                             color: MyColors.textColor,
          //                                             fontSize: 16.sp,
          //                                             fontWeight:
          //                                                 FontWeight.w400),
          //                                   ),
          //                                 )),
          //                             timeIndex == dayDiet.meals.length - 1
          //                                 ? GestureDetector(
          //                                     onTap: () {
          //                                       dayDiet.meals.add(MealOfUser(
          //                                           time: "Time",
          //                                           food: "N/A",
          //                                           calories: "N/A"));
          //                                       homeController.update();
          //                                     },
          //                                     child: Container(
          //                                       height: 40.h,
          //                                       width: 40.h,
          //                                       decoration: BoxDecoration(
          //                                           shape: BoxShape.circle,
          //                                           border: Border.all(
          //                                               color: MyColors
          //                                                   .buttonColor,
          //                                               width: 2)),
          //                                       child: const Icon(
          //                                         Icons.add,
          //                                         color: MyColors.buttonColor,
          //                                       ),
          //                                     ),
          //                                   )
          //                                 : GestureDetector(
          //                                     onTap: () {
          //                                       dayDiet.meals
          //                                           .removeAt(timeIndex);
          //                                       homeController.update();
          //                                     },
          //                                     child: Container(
          //                                       height: 40.h,
          //                                       width: 40.h,
          //                                       decoration: BoxDecoration(
          //                                           shape: BoxShape.circle,
          //                                           border: Border.all(
          //                                               color: MyColors
          //                                                   .buttonColor,
          //                                               width: 2)),
          //                                       child: const Icon(
          //                                         Icons.remove,
          //                                         color: MyColors.buttonColor,
          //                                       ),
          //                                     ),
          //                                   )
          //                           ]),
          //                     ],
          //                   );
          //                 },
          //                 separatorBuilder: (context, int index) {
          //                   return SizedBox(
          //                     height: 10.h,
          //                   );
          //                 },
          //                 itemCount: dayDiet.meals.length)
          //           ],
          //         );
          //       },
          //       separatorBuilder: (context, int index) {
          //         return SizedBox(
          //           height: 10.h,
          //         );
          //       },
          //       itemCount: homeController.dietOfUserByDiet.length);
          // }),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomButton(
                    text: "Update Diet".tr,
                    onPressed: () async {
                      // for (var diet in homeController.dietOfUserByDiet) {
                      //   for (var slotDiet in diet.meals) {
                      //     slotDiet.food = slotDiet.addText;
                      //     slotDiet.calories = slotDiet.kcal.text;
                      //   }
                      // }
                      //
                      // homeController.updateUserDietOfWeek(userId, planId);

                      if(dietController.addDietPdfFil==null){
                        CustomToast.successToast(msg: "Please select pdf first");
                      }
                      else{
                        dietController.addDietPdFFile(planId,userId);
                      }

                      // onBack();
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pickPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // restrict to PDF files
    );

    if (result != null) {
      dietController.addDietPdfFil = File(result.files.single.path!);
      dietController.update();
    } else {
      dietController.addDietPdfFil = null;
    }
  }
}
