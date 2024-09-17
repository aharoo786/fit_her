import 'package:fitness_zone_2/values/my_imgs.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/get_all_dietitian_trainers/get_diet_plan_details.dart';
import '../../values/my_colors.dart';

class DietPlanFoodDetails extends StatelessWidget {
  List<Diet> dietPlan = [];

  DietPlanFoodDetails({super.key, required this.dietPlan});

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Diet Plan"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Time', style: textTheme.titleLarge),
                  Text('Food Item', style: textTheme.titleLarge),
                  Text('Taken', style: textTheme.titleLarge),
                  Text('Calories', style: textTheme.titleLarge),
                ],
              ),
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: dietPlan.length,
              itemBuilder: (context, index) {
                var diet = dietPlan[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  child: LayoutBuilder(builder: (context, box) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: box.maxWidth * 0.16,
                              //color:Colors.amber,
                              child: Text(diet.time,
                                  style: textTheme.titleLarge!
                                      .copyWith(fontWeight: FontWeight.w400)),
                            ),
                            SizedBox(
                              width: box.maxWidth * 0.52,
                              //   color:Colors.amber,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CircleAvatar(
                                    radius: 10,
                                    backgroundImage: AssetImage(MyImgs.doctor2),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(diet.food.split("&").first.split("=").last,
                                        style: textTheme.titleLarge!.copyWith(
                                            fontWeight: FontWeight.w400)),
                                  ),
                                  const Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                            Container(
                              width: box.maxWidth * 0.1,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(4)),
                              child: Checkbox(
                                visualDensity: const VisualDensity(
                                    horizontal: -4, vertical: -4),
                                value: true,
                                hoverColor: Colors.white,
                                onChanged: (value) {},
                                side: BorderSide.none,
                                checkColor: MyColors.primaryGradient1,
                              ),
                            ),
                            SizedBox(
                              width: box.maxWidth * 0.16,
                              //  color:Colors.amber,

                              child: Text(diet.calories,
                                  style: textTheme.titleLarge!
                                      .copyWith(fontWeight: FontWeight.w400)),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Divider(
                          height: 1,
                          color: Colors.black.withOpacity(0.2),
                        )
                      ],
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
