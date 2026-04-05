import 'package:flutter/material.dart';

import '../../widgets/app_bar_widget.dart';
import 'package:get/get.dart';

class RefundPolicyScreen extends StatelessWidget {
  const RefundPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HelpingWidgets()
          .appBarWidget(() => Get.back(), text: "Refund Policy"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Applicable to App users & Similar Clients",
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              "Applicable from January 2025",
              style: TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(
                "1. Partial Refund Policy (Up to 50% Deduction)"),
            _buildSectionDescription(
              "If a client requests a refund without availing our services, due to personal or non-service-related reasons, a deduction will be applied based on the type of package purchased:",
            ),
            const SizedBox(height: 8),
            _buildSectionDescription(
              "• Regular Pricing (One-month or Two-month Subscription): Up to 30% deduction.",
            ),
            _buildSectionDescription(
              "• Discounted or Deal-Based Packages: A flat 50% deduction will be applied.",
            ),
            const SizedBox(height: 8),
            _buildSectionDescription(
              "This deduction accounts for administrative, onboarding, and resource allocation costs, which are incurred immediately upon registration—even if the services remain unused..",
            ),
            _buildSectionDescription(
              "Note: This applies only if services have not yet been availed.",
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                  fontSize: 10),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(
                "2. Full Refund Policy (100%) – Quality-Related"),
            _buildSectionDescription(
              "Clients who have availed services but are not satisfied with the quality may request a 100% refund within 24 hours of availing the service.",
            ),
            _buildSectionDescription(
              "Terms & conditions apply: Clear feedback must be provided, and our quality assurance team will review the request before approval.",
            ),
            const SizedBox(height: 16),
            _buildSectionTitle("3. Session Freeze Policy"),
            _buildSectionDescription(
              "Clients may request a pause/freeze on their sessions in case of medical issues or unknown causes (e.g., during menstrual cycles). The freeze request must be informed in advance or within 24 hours of the scheduled session.",
            ),
            const SizedBox(height: 16),
            _buildSectionTitle("4. Package Transfer Policy"),
            _buildSectionDescription(
              "Clients may transfer their active package to another individual, provided that more than 20 days remain in the current plan. Transfer requests must be made via email or official support channels.",
            ),
            const SizedBox(height: 16),
            _buildSectionTitle("5. Refund Processing Timeline & Procedure"),
            _buildSectionDescription("To request a refund:"),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.email_outlined, size: 20),
                SizedBox(width: 8),
                Text("support@thefither.com",
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 10,)),
              ],
            ),
            const SizedBox(height: 8),
            _buildSectionDescription(
              "Or inform your consultant, who will forward your cancellation request.",
            ),
            const SizedBox(height: 8),
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Processing Time: ",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
                  ),
                  TextSpan(
                    text:
                        "Refunds will be processed within 7 to 10 working days after the request has been acknowledged.",
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildSectionDescription(
              "Note: Once a refund has been initiated and processed, it cannot be reversed under any circumstances.",
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                  fontSize: 10),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
    );
  }

  Widget _buildSectionDescription(String title, {TextStyle? style}) {
    return Text(
      title,
      style: style ?? TextStyle(fontWeight: FontWeight.w400, fontSize: 10),
    );
  }
}
