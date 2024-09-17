import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ViewDetails extends StatelessWidget {
  const ViewDetails({super.key});

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Fit Fusion Workout Plan"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 20,),
            Container(
              padding: const EdgeInsets.only(top: 15,bottom: 15,left: 30,right: 30),
              decoration: BoxDecoration(
                color: MyColors.planColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0,2),
                    spreadRadius: 0,
                    blurRadius: 2,
                    color: Colors.black.withOpacity(0.3)
                  )
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Services",
                    style: textTheme.bodyMedium!
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 5,),
                  rowWidget("Live Workout Session", textTheme),
                  rowWidget("Customized Diet Plan", textTheme),
                  rowWidget("Flexible Time Slots", textTheme),
                  rowWidget("Weekly Follow Up", textTheme),
                  rowWidget("Complete Privacy", textTheme),
                ],
              ),
            ),
            SizedBox(height: 20,),
            Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.green, // Header background color
                  onPrimary: Colors.white, // Header text color
                  onSurface: Colors.black, // Body text color
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green, // Button text color
                  ),
                ),
              ),
              child: CalendarDatePicker(
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2090),
                  selectableDayPredicate: (DateTime value) {
                    return true;
                  },
                  onDateChanged: (DateTime date) {}),
            ),
          ],
        ),
      ),
    );
  }

  rowWidget(String text, TextTheme textTheme) {
    return Row(
      children: [
        Icon(
          Icons.done,
          color: MyColors.primaryGradient1,
        ),
        SizedBox(width: 10,),
        Text(
          text,
          style: textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w400),
        ),

      ],
    );
  }
}
