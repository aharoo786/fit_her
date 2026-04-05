import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../data/controllers/auth_controller/auth_controller.dart';
import '../../data/controllers/home_controller/home_controller.dart';
import '../../helper/permissions.dart';
import '../../values/my_colors.dart';
import '../../values/my_imgs.dart';
import '../../widgets/toasts.dart';

class SelectPaymentMode extends StatelessWidget {
  SelectPaymentMode(
      {super.key,
      required this.planId,
      required this.durationId,
      required this.price});
  HomeController homeController = Get.find();
  String planId;
  String price;
  int durationId;

  void _showDirectPayPhoneDialog(BuildContext context, TextTheme textTheme) {
    final initialPhone = HomeController.normalizeMsisdn(
            Get.find<AuthController>().logInUser?.phone) ??
        '';
    Get.dialog(
      AlertDialog(
        title: const Text("Confirm mobile number"),
        content: _DirectPayPhoneDialogContent(
          planId: planId,
          price: price,
          initialPhone: initialPhone,
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Scaffold(
        appBar: HelpingWidgets().appBarWidget(() {
          homeController.planPicture == null;
          Get.back();
        }, text: "Select Payment"),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Center(
                child: CustomButton(
                  text: "Pay with JazzCash / EasyPaisa (Direct Pay)",
                  onPressed: () => _showDirectPayPhoneDialog(context, textTheme),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(
                      child: Divider(height: 1.5, color: Colors.black54)),
                  const SizedBox(width: 10),
                  Text("Or", style: textTheme.titleSmall),
                  const SizedBox(width: 10),
                  const Expanded(
                      child: Divider(height: 1.5, color: Colors.black54)),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: GetBuilder<HomeController>(builder: (cont) {
                  return GestureDetector(
                    onTap: () {
                      selectMediaBottomSheet(
                          _getFromGallery, _getFromCamera, context);
                    },
                    child: homeController.planPicture != null
                        ? Container(
                            alignment: Alignment.center,
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                                // / borderRadius: BorderRadius.circular(13),
                                color: MyColors.bodyBackground,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.4),
                                    blurRadius: 2.0,
                                    spreadRadius: 0.0,
                                    offset: const Offset(0.0,
                                        2.0), // shadow direction: bottom right
                                  )
                                ],
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: FileImage(
                                    File(homeController.planPicture!.path),
                                  ),
                                )),
                          )
                        : SizedBox(
                            height: 100,
                            child: SvgPicture.asset(
                              MyImgs.upload,
                            ),
                          ),
                  );
                }),
              ),
              SizedBox(
                width: 190,
                child: Text(
                  "Click here to upload the slip",
                  style: textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Spacer(),
              CustomButton(
                  text: "Upload",
                  onPressed: () async {
                    if (homeController.planPicture == null) {
                      CustomToast.failToast(msg: "Please select image");
                    } else {
                      var success = await homeController.addPlanBuyImage(
                          planId, durationId, price);
                      if (success) {
                        HelpingWidgets.showCustomDialog(context, () {
                          Get.back();
                          Get.back();
                        },
                            "Successfully Uploaded!",
                            "Our team is reviewing your payment, and you will receive a confirmation shortly. Please wait for approval.",
                            MyImgs.logo,
                            buttonText: "OK");
                      }
                    }
                  }),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  selectMediaBottomSheet(
      Function gallery, Function camera, BuildContext context) {
    Get.bottomSheet(Container(
      height: 150,
      color: MyColors.bodyBackground,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.photo_camera,
                  size: 30,
                ),
                onPressed: () {
                  Get.back();
                  camera(context);
                },
              ),
              Text("From Camera".tr)
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.photo,
                  size: 30,
                ),
                onPressed: () {
                  Get.back();
                  gallery(context);
                },
              ),
              Text("From Gallery".tr)
            ],
          ),
        ],
      ),
    ));
  }

  /// Get from Camera
  _getFromCamera(BuildContext context) async {
    PermissionOfPhotos().getFromCamera(context).then((value) async {
      if (value) {
        final pickedFile =
            await ImagePicker().pickImage(source: ImageSource.camera);
        if (pickedFile != null) {
          print("Picked File: ${pickedFile.path}");
          var imagePath = pickedFile.path;
          // Get.find<AuthController>().image = File(imagePath);
          // Get.find<AuthController>().update();

          var imageName = imagePath.split("/").last;
          print("Image Name: $imageName");
          final dir1 = Directory.systemTemp;
          final targetPath1 =
              "${dir1.absolute.path}/dp${Get.find<AuthController>().i}.jpg";
          var compressedFile1 = await FlutterImageCompress.compressAndGetFile(
              imagePath, targetPath1,
              quality: 60);
          HomeController homeController = Get.find();

          homeController.planPicture = XFile(compressedFile1!.path);
          homeController.update();

          Get.find<AuthController>().i++;
          Get.find<AuthController>().update();
        }
      } else {
        print(value);
      }
    });
  }

  _getFromGallery(BuildContext context) async {
    PermissionOfPhotos().getFromGallery(context).then((value) async {
      if (value) {
        final pickedFile =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          print("Picked File: ${pickedFile.path}");
          var imagePath = pickedFile.path;
          // Get.find<AuthController>().image = File(imagePath);
          // Get.find<AuthController>().update();

          var imageName = imagePath.split("/").last;
          print("Image Name: $imageName");
          final dir1 = Directory.systemTemp;
          final targetPath1 =
              "${dir1.absolute.path}/dp${Get.find<AuthController>().i}.jpg";
          var compressedFile1 = await FlutterImageCompress.compressAndGetFile(
              imagePath, targetPath1,
              quality: 60);
          HomeController homeController = Get.find();
          homeController.planPicture = XFile(compressedFile1!.path);
          homeController.update();

          Get.find<AuthController>().i++;
          Get.find<AuthController>().update();
        }
      } else {
        print(value);
      }
    });
  }
}

/// Dialog content for Direct Pay: user confirms/edits phone before opening WebView.
class _DirectPayPhoneDialogContent extends StatefulWidget {
  final String planId;
  final String price;
  final String initialPhone;

  const _DirectPayPhoneDialogContent({
    required this.planId,
    required this.price,
    required this.initialPhone,
  });

  @override
  State<_DirectPayPhoneDialogContent> createState() =>
      _DirectPayPhoneDialogContentState();
}

class _DirectPayPhoneDialogContentState
    extends State<_DirectPayPhoneDialogContent> {
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final raw = _phoneController.text.trim();
    final normalized = HomeController.normalizeMsisdn(raw);
    if (normalized == null || !HomeController.isValidMsisdn(normalized)) {
      CustomToast.failToast(
        msg:
            "Please enter a valid Pakistan mobile number (03xxxxxxxxx, 11 digits).",
      );
      return;
    }
    Get.back();
    Get.find<HomeController>().getDirectPayPaymentLink(
      widget.price,
      widget.planId,
      msisdn: normalized,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Enter your JazzCash / EasyPaisa mobile number. We'll use it for payment.",
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 11,
            decoration: const InputDecoration(
              hintText: "03xxxxxxxxx",
              labelText: "Mobile number",
              border: OutlineInputBorder(),
              counterText: "",
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: "Continue to payment",
            onPressed: _onSubmit,
          ),
        ],
      ),
    );
  }
}
