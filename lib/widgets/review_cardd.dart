import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

import '../values/my_imgs.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.isLast});
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Stack(
      children: [
        Container(
          width: 300.w,
          margin:
              EdgeInsets.only(left: 20.w, right: isLast ? 20.w : 0, top: 20.h),
          padding:
              EdgeInsets.only(left: 15.w, right: 15.w, top: 35.h, bottom: 11.h),
          decoration: BoxDecoration(
            color: MyColors.planColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 2,
                  spreadRadius: 0,
                  offset: const Offset(0, 1)),
              BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 3,
                  spreadRadius: 1,
                  offset: const Offset(0, 1)),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: Text(
                  "Working with Fit Her has been a transformative experience. Their innovative health and wellness app, designed with user-centric features like workout schedules and diet consultations, truly stands out. The team's attention to detail and commitment to improving user experience is evident in every aspect of the app.",
                  style: textTheme.titleSmall!
                      .copyWith(fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 36.w,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const CircleAvatar(
                radius: 20,

                backgroundImage: AssetImage(
                  MyImgs.userProfileIcon,
                ), // Replace with your image asset
              ),
              SizedBox(
                width: 5.w,
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < 4
                          ? Icons.star
                          : Icons
                              .star_border, // 4 filled stars and 1 empty star
                      color: Colors.amber,
                      size: 14,
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
