import 'package:flutter/cupertino.dart';

// ignore: must_be_immutable
class CustomText extends StatelessWidget {
  CustomText({Key? key, this.Title, this.TitleFontSize, this.TitleColor})
      : super(key: key);

  String? Title;
  double? TitleFontSize;
  Color? TitleColor;
  @override
  Widget build(BuildContext context) {
    return Title == null
        ? SizedBox()
        : Text(
            Title!,
            style: TextStyle(fontSize: TitleFontSize, color: TitleColor),
            maxLines: 3,
          );
  }
}
