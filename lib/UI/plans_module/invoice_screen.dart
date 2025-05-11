import 'package:fitness_zone_2/data/controllers/auth_controller/auth_controller.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class InvoiceScreen extends StatelessWidget {
  HomeController homeController = Get.find();
  AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Invoice"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Plan Name",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                '${homeController.userHomeData?.userAllPlans[0].title}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InvoiceDetail(
                    label: 'Billed to:',
                    value:
                        "${authController.logInUser?.firstName} ${authController.logInUser?.lastName}"),
                InvoiceDetail(label: 'Billed by:', value: '${homeController.userHomeData!.customSupporter?.firstName} ${homeController.userHomeData!.customSupporter?.lastName}'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InvoiceDetail(
                    label: 'Issued at:',
                    value: homeController
                                .userHomeData?.userAllPlans[0].buyingDate ==
                            null
                        ? "N/A"
                        : DateFormat('MMMM d, yyyy').format(homeController
                            .userHomeData!.userAllPlans[0].buyingDate!)),
                InvoiceDetail(
                    label: 'Valid till:',
                    value: homeController
                                .userHomeData?.userAllPlans[0].expireDate ==
                            null
                        ? "N/A"
                        : DateFormat('MMMM d, yyyy').format(homeController
                            .userHomeData!.userAllPlans[0].expireDate!)),
              ],
            ),
            const Divider(height: 40, thickness: 1, color: Colors.grey),
             InvoiceAmountDetail(label: 'Paid Amount', value: '${homeController.userHomeData!.userAllPlans[0].currency} ${homeController.userHomeData!.userAllPlans[0].price}'),
             // InvoiceAmountDetail(label: 'Sub Total', value: 'Rs. ${homeController.userHomeData!.userAllPlans[0].priceData!.priceAmount}'),
             InvoiceAmountDetail(label: 'Tax', value: '${homeController.userHomeData!.userAllPlans[0].currency} 00'),
             InvoiceAmountDetail(
              label: 'Total',
              value: '${homeController.userHomeData!.userAllPlans[0].currency} ${homeController.userHomeData!.userAllPlans[0].price}',
              isBold: true,
            ),
            const SizedBox(height: 24),
            // Center(
            //   child: InkWell(
            //     onTap: () {
            //       // Handle Terms & Agreement
            //     },
            //     child: const Text(
            //       'Terms & Agreement',
            //       style: TextStyle(
            //         decoration: TextDecoration.underline,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 24),
            // Center(
            //   child: ElevatedButton(
            //     onPressed: () {
            //       // Handle download action
            //     },
            //     style: ElevatedButton.styleFrom(
            //       padding: const EdgeInsets.symmetric(
            //         horizontal: 40,
            //         vertical: 12,
            //       ),
            //       backgroundColor: Colors.green.shade400,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(8),
            //       ),
            //     ),
            //     child: const Text(
            //       'Download',
            //       style: TextStyle(fontSize: 16),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class InvoiceDetail extends StatelessWidget {
  final String label;
  final String value;

  const InvoiceDetail({required this.label, required this.value, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class InvoiceAmountDetail extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const InvoiceAmountDetail({
    required this.label,
    required this.value,
    this.isBold = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
