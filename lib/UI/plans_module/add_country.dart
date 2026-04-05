import 'package:fitness_zone_2/data/controllers/plan_controller/plan_controller.dart';
import 'package:fitness_zone_2/values/my_colors.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';

class AddCountry extends StatelessWidget {
  AddCountry({super.key});
  PlanController planController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Add Country"),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
                onTap: () {
                  showCountryPicker(
                    context: context,
                    showPhoneCode:
                        true, // optional. Shows phone code before the country name.
                    onSelect: (Country country) {
                      planController.selectedCountry.value=country.name;
                      planController.selectedCountryCode.value=country.countryCode;
                    },
                  );
                },
                child: Obx(
                  ()=> Container(
                    height: 56,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: MyColors.textFieldColor,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(planController.selectedCountry.value),
                  ),
                ))
          ],
        ),
      ),
      bottomNavigationBar: HelpingWidgets().bottomBarButtonWidget(
        onTap: (){
          planController.addCountryFunc();
        }
      ),
    );
  }
}
