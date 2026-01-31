import 'dart:async';
import 'dart:io';

import 'package:fitness_zone_2/data/controllers/diet_contoller/diet_controller.dart';
import 'package:fitness_zone_2/values/my_imgs.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/custom_button.dart';
import 'package:fitness_zone_2/widgets/custom_textfield.dart';
import 'package:fitness_zone_2/widgets/toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../data/controllers/auth_controller/auth_controller.dart';
import '../../data/models/food_suggestion_model.dart';
import '../../helper/permissions.dart';
import '../../values/my_colors.dart';
import 'calerie_info.dart';

class TrackCalories extends StatefulWidget {
  const TrackCalories({super.key});

  @override
  State<TrackCalories> createState() => _TrackCaloriesState();
}

class _TrackCaloriesState extends State<TrackCalories> {
  DietController dietController = Get.find();
  TextEditingController foodName = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    foodName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Track Calories"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              "You can use this tracker only 3 times a day.",
              style: textTheme.bodySmall?.copyWith(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    text: "Food Name",
                    length: 200,
                    keyboardType: TextInputType.text,
                    inputFormatters: FilteringTextInputFormatter.singleLineFormatter,
                    controller: foodName,
                    onChanged: (value) {
                      _debounceTimer?.cancel();
                      if (value.length >= 2) {
                        _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                          dietController.getFoodSuggestions(value);
                        });
                      }
                      else{
                        dietController.foodSuggestionLoad.value=false;
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  // Food Suggestions
                  Obx(() {
                    if (dietController.foodSuggestionLoad.value && dietController.foodSuggestionResponse != null && foodName.text.isNotEmpty) {
                      return Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            // Common foods
                            if (dietController.foodSuggestionResponse!.items != null && dietController.foodSuggestionResponse!.items!.isNotEmpty)
                              ...dietController.foodSuggestionResponse!.items!.map((food) => _buildFoodSuggestionItem(food, true)).toList(),
                            // Branded foods
                            // if (dietController.foodSuggestionResponse!.items != null && dietController.foodSuggestionResponse!.branded!.isNotEmpty)
                            //   ...dietController.foodSuggestionResponse!.branded!.map((food) => _buildFoodSuggestionItem(food, false)).toList(),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
            const SizedBox(height: 50,),
            SizedBox(
              width: 200,
              height: 250,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GetBuilder<DietController>(
                      id: "colorieUpdate",
                      builder: (cont) {
                        return GestureDetector(
                            onTap: () {
                              selectMediaBottomSheet(_getFromGallery, _getFromCamera, context);
                            },
                            child: dietController.calorieFile == null
                                ? SvgPicture.asset(MyImgs.captureCalorie)
                                : Image.file(
                                    File(dietController.calorieFile!.path),
                                    width: 200,
                                    height: 200,
                                  ));
                      }),
                  const SizedBox(
                    height: 14,
                  ),
                  Text(
                    "Note: You can use this tracker only 3 times a day.",
                    style: textTheme.titleLarge?.copyWith(color: Colors.grey, fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: CustomButton(
            text: "Check",
            onPressed: () {
              if (foodName.text.isEmpty || dietController.calorieFile == null) {
                CustomToast.failToast(msg: "Please provide image and food name");
                return;
              }
              dietController.addCaloriesImage(foodName.text);
            }),
      ),
    );
  }

  selectMediaBottomSheet(Function gallery, Function camera, BuildContext context) {
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
  _getFromCamera(
    BuildContext context,
  ) async {
    PermissionOfPhotos().getFromCamera(context).then((value) async {
      if (value) {
        final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
        if (pickedFile != null) {
          print("Picked File: ${pickedFile.path}");
          var imagePath = pickedFile.path;
          var imageName = imagePath.split("/").last;
          print("Image Name: $imageName");
          final dir1 = Directory.systemTemp;
          final targetPath1 = "${dir1.absolute.path}/dp${Get.find<AuthController>().i}.jpg";
          var compressedFile1 = await FlutterImageCompress.compressAndGetFile(imagePath, targetPath1, quality: 60);

          dietController.calorieFile = XFile(compressedFile1!.path);
          dietController.update(["colorieUpdate"]);
          Get.find<AuthController>().i++;
        }
      } else {
        print(value);
      }
    });
  }

  _getFromGallery(BuildContext context) async {
    PermissionOfPhotos().getFromGallery(context).then((value) async {
      if (value) {
        final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          var imagePath = pickedFile.path;
          var imageName = imagePath.split("/").last;
          print("Image Name: $imageName");
          final dir1 = Directory.systemTemp;
          final targetPath1 = "${dir1.absolute.path}/dp${Get.find<AuthController>().i}.jpg";
          var compressedFile1 = await FlutterImageCompress.compressAndGetFile(imagePath, targetPath1, quality: 60);
          dietController.calorieFile = XFile(compressedFile1!.path);
          dietController.update(["colorieUpdate"]);

          Get.find<AuthController>().i++;
        }
      } else {
        print(value);
      }
    });
  }

  Widget _buildFoodSuggestionItem(dynamic food, bool isCommon) {
    String foodName = '';
    String? photoUrl;

    FoodItem commonFood = food as FoodItem;
      foodName = commonFood.name ?? '';
      photoUrl =   "https://spoonacular.com/cdn/ingredients_100x100/${commonFood.image}";



    return ListTile(
      leading: CircleAvatar(
        backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
        child: photoUrl == null ? const Icon(Icons.fastfood) : null,
      ),
      title: Text(
        foodName,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),

      onTap: () {
        this.foodName.text = foodName;
        dietController.foodSuggestionLoad.value = false;
        dietController.foodSuggestionResponse = null;
      },
    );
  }
}
