import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/controllers/auth_controller/auth_controller.dart';
import '../../../values/dimens.dart';
import '../../../values/my_colors.dart';
import '../../../values/my_imgs.dart';
import '../../../widgets/app_bar_widget.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../widgets/circular_progress.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/toasts.dart';

class AddNewUser extends StatelessWidget {
  AddNewUser({Key? key, this.isMember = false}) : super(key: key);
  final bool isMember;
  final AuthController authController = Get.find();
  final HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: isMember ? "Add Member" : "Add User"),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimens.size20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: Dimens.size32.h,
              ),
              CustomTextField(
                keyboardType: TextInputType.text,
                text: "First Name".tr,
                length: 30,
                controller: homeController.firstNameController,
                inputFormatters:
                    FilteringTextInputFormatter.singleLineFormatter,
              ),
              SizedBox(
                height: 20.h,
              ),
              CustomTextField(
                keyboardType: TextInputType.text,
                text: "Last Name".tr,
                length: 30,
                controller: homeController.lastNameController,
                inputFormatters:
                    FilteringTextInputFormatter.singleLineFormatter,
              ),
              SizedBox(
                height: 20.h,
              ),
              CustomTextField(
                keyboardType: TextInputType.text,
                text: "Email".tr,
                length: 30,
                controller: homeController.emailController,
                inputFormatters:
                    FilteringTextInputFormatter.singleLineFormatter,
              ),
              SizedBox(
                height: 20.h,
              ),
              CustomTextField(
                keyboardType: TextInputType.text,
                text: "Phone no".tr,
                length: 30,
                controller: homeController.phoneController,
                inputFormatters:
                    FilteringTextInputFormatter.singleLineFormatter,
              ),
              SizedBox(
                height: 20.h,
              ),
              CustomTextField(
                keyboardType: TextInputType.text,
                text: "Password".tr,
                length: 30,
                controller: homeController.passwordController,
                inputFormatters:
                    FilteringTextInputFormatter.singleLineFormatter,
              ),
              SizedBox(
                height: 20.h,
              ),
              Obx(() => homeController.getPlanLoaded.value
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isMember
                            ? Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  color: MyColors.textFieldColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonFormField<String>(
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
                                  value: homeController.addTeamMember[0],
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      homeController.addedTeamMember.value =
                                          newValue;
                                    }
                                  },
                                  items: homeController.addTeamMember
                                      .map((String cat) {
                                    return DropdownMenuItem<String>(
                                      value: cat,
                                      child: Text(
                                        cat,
                                        style: textTheme.bodySmall!
                                            .copyWith(color: Colors.black),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              )
                            : SizedBox(),
                        SizedBox(
                          height: isMember ? 20.h : 0,
                        ),
                        Text(
                          "Select Plan",
                          style: textTheme.headlineMedium!
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        isMember
                            ? SizedBox(
                                height: 170.h,
                                child:
                                   ListView.separated(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 20.h),
                                    itemCount:
                                        homeController.allPlanModel!.plans.length,
                                    // homeController
                                    //             .addedTeamMember.value ==
                                    //         "Trainer"
                                    //     ? homeController
                                    //         .trainerPlanList.value.length
                                    //     : homeController
                                    //         .dietPlanList.value.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      var plan = homeController.allPlanModel!.plans[index];

                                      // homeController
                                      //             .addedTeamMember.value ==
                                      //         "Trainer"
                                      //     ? homeController
                                      //         .trainerPlanList.value[index]
                                      //     : homeController
                                      //         .dietPlanList.value[index];
                                      var id = homeController
                                                  .addedTeamMember.value ==
                                              "Trainer"
                                          ? homeController
                                              .selectedTrainerIdForMember
                                          : homeController
                                              .selectedDietIdForMember;
                                      return GestureDetector(
                                        onTap: () {
                                          id.value = plan.id;
                                          homeController
                                              .selectedPlanIndex.value = index;
                                        },
                                        child: Obx(
                                          () => Container(
                                            width: 300.w,
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                    color: id.value == plan.id
                                                        ? MyColors.buttonColor
                                                        : Colors.white),
                                                boxShadow: [
                                                  BoxShadow(
                                                      offset: Offset(0, 2),
                                                      blurRadius: 4,
                                                      color: Colors.black
                                                          .withOpacity(0.1))
                                                ]),
                                            child: Row(children: [
                                              SizedBox(
                                                width: 70.w,
                                                child: Image.asset(MyImgs.logo),
                                              ),
                                              SizedBox(
                                                width: 10.w,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      plan.title,
                                                      style: textTheme
                                                          .headlineSmall!
                                                          .copyWith(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      plan.shortDescription,
                                                      style: textTheme
                                                          .bodySmall!
                                                          .copyWith(),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      "Duration: ${plan.duration}",
                                                      style: textTheme
                                                          .bodySmall!
                                                          .copyWith(),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      "PKR ${plan.price}",
                                                      style: textTheme
                                                          .bodyLarge!
                                                          .copyWith(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ]),
                                          ),
                                        ),
                                      );
                                    },
                                    separatorBuilder:
                                        (BuildContext context, int index) {
                                      return SizedBox(
                                        width: 10.w,
                                      );
                                    },
                                  )

                              )
                            : SizedBox(
                                height: 170.h,
                                child: ListView.separated(
                                  padding: EdgeInsets.symmetric(vertical: 20.h),
                                  itemCount:
                                      homeController.allPlanModel!.plans.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    var plan = homeController
                                        .allPlanModel!.plans[index];
                                    return GestureDetector(
                                      onTap: () {
                                        homeController.selectedPlanId.value =
                                            plan.id;
                                        homeController.selectedPlanIndex.value =
                                            index;
                                      },
                                      child: Obx(
                                        () => Container(
                                          width: 300.w,
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                  color: homeController
                                                              .selectedPlanId
                                                              .value ==
                                                          plan.id
                                                      ? MyColors.buttonColor
                                                      : Colors.white),
                                              boxShadow: [
                                                BoxShadow(
                                                    offset: Offset(0, 2),
                                                    blurRadius: 4,
                                                    color: Colors.black
                                                        .withOpacity(0.1))
                                              ]),
                                          child: Row(children: [
                                            SizedBox(
                                              width: 70.w,
                                              child: Image.asset(MyImgs.logo),
                                            ),
                                            SizedBox(
                                              width: 10.w,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    plan.title,
                                                    style: textTheme
                                                        .headlineSmall!
                                                        .copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis ,
                                                  ),
                                                  Text(
                                                    plan.shortDescription,
                                                    style: textTheme.bodySmall!
                                                        .copyWith(),
                                                    maxLines: 3,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    "Duration: ${plan.duration}",
                                                    style: textTheme.bodySmall!
                                                        .copyWith(),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    "PKR ${plan.price}",
                                                    style: textTheme.bodyLarge!
                                                        .copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ]),
                                        ),
                                      ),
                                    );
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return SizedBox(
                                      width: 10.w,
                                    );
                                  },
                                ),
                              ),
                        SizedBox(
                          height: 10.h,
                        ),
                        isMember
                            ? SizedBox()
                            : Text(
                                "Select ${homeController.allPlanModel!.plans[homeController.selectedPlanIndex.value].categoryId == 1 || homeController.allPlanModel!.plans[homeController.selectedPlanIndex.value].categoryId == 3 ? "Dietitian" : "Trainers"}",
                                style: textTheme.headlineMedium!
                                    .copyWith(fontWeight: FontWeight.w600),
                              ),
                        isMember
                            ? SizedBox()
                            : Obx(() => homeController.getDietitianLoad.value
                                ? Obx(() {
                                    if (homeController
                                            .allPlanModel!
                                            .plans[homeController
                                                .selectedPlanIndex.value]
                                            .categoryId ==
                                        3) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ListView.separated(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 20.h),
                                            itemCount: homeController
                                                .getAllDietitianAndTrainers!
                                                .dietitions
                                                .length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              var diet = homeController
                                                  .getAllDietitianAndTrainers!
                                                  .dietitions[index];

                                              return GestureDetector(
                                                onTap: () {
                                                  homeController.selectedDietId
                                                      .value = diet.id;
                                                },
                                                child: Obx(
                                                  () => Container(
                                                    width: 300.w,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                        border: Border.all(
                                                            color: homeController
                                                                        .selectedDietId
                                                                        .value ==
                                                                    diet.id
                                                                ? MyColors
                                                                    .buttonColor
                                                                : Colors.white),
                                                        boxShadow: [
                                                          BoxShadow(
                                                              offset:
                                                                  const Offset(
                                                                      0, 2),
                                                              blurRadius: 4,
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.1))
                                                        ]),
                                                    child: Row(children: [
                                                      SizedBox(
                                                        width: 70.w,
                                                        child: Image.asset(
                                                            MyImgs.logo),
                                                      ),
                                                      SizedBox(
                                                        width: 10.w,
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "${diet.firstName} ${diet.lastName}",
                                                              style: textTheme
                                                                  .headlineSmall!
                                                                  .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                            Text(
                                                              diet.email,
                                                              style: textTheme
                                                                  .bodySmall!
                                                                  .copyWith(),
                                                              maxLines: 3,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ]),
                                                  ),
                                                ),
                                              );
                                            },
                                            separatorBuilder:
                                                (BuildContext context,
                                                    int index) {
                                              return SizedBox(
                                                height: 10.h,
                                              );
                                            },
                                          ),
                                          Text(
                                            "Select Trainers",
                                            style: textTheme.headlineMedium!
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.w600),
                                          ),
                                          ListView.separated(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 20.h),
                                            itemCount: homeController
                                                .getAllDietitianAndTrainers!
                                                .trainers
                                                .length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              var diet = homeController
                                                  .getAllDietitianAndTrainers!
                                                  .trainers[index];

                                              return GestureDetector(
                                                onTap: () {
                                                  homeController
                                                      .selectedTrainerId
                                                      .value = diet.id;
                                                },
                                                child: Obx(
                                                  () => Container(
                                                    width: 300.w,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                        border: Border.all(
                                                            color: homeController
                                                                        .selectedTrainerId
                                                                        .value ==
                                                                    diet.id
                                                                ? MyColors
                                                                    .buttonColor
                                                                : Colors.white),
                                                        boxShadow: [
                                                          BoxShadow(
                                                              offset:
                                                                  const Offset(
                                                                      0, 2),
                                                              blurRadius: 4,
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.1))
                                                        ]),
                                                    child: Row(children: [
                                                      SizedBox(
                                                        width: 70.w,
                                                        child: Image.asset(
                                                            MyImgs.logo),
                                                      ),
                                                      SizedBox(
                                                        width: 10.w,
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "${diet.firstName} ${diet.lastName}",
                                                              style: textTheme
                                                                  .headlineSmall!
                                                                  .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                            Text(
                                                              diet.email,
                                                              style: textTheme
                                                                  .bodySmall!
                                                                  .copyWith(),
                                                              maxLines: 3,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ]),
                                                  ),
                                                ),
                                              );
                                            },
                                            separatorBuilder:
                                                (BuildContext context,
                                                    int index) {
                                              return SizedBox(
                                                height: 10.h,
                                              );
                                            },
                                          )
                                        ],
                                      );
                                    } else {
                                      return ListView.separated(
                                        shrinkWrap: true,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 20.h),
                                        itemCount: homeController
                                                    .allPlanModel!
                                                    .plans[homeController
                                                        .selectedPlanIndex
                                                        .value]
                                                    .categoryId ==
                                                1
                                            ? homeController
                                                .getAllDietitianAndTrainers!
                                                .dietitions
                                                .length
                                            : homeController
                                                .getAllDietitianAndTrainers!
                                                .trainers
                                                .length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          var diet = homeController
                                                      .allPlanModel!
                                                      .plans[homeController
                                                          .selectedPlanIndex
                                                          .value]
                                                      .categoryId ==
                                                  1
                                              ? homeController
                                                  .getAllDietitianAndTrainers!
                                                  .dietitions[index]
                                              : homeController
                                                  .getAllDietitianAndTrainers!
                                                  .trainers[index];

                                          return GestureDetector(
                                            onTap: () {
                                              if (homeController
                                                      .allPlanModel!
                                                      .plans[homeController
                                                          .selectedPlanIndex
                                                          .value]
                                                      .categoryId ==
                                                  1) {
                                                homeController.selectedDietId
                                                    .value = diet.id;
                                              } else {
                                                homeController.selectedTrainerId
                                                    .value = diet.id;
                                              }
                                            },
                                            child: Obx(
                                              () => Container(
                                                width: 300.w,
                                                padding:
                                                    const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    border: Border.all(
                                                        color: (homeController
                                                                            .allPlanModel!
                                                                            .plans[homeController
                                                                                .selectedPlanIndex.value]
                                                                            .categoryId ==
                                                                        1
                                                                    ? homeController
                                                                        .selectedDietId
                                                                        .value
                                                                    : homeController
                                                                        .selectedTrainerId) ==
                                                                diet.id
                                                            ? MyColors
                                                                .buttonColor
                                                            : Colors.white),
                                                    boxShadow: [
                                                      BoxShadow(
                                                          offset: const Offset(
                                                              0, 2),
                                                          blurRadius: 4,
                                                          color: Colors.black
                                                              .withOpacity(0.1))
                                                    ]),
                                                child: Row(children: [
                                                  SizedBox(
                                                    width: 70.w,
                                                    child: Image.asset(
                                                        MyImgs.logo),
                                                  ),
                                                  SizedBox(
                                                    width: 10.w,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "${diet.firstName} ${diet.lastName}",
                                                          style: textTheme
                                                              .headlineSmall!
                                                              .copyWith(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        Text(
                                                          diet.email,
                                                          style: textTheme
                                                              .bodySmall!
                                                              .copyWith(),
                                                          maxLines: 3,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ]),
                                              ),
                                            ),
                                          );
                                        },
                                        separatorBuilder:
                                            (BuildContext context, int index) {
                                          return SizedBox(
                                            height: 10.h,
                                          );
                                        },
                                      );
                                    }
                                  })
                                : const CircularProgress())
                      ],
                    )
                  : const CircularProgress())
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomButton(
                text: "Add",
                onPressed: () async {
                  if (isMember) {
                    if (homeController.firstNameController.text.isEmpty ||
                        homeController.lastNameController.text.isEmpty ||
                        homeController.emailController.text.isEmpty ||
                        homeController.phoneController.text.isEmpty ||
                        homeController.phoneController.text.isEmpty) {
                      CustomToast.failToast(
                          msg: "Please provide all information");
                    } else if (!homeController.emailController.text.isEmail) {
                      CustomToast.failToast(msg: "Please provide valid email");
                    } else {
                      int id = homeController.addedTeamMember.value == "Trainer"
                          ? homeController.selectedTrainerIdForMember.value
                          : homeController.selectedDietIdForMember.value;
                      homeController.addTeamMemberFunc(id);
                    }
                  } else {
                    if (homeController.firstNameController.text.isEmpty ||
                        homeController.lastNameController.text.isEmpty ||
                        homeController.emailController.text.isEmpty ||
                        homeController.phoneController.text.isEmpty ||
                        homeController.phoneController.text.isEmpty ||
                        homeController.selectedPlanId.value == 0 ||
                        (homeController.selectedTrainerId.value == 0 &&
                            homeController.selectedPlanIndex.value == 0)) {
                      CustomToast.failToast(
                          msg: "Please provide all information");
                    } else if (!homeController.emailController.text.isEmail) {
                      CustomToast.failToast(msg: "Please provide valid email");
                    } else {
                      homeController.addUser();
                    }
                  }
                }),
          ],
        ),
      ),
    );
  }
}
