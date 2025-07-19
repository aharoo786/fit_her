import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import '../../data/controllers/auth_controller/auth_controller.dart';
import '../../data/controllers/home_controller/home_controller.dart';

Future<String> generatePDF() async {
  final HomeController homeController = Get.find();
  final AuthController authController = Get.find();
  final plan = homeController.userHomeData?.userAllPlans[0];
  final user = authController.logInUser;
  final supporter = homeController.userHomeData?.customSupporter;

  final pdf = pw.Document();

  const PdfPageFormat pageFormat = PdfPageFormat.a4;

  pdf.addPage(
    pw.MultiPage(
      pageFormat: pageFormat,
      build: (context) => [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('INVOICE',
                style: pw.TextStyle(
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                )),
            pw.SizedBox(height: 20),

            // Plan Name
            pw.Text('Plan Name',
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Text(plan?.title ?? "N/A",
                style: pw.TextStyle(fontSize: 14, color: PdfColors.green)),
            pw.SizedBox(height: 30),

            // Billed Info
            _infoRow(
                "Billed to:",
                "${user?.firstName ?? ""} ${user?.lastName ?? ""}",
                "Billed by:",
                "${supporter?.firstName ?? ""} ${supporter?.lastName ?? ""}"),
            pw.SizedBox(height: 20),

            // Dates
            _infoRow(
              "Issued at:",
              plan?.buyingDate == null
                  ? "N/A"
                  : DateFormat('MMMM d, yyyy').format(plan!.buyingDate!),
              "Valid till:",
              plan?.expireDate == null
                  ? "N/A"
                  : DateFormat('MMMM d, yyyy').format(plan!.expireDate!),
            ),
            pw.SizedBox(height: 30),

            // Price breakdown
            _priceRow("Paid Amount", 'Rs. ${plan?.price ?? "0"}'),
            _priceRow("Sub Total", 'Rs. ${plan?.price ?? "0"}'),
            _priceRow("Tax", "Rs. 00"),
            _priceRow("Total", 'Rs. ${plan?.price ?? "0"}'),

            pw.SizedBox(height: 40),

            // Footer Terms
            pw.Center(
              child: pw.Text("Terms & Agreement",
                  style: pw.TextStyle(decoration: pw.TextDecoration.underline)),
            ),
            pw.SizedBox(height: 20),
            pw.Center(child: pw.Text("Prepared by: FitHer")),
          ],
        )
      ],
    ),
  );

  // Output path
  String outputDirectory;
  if (Platform.isIOS) {
    final appDocDir = await getApplicationDocumentsDirectory();
    outputDirectory = appDocDir.path;
  } else {
    final externalDir = await getExternalStorageDirectory();
    outputDirectory = externalDir!.path;
  }

  final baseFileName = "invoice_${plan?.planId ?? 'unknown'}.pdf";
  String fileName = baseFileName;
  int suffix = 1;
  while (await File("$outputDirectory/$fileName").exists()) {
    fileName = "${baseFileName.replaceAll('.pdf', '')}($suffix).pdf";
    suffix++;
  }

  final file = File("$outputDirectory/$fileName");
  await file.writeAsBytes(await pdf.save());
  return file.path;
}

pw.Widget _infoRow(String label1, String value1, String label2, String value2) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      _infoColumn(label1, value1),
      _infoColumn(label2, value2),
    ],
  );
}

pw.Widget _infoColumn(String label, String value) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(label,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
      pw.SizedBox(height: 4),
      pw.Text(value,
          style: pw.TextStyle(color: PdfColors.grey700, fontSize: 12)),
    ],
  );
}

pw.Widget _priceRow(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 6),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
        pw.Text(value,
            style: pw.TextStyle(color: PdfColors.grey700, fontSize: 12)),
      ],
    ),
  );
}

Future<File?> saveLocalFileToDirectory(
    String filePath, String destinationDirectory) async {
  try {
    // Ensure the source file exists
    File sourceFile = File(filePath);
    if (!sourceFile.existsSync()) {
      print("Source file does not exist: $filePath");
      return null;
    }

    // Create the destination directory if it doesn't exist
    Directory destinationDir = Directory(destinationDirectory);
    if (!destinationDir.existsSync()) {
      destinationDir.createSync(recursive: true);
    }

    // Create the destination file path
    String destinationFilePath =
        "$destinationDirectory/${sourceFile.uri.pathSegments.last}";

    // Copy the source file to the destination
    sourceFile.copySync(destinationFilePath);

    print("File copied to: $destinationFilePath");

    return File(destinationFilePath);
  } catch (e) {
    print(e);
    return null;
  }
}
