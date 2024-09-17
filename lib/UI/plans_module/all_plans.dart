import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:fitness_zone_2/values/my_imgs.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/circular_progress.dart';
import 'package:fitness_zone_2/widgets/meal_details.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

class OurPlansScreen extends StatelessWidget {
  OurPlansScreen({super.key});
  HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Our Plans"),
      body: Obx(
        () => homeController.getPlanLoaded.value
            ? GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 items per row
                  mainAxisSpacing: 48.h,
                  crossAxisSpacing: 16.w,
                  childAspectRatio:
                      0.7, // Adjust the aspect ratio to your needs
                ),
                itemCount: homeController
                    .allPlanModel?.plans.length, // Number of items in the grid
                itemBuilder: (context, index) {
                  var plan = homeController.allPlanModel?.plans[index];

                  return GestureDetector(
                    onTap: () {
                      Get.to(() => DietDetails(
                            isPlan: true,
                            title: plan!.title,
                            description: plan.shortDescription,
                            longDescription: plan.longDescription,
                            price: plan.price.toString(),
                            duration: plan.duration,
                            planCategory: plan.categoryId,
                            planId: plan.id.toString(),
                          ));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              offset: const Offset(0, 4),
                              blurRadius: 4,
                              spreadRadius: 0,
                              color: Colors.black.withOpacity(0.25))
                        ],
                      ),
                      child: LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: constraints.maxHeight / 2,
                                decoration: const BoxDecoration(
                                    color: MyColors.primaryGradient1,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(25),
                                        topRight: Radius.circular(25)),
                                    image: DecorationImage(
                                        image: AssetImage(MyImgs.logo))),
                              ),
                              SizedBox(
                                height: 8.h,
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.only(left: 14.w, right: 20.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      plan!.title,
                                      style: textTheme.titleLarge!.copyWith(
                                          fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(
                                      height: 3.h,
                                    ),
                                    Text(
                                      plan.shortDescription,
                                      style: textTheme.titleMedium!.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black.withOpacity(0.35),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                    // Row(
                                    //   children: List.generate(5, (index) {
                                    //     return Icon(
                                    //       index < 4
                                    //           ? Icons.star
                                    //           : Icons
                                    //               .star_border, // 4 filled stars and 1 empty star
                                    //       color: Colors.amber,
                                    //       size: 14,
                                    //     );
                                    //   }),
                                    // ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    const Align(
                                        alignment: Alignment.centerRight,
                                        child: Icon(
                                          Icons.arrow_forward_ios_sharp,
                                          size: 15,
                                        ))
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                },
              )
            : const Center(
                child: CircularProgress(),
              ),
      ),
    );
  }
}
