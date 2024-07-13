import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class PermissionOfPhotos {
  Future<bool> getFromGallery(BuildContext context) async {
    Permission platform;
    if (Platform.isIOS) {
      platform = Permission.photos;
    } else {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt < 33) {
        platform = Permission.storage;
      } else {
        platform = Permission.photos;
      }
    }

    var stauts = await platform.status;
    await platform.request();
    Get.log("status  $stauts ");
    if (await platform.status.isDenied) {
      // Permission.systemAlertWindow.isPermanentlyDenied;
      if (Platform.isIOS) {
        await platform.request();
      } else {
        showDeleteDialog(context,
            "FarmSharing app requires access to the gallery to upload pictures");
        // await platform.request();
        //   if (await platform.status.isPermanentlyDenied) {
        //     if (Platform.isIOS) {
        //       showDialog(
        //           context: context,
        //           builder: (BuildContext context) => CupertinoAlertDialog(
        //                 title: Text("Settings "),
        //                 content: Text(
        //                     "Farm sharing want to access camera open settings and give permission"),
        //                 actions: <Widget>[
        //                   CupertinoDialogAction(
        //                     isDefaultAction: true,
        //                     child: Text("No"),
        //                     onPressed: () => Navigator.pop(context),
        //                   ),
        //                   CupertinoDialogAction(
        //                     onPressed: () => openAppSettings(),
        //                     child: Text("open settings"),
        //                   )
        //                 ],
        //               ));
        //     } else {
        //       showDeleteDialog(context);
        //     }
        //     // showDialog(
        //     //     context: context,
        //     //     builder: (context) {
        //     //       return Center(
        //     //
        //     //         child: Container(
        //     //           color: Colors.white,
        //     //           height: 300,
        //     //           width: 400,
        //     //           child: Column(
        //     //             mainAxisSize: MainAxisSize.min,
        //     //             children: [
        //     //               TextButton(onPressed: (){}, child: Text("nfjk"))
        //     //             ],
        //     //           ),
        //     //
        //     //         ),
        //     //       );
        //     //     });
        //
        //     // openAppSettings();
        //     print("is permanant");
        //     //  if (await Permission.camera.request().isDenied) {
        //     //   print("is denied");
        //     //   openAppSettings();
        //     //
        //
        //     //   // We didn't ask for permission yet or the permission has been denied before but not permanently.
        //     // }
        //
        //   } else if (await platform.isGranted) {
        //     print("is grandted");
        //     var picked = ImagePicker().pickImage(source: ImageSource.gallery);
        //     Get.log("ggranted");
        //     // Either the permission was already granted before or the user just granted it.
        //   } else if (await platform.isLimited) {
        //     var picked = ImagePicker().pickImage(source: ImageSource.gallery);
        //   } else if (await platform.isDenied) {
        //        showDeleteDialog(context);
        //     // Either the permission was already granted before or the user just granted it.
        //   }
      }

      //  if (await Permission.camera.request().isDenied) {
      //   print("is denied");
      //   openAppSettings();
      //

      //   // We didn't ask for permission yet or the permission has been denied before but not permanently.
      //   // We didn't ask for permission yet or the permission has been denied before but not permanently.
      // }
      return false;
    } else if (await platform.status.isPermanentlyDenied) {
      if (Platform.isIOS) {
        showDialog(
            context: context,
            builder: (BuildContext context) => CupertinoAlertDialog(
                  title: Text("Settings"),
                  content: Text(
                      "Farm sharing want to access camera open settings and give permission"),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      child: Text("Not now"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    CupertinoDialogAction(
                      onPressed: () => openAppSettings(),
                      child: Text("iOS Settings"),
                    )
                  ],
                ));
      } else {
        showDeleteDialog(context,
            "FarmSharing app requires access to the gallery to upload pictures");
      }
      // showDialog(
      //     context: context,
      //     builder: (context) {
      //       return Center(
      //
      //         child: Container(
      //           color: Colors.white,
      //           height: 300,
      //           width: 400,
      //           child: Column(
      //             mainAxisSize: MainAxisSize.min,
      //             children: [
      //               TextButton(onPressed: (){}, child: Text("nfjk"))
      //             ],
      //           ),
      //
      //         ),
      //       );
      //     });

      // openAppSettings();
      print("is permanant");
      //  if (await Permission.camera.request().isDenied) {
      //   print("is denied");
      //   openAppSettings();
      //

      //   // We didn't ask for permission yet or the permission has been denied before but not permanently.
      // }
      return false;
    } else if (await platform.isGranted) {
      print("is grandted");
      //  var picked = ImagePicker().pickImage(source: ImageSource.gallery);
      Get.log("ggranted");
      return true;
      // Either the permission was already granted before or the user just granted it.
    } else if (await platform.isLimited) {
      // ImagePicker().pickImage(source: ImageSource.gallery).then((value) {
      //   print(value.toString());
      // });
      return true;
    }
    // final targetPath1 = dir1.absolute.path + "/dp${profileController.i}.jpg";
    // var compressedFile1 = aw
    // ait FlutterImageCompress.compressAndGetFile(
    //     imagePath, targetPath1,
    //     quality: 60);
    // print("compressedFile File: ${compressedFile1!.path}");
    // // Get.find<ProfileController>().image = compressedFile1;
    // // Get.find<ProfileController>().imagePath.value = compressedFile1.path;
    // profileController.addedFiles.add(compressedFile1);
    // profileController.i++;
    // Get.find<ProfileController>().update();
    //}
    return false;
  }

  Future<bool> getFromCamera(BuildContext context) async {
    //var status = await Permission.camera.status;
    var status = await Permission.camera.status; //
    await Permission.camera.request();
    if (await Permission.camera.status.isDenied) {
      if (Platform.isIOS) {
        await Permission.camera.request();
      } else {
        showDeleteDialog(context,
            "FarmSharing app requires access to the camera to upload pictures");
        // await platform.request();
        //   if (await platform.status.isPermanentlyDenied) {
        //     if (Platform.isIOS) {
        //       showDialog(
        //           context: context,
        //           builder: (BuildContext context) => CupertinoAlertDialog(
        //                 title: Text("Settings "),
        //                 content: Text(
        //                     "Farm sharing want to access camera open settings and give permission"),
        //                 actions: <Widget>[
        //                   CupertinoDialogAction(
        //                     isDefaultAction: true,
        //                     child: Text("No"),
        //                     onPressed: () => Navigator.pop(context),
        //                   ),
        //                   CupertinoDialogAction(
        //                     onPressed: () => openAppSettings(),
        //                     child: Text("open settings"),
        //                   )
        //                 ],
        //               ));
        //     } else {
        //       showDeleteDialog(context);
        //     }
        //     // showDialog(
        //     //     context: context,
        //     //     builder: (context) {
        //     //       return Center(
        //     //
        //     //         child: Container(
        //     //           color: Colors.white,
        //     //           height: 300,
        //     //           width: 400,
        //     //           child: Column(
        //     //             mainAxisSize: MainAxisSize.min,
        //     //             children: [
        //     //               TextButton(onPressed: (){}, child: Text("nfjk"))
        //     //             ],
        //     //           ),
        //     //
        //     //         ),
        //     //       );
        //     //     });
        //
        //     // openAppSettings();
        //     print("is permanant");
        //     //  if (await Permission.camera.request().isDenied) {
        //     //   print("is denied");
        //     //   openAppSettings();
        //     //
        //
        //     //   // We didn't ask for permission yet or the permission has been denied before but not permanently.
        //     // }
        //
        //   } else if (await platform.isGranted) {
        //     print("is grandted");
        //     var picked = ImagePicker().pickImage(source: ImageSource.gallery);
        //     Get.log("ggranted");
        //     // Either the permission was already granted before or the user just granted it.
        //   } else if (await platform.isLimited) {
        //     var picked = ImagePicker().pickImage(source: ImageSource.gallery);
        //   } else if (await platform.isDenied) {
        //        showDeleteDialog(context);
        //     // Either the permission was already granted before or the user just granted it.
        //   }
        return false;
      }
    }
    if (await Permission.camera.status.isPermanentlyDenied) {
      if (Platform.isIOS) {
        showDialog(
            context: context,
            builder: (BuildContext context) => CupertinoAlertDialog(
                  title: Text("Settings"),
                  content: Text(
                      "Farm sharing want to access camera open settings and give permission"),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      child: Text("Not now"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    CupertinoDialogAction(
                      child: Text("iOS Settings"),
                      onPressed: openAppSettings,
                    )
                  ],
                ));
      } else {
        showDeleteDialog(context,
            "FarmSharing app requires access to the camera to capture pictures");
      }
      // showDialog(
      //     context: context,
      //     builder: (context) {
      //       return Center(
      //
      //         child: Container(
      //           color: Colors.white,
      //           height: 300,
      //           width: 400,
      //           child: Column(
      //             mainAxisSize: MainAxisSize.min,
      //             children: [
      //               TextButton(onPressed: (){}, child: Text("nfjk"))
      //             ],
      //           ),
      //
      //         ),
      //       );
      //     });

      // openAppSettings();
      print("is permanant");
      //  if (await Permission.camera.request().isDenied) {
      //   print("is denied");
      //   openAppSettings();
      //

      //   // We didn't ask for permission yet or the permission has been denied before but not permanently.
      // }
      return false;
    } else if (await Permission.camera.isGranted ||
        await Permission.camera.isLimited) {
      // print("is grandted");
      // var picked = ImagePicker().pickImage(source: ImageSource.camera);
      // Get.log("ggranted");
      return true;
      // Either the permission was already granted before or the user just granted it.
    }

// You can can also directly ask the permission about its status.
//   else if (await Permission.camera.request().isPermanentlyDenied) {
//     var picked = ImagePicker().pickImage(source: ImageSource.camera);
//
//     // The OS restricts access, for example because of parental controls.
//   }

    // else{
    //   openAppSettings();
    //
    // }

// You can request multiple permissions at once.
// var statuses =
//     Permission.camera.request();
//   print(statuses);

    // Get.log("status ......  $status");
    // // if(!status.isPermanentlyDenied){
    // //   final pickedFile =
    // //      await ImagePicker().pickImage(source: ImageSource.camera);
    // // }
    // // Get.log("camera value,  $status");
    // //
    // //   var status =await Permission.camera.request();
    // //
    // //   final pickedFile =
    // //   await ImagePicker().pickImage(source: ImageSource.camera);
    // //   if (pickedFile != null) {
    // //     print("Picked File: ${pickedFile.path}");
    // //     var imagePath = pickedFile.path;
    // //     // Get.find<AuthController>().image = File(imagePath);
    // //     // Get.find<AuthController>().update();
    // //
    // //     var imageName = imagePath.split("/").last;
    // //     print("Image Name: $imageName");
    // //     final dir1 = Directory.systemTemp;
    // //     // final targetPath1 =
    // //     //     dir1.absolute.path + "/camera${profileController.i}.jpg";
    // //     // var compressedFile1 = await FlutterImageCompress.compressAndGetFile(
    // //     //     imagePath, targetPath1,
    // //     //     quality: 60);
    // //     // print("compressedFile File: ${compressedFile1!.path}");
    // //     // // Get.find<ProfileController>().image = compressedFile1;
    // //     // // Get.find<ProfileController>().imagePath.value = compressedFile1.path;
    // //     // profileController.i++;
    // //     // //profileController.businessData.sellerImageData.
    // //     // profileController.addedFiles.add(compressedFile1);
    // //     // Get.find<ProfileController>().update();
    // //   }
    // // else{
    // //
    // // }
    //
    //   if (status.isDenied) {
    //
    //
    //   }
    //   else  if (status.isGranted || status.isLimited) {
    //     final pickedFile =
    //     await ImagePicker().pickImage(source: ImageSource.camera);
    //     if (pickedFile != null) {
    //       print("Picked File: ${pickedFile.path}");
    //       var imagePath = pickedFile.path;
    //       // Get.find<AuthController>().image = File(imagePath);
    //       // Get.find<AuthController>().update();
    //
    //       var imageName = imagePath.split("/").last;
    //       print("Image Name: $imageName");
    //       final dir1 = Directory.systemTemp;
    //       // final targetPath1 =
    //       //     dir1.absolute.path + "/camera${profileController.i}.jpg";
    //       // var compressedFile1 = await FlutterImageCompress.compressAndGetFile(
    //       //     imagePath, targetPath1,
    //       //     quality: 60);
    //       // print("compressedFile File: ${compressedFile1!.path}");
    //       // // Get.find<ProfileController>().image = compressedFile1;
    //       // // Get.find<ProfileController>().imagePath.value = compressedFile1.path;
    //       // profileController.i++;
    //       // //profileController.businessData.sellerImageData.
    //       // profileController.addedFiles.add(compressedFile1);
    //       // Get.find<ProfileController>().update();
    //     }
    //   }
    //  else if (status.isPermanentlyDenied) {
    //
    //   }
    return false;
  }
}

showDeleteDialog(BuildContext context, String text) {
  // set up the buttons
  Widget cancelButton = GestureDetector(
    onTap: () {
      Navigator.pop(context);
    },
    child: Text(
      "Not now",
      style: TextStyle(fontSize: 12),
    ),
  );
  Widget continueButton = GestureDetector(
    onTap: () async {
      openAppSettings();
    },
    child: Text("Open settings".tr,
        style: TextStyle(fontStyle: FontStyle.normal, fontSize: 12)),
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    actionsPadding: EdgeInsets.only(right: 15, bottom: 15),
    // shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.all(Radius.circular(36.0))),
    title: Text(
      "Settings".tr,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    ),
    content: Text(
      text.tr,
      style: TextStyle(fontWeight: FontWeight.w400),
    ),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      });
}
