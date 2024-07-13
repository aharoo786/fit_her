import 'package:fitness_zone_2/values/constants.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/controllers/home_controller/home_controller.dart';
import '../../../data/models/add_package/add_package_model.dart';
import '../../../data/models/get_all_cat_plan/get_all_categories.dart';
import '../../../helper/validators.dart';
import '../../../values/my_colors.dart';
import '../../../values/my_imgs.dart';
import '../../../widgets/app_bar_widget.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../widgets/custom_textfield.dart';
import '../../../widgets/toasts.dart';

class AddPackage extends StatelessWidget {
   AddPackage({super.key,this.isFromUpdate=false});
  final bool isFromUpdate;
  final HomeController homeController = Get.find();
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: isFromUpdate? "Update Package":"Add Package"),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20.h,
              ),
              CustomTextField(
                text: "Package name",
                length: 500,
                controller: homeController.packageName,
                validator: (value) =>
                    Validators.firstNameValidation(value!.toString()),
                keyboardType: TextInputType.text,
                inputFormatters:
                    FilteringTextInputFormatter.singleLineFormatter,
              ),
              SizedBox(
                height: 16.h,
              ),
              CustomTextField(
                text: "Description",
                length: 500,
                controller: homeController.shortDis,
                validator: (value) =>
                    Validators.firstNameValidation(value!.toString()),
                keyboardType: TextInputType.text,
                inputFormatters:
                    FilteringTextInputFormatter.singleLineFormatter,
              ),
              SizedBox(
                height: 16.h,
              ),
              CustomTextField(
                text: "Long Description",
                length: 500,
                controller: homeController.longDis,
                validator: (value) =>
                    Validators.emailValidator(value!.toString()),
                keyboardType: TextInputType.text,
                inputFormatters:
                    FilteringTextInputFormatter.singleLineFormatter,
              ),
              SizedBox(
                height: 16.h,
              ),
              CustomTextField(
                text: "Price",
                length: 500,
                controller: homeController.price,
                validator: (value) =>
                    Validators.emailValidator(value!.toString()),
                keyboardType: TextInputType.number,
                inputFormatters: FilteringTextInputFormatter.digitsOnly,
              ),
              SizedBox(
                height: 16.h,
              ),
              CustomTextField(
                keyboardType: TextInputType.text,
                text: "Duration".tr,
                length: 30,
                controller: homeController.packageDuration,
                Readonly: true,
                inputFormatters:
                    FilteringTextInputFormatter.singleLineFormatter,
                suffixIcon: GestureDetector(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                        context: context,
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              primaryColor: MyColors
                                  .buttonColor, // OK button background color
                              hintColor:
                                  MyColors.buttonColor, // OK button text color
                              dialogBackgroundColor:
                                  Colors.white, // Dialog background color
                            ),
                            child: child!,
                          );
                        },
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2099));
                    if (picked != null) {
                      homeController.packageDuration.text =
                          "${picked.difference(DateTime.now()).inDays} days";
                    }
                  },
                  child: Image.asset(
                    MyImgs.calender2,
                    scale: 3,
                  ),
                ),
              ),
              SizedBox(
                height: 16.h,
              ),
              Obx(() => homeController.getCatLoaded.value
                  ? Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        color: MyColors.textFieldColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<Category>(
                        style: TextStyle(
                            color: MyColors.textColor,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 12.h),
                          border: InputBorder.none,
                        ),

                        //padding: EdgeInsets.symmetric(horizontal: 10.w),
                        value:
                            homeController.allCategoriesOfPlan!.categories.firstWhere((element) => element.id==homeController.selectedId.value),
                        onChanged: (Category? newValue) {
                          if (newValue != null) {
                            homeController.selectedId.value = newValue.id;
                            // authController.memerDesig=newValue;

                            //authController.loginAsA.value = newValue;
                            // When a new item is selected, update the selectedFruit variable
                          }
                        },
                        items: homeController.allCategoriesOfPlan!.categories
                            .map((Category cat) {
                          return DropdownMenuItem<Category>(
                            value: cat,
                            child: Text(
                              cat.title,
                              style: textTheme.bodySmall!
                                  .copyWith(color: Colors.black),
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(
                      color: MyColors.buttonColor,
                    ))),
              SizedBox(
                height: 20.h,
              ),
              Obx(
                () => homeController.selectedId.value == 1
                    ? const SizedBox()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Add Time",
                            style: textTheme.headlineMedium!
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          GetBuilder<HomeController>(builder: (homeController) {
                            return ListView.separated(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, int index) {
                                  var dayTime =
                                      homeController.addPackageTimeTable[index];
                                  return ExpansionTile(
                                    onExpansionChanged: (bool value) {
                                      if (value) {}
                                    },
                                    trailing: const Icon(
                                        Icons.keyboard_arrow_down_rounded),
                                    tilePadding: EdgeInsets.zero,
                                    title: Text(
                                      dayTime.day,
                                      style: textTheme.bodyLarge,
                                    ),
                                    children: [
                                      ListView.separated(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder:
                                              (context, int timeIndex) {
                                            var slot = dayTime.slots[timeIndex];
                                            return Row(children: [
                                              GestureDetector(
                                                  onTap: () async {
                                                    TimeOfDay? time =
                                                        await showTimePicker(
                                                      context: context,
                                                      initialTime:
                                                          TimeOfDay.now(),
                                                      builder:
                                                          (BuildContext context,
                                                              Widget? child) {
                                                        return Theme(
                                                          data:
                                                              ThemeData.light()
                                                                  .copyWith(
                                                            primaryColor: Colors
                                                                .blue, // Change the primary color
                                                            dialogBackgroundColor:
                                                                Colors
                                                                    .white, // Change the dialog background color
                                                            textTheme:
                                                                const TextTheme(
                                                              bodyLarge: TextStyle(
                                                                  color: Colors
                                                                      .black), // Change the text color
                                                            ),
                                                          ),
                                                          child: child!,
                                                        );
                                                      },
                                                    );
                                                    if (time != null) {
                                                      slot.start =
                                                          time.format(context);
                                                      homeController.update();
                                                    }
                                                  },
                                                  child: Container(
                                                    height: 56.h,
                                                    width: 140.w,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 12.w),
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                            color:
                                                                Colors.black)),
                                                    child: Text(
                                                      slot.start,
                                                      style: slot.start ==
                                                              "Start Time"
                                                          ? TextStyle(
                                                              color: MyColors
                                                                  .hintText,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 14.sp)
                                                          : TextStyle(
                                                              color: MyColors
                                                                  .textColor,
                                                              fontSize: 16.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                    ),
                                                  )),
                                              SizedBox(
                                                width: 10.w,
                                              ),
                                              GestureDetector(
                                                  onTap: () async {
                                                    TimeOfDay? time =
                                                        await showTimePicker(
                                                      context: context,
                                                      initialTime:
                                                          TimeOfDay.now(),
                                                      builder:
                                                          (BuildContext context,
                                                              Widget? child) {
                                                        return Theme(
                                                          data:
                                                              ThemeData.light()
                                                                  .copyWith(
                                                            primaryColor: Colors
                                                                .blue, // Change the primary color
                                                            dialogBackgroundColor:
                                                                Colors
                                                                    .white, // Change the dialog background color
                                                            textTheme:
                                                                const TextTheme(
                                                              bodyLarge: TextStyle(
                                                                  color: Colors
                                                                      .black), // Change the text color
                                                            ),
                                                          ),
                                                          child: child!,
                                                        );
                                                      },
                                                    );
                                                    if (time != null) {
                                                      slot.end =
                                                          time.format(context);
                                                      homeController.update();
                                                    }
                                                  },
                                                  child: Container(
                                                    height: 56.h,
                                                    width: 140.w,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 12.w),
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                            color:
                                                                Colors.black)),
                                                    child: Text(
                                                      slot.end,
                                                      style: slot.end ==
                                                              "End Time"
                                                          ? TextStyle(
                                                              color: MyColors
                                                                  .hintText,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 14.sp)
                                                          : TextStyle(
                                                              color: MyColors
                                                                  .textColor,
                                                              fontSize: 16.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                    ),
                                                  )),
                                              SizedBox(
                                                width: 10.w,
                                              ),
                                              timeIndex ==
                                                      dayTime.slots.length - 1
                                                  ? GestureDetector(
                                                      onTap: () {
                                                        dayTime.slots.add(Slot(
                                                            start: "Start Time",
                                                            end: "End Time"));
                                                        homeController.update();
                                                      },
                                                      child: Container(
                                                        height: 40.h,
                                                        width: 40.h,
                                                        decoration: BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                                color: MyColors
                                                                    .buttonColor,
                                                                width: 2)),
                                                        child: const Icon(
                                                          Icons.add,
                                                          color: MyColors
                                                              .buttonColor,
                                                        ),
                                                      ),
                                                    )
                                                  : GestureDetector(
                                                      onTap: () {
                                                        dayTime.slots.removeAt(
                                                            timeIndex);
                                                        homeController.update();
                                                      },
                                                      child: Container(
                                                        height: 40.h,
                                                        width: 40.h,
                                                        decoration: BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                                color: MyColors
                                                                    .buttonColor,
                                                                width: 2)),
                                                        child: const Icon(
                                                          Icons.remove,
                                                          color: MyColors
                                                              .buttonColor,
                                                        ),
                                                      ),
                                                    )
                                            ]);
                                          },
                                          separatorBuilder:
                                              (context, int index) {
                                            return SizedBox(
                                              height: 10.h,
                                            );
                                          },
                                          itemCount: dayTime.slots.length)
                                    ],
                                  );
                                },
                                separatorBuilder: (context, int index) {
                                  return SizedBox(
                                    height: 10.h,
                                  );
                                },
                                itemCount:
                                    homeController.addPackageTimeTable.length);
                          }),
                        ],
                      ),
              ),
              SizedBox(
                height: 20.h,
              ),
              CustomButton(
                  text:isFromUpdate?"Update Package": "Add Package",
                  onPressed: () {
                    if (homeController.packageName.text.isEmpty ||
                        homeController.shortDis.text.isEmpty ||
                        homeController.longDis.text.isEmpty ||
                        homeController.price.text.isEmpty ||
                        homeController.packageDuration.text.isEmpty) {
                      CustomToast.failToast(
                          msg: "Please provide all information");
                    } else {
                      if(isFromUpdate){
                        homeController.updatePlan();
                      }
                      else{
                        homeController.addPlan();
                      }
                    }
                  }),
              SizedBox(
                height: 20.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
