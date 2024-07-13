import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/widgets/toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../widgets/app_bar_widget.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PasteLink extends StatelessWidget {
   PasteLink({super.key,required this.slotId,this.isDiet=false});
  final int slotId;
  final bool isDiet;
  final TextEditingController textEditingController =TextEditingController();

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar:  HelpingWidgets().appBarWidget((){
        Get.back();
      },text: "Paste Link"),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.h),
        children: [
          SizedBox(
            height: 40.h,
          ),
          CustomTextField(
              text: "Paste Link",
              length: 1000,
              keyboardType: TextInputType.text,
              controller:textEditingController,
              inputFormatters: FilteringTextInputFormatter.singleLineFormatter),
         SizedBox(height: 40.h,),
          CustomButton(text: "Update", onPressed: () {
            if(textEditingController.text.isEmpty){
              CustomToast.failToast(msg: "Please provide link");
            }
            else{
              Get.find<HomeController>().updateLinkFunc(textEditingController, slotId,isDiet,0);
            }

          }),
        ],
      ),
    );
  }
}
