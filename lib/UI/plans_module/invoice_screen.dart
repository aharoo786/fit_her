import 'dart:io';

import 'package:fitness_zone_2/UI/plans_module/refund_policy.dart';
import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../widgets/toasts.dart';
import 'generate_pdf.dart';

class InvoiceScreen extends StatelessWidget {
  final HomeController homeController = Get.find();
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    final plan = homeController.userHomeData?.userAllPlans[0];
    final user = authController.logInUser;
    final supporter = homeController.userHomeData?.customSupporter;

    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() => Get.back(), text: "Invoice"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Plan Name',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Center(
              child: Text(
                plan?.title ?? "N/A",
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            _infoRowDouble(
              "Billed to:",
              "${user?.firstName ?? ""} ${user?.lastName ?? ""}",
              "Billed by:",
              "${supporter?.firstName ?? ""} ${supporter?.lastName ?? ""}",
            ),
            const SizedBox(height: 50),
            _infoRowDouble(
              "Issued at:",
              plan?.buyingDate == null
                  ? "N/A"
                  : DateFormat('MMMM d, yyyy').format(plan!.buyingDate!),
              "Valid till:",
              plan?.expireDate == null
                  ? "N/A"
                  : DateFormat('MMMM d, yy').format(plan!.expireDate!),
            ),
            const SizedBox(height: 40),
            _priceRow("Paid Amount", 'Rs. ${plan?.price ?? "0"}'),
            _priceRow("Sub Total", 'Rs. ${plan?.price ?? "0"}'),
            _priceRow("Tax", "Rs. 00"),
            _priceRow("Total", 'Rs. ${plan?.price ?? "0"}'),
            const Spacer(),
            GestureDetector(
              onTap: () {
                // Show terms or navigate
                Get.to(() => RefundPolicyScreen());
              },
              child: const Text(
                "Terms & Agreement",
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            CustomButton(
                text: "Download",
                onPressed: () async {
                  int i = 0;
                  String filePath = await generatePDF();
                  Get.log("thiis is path of pdf $filePath");
                  String destinationDirectory;

                  if (Platform.isIOS) {
                    // On iOS, use the applicationDocumentsDirectory
                    final appDocDir = await getApplicationDocumentsDirectory();
                    destinationDirectory = appDocDir.path;
                  } else {
                    // On Android, use a specific directory (e.g., the Download directory)
                    destinationDirectory = "/storage/emulated/0/Download";
                  }

                  File? savedFile = await saveLocalFileToDirectory(
                      filePath, destinationDirectory);
                  // i++;

                  if (savedFile != null) {
                    CustomToast.successToast(
                        msg: "Receipt downloaded successfully".tr);
                    OpenFilex.open(filePath);
                  } else {
                    CustomToast.successToast(
                        msg: "Failed to download receipt".tr);
                  }
                }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _infoRowDouble(
      String label1, String value1, String label2, String value2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _infoColumn(label1, value1),
        _infoColumn(label2, value2),
      ],
    );
  }

  Widget _infoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _priceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
