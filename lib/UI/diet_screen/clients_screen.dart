import 'package:fitness_zone_2/UI/diet_screen/client_details_screen.dart';
import 'package:fitness_zone_2/data/controllers/home_controller/home_controller.dart';
import 'package:fitness_zone_2/values/my_imgs.dart';
import 'package:fitness_zone_2/widgets/app_bar_widget.dart';
import 'package:fitness_zone_2/widgets/circular_progress.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/controllers/diet_contoller/diet_controller.dart';
import '../chat/widgets/chat_room.dart';

class ClientsScreen extends StatelessWidget {
  DietController dietController = Get.find();
  HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: HelpingWidgets().appBarWidget(() {
        Get.back();
      }, text: "Clients"),
      body: Obx(() => dietController.clientDataLoad.value
          ? ListView.separated(
              itemCount: dietController.getDietClientsModel!.cliets.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey.shade300,
                thickness: 1,
              ),
              itemBuilder: (context, index) {
                final client =
                    dietController.getDietClientsModel!.cliets[index];
                return ListTile(
                  visualDensity: const VisualDensity(vertical: -4),
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage(MyImgs.avatar),
                    radius: 25,
                  ),
                  title: Text(
                      "${client.user?.firstName} ${client.user?.lastName}",
                      style: textTheme.bodySmall!
                          .copyWith(fontWeight: FontWeight.w500)),
                  subtitle: Text(
                      "${DateFormat("MMMM, dd").format(client.buyingDate)} - ${DateFormat("MMMM, dd").format(client.expireDate)}",
                      style: textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.black.withOpacity(0.4))),
                  trailing: IconButton(
                    icon: const Icon(Icons.message),
                    onPressed: () async {
                      if (client.user != null) {
                        var userDetail = client.user!.id.toString();

                        var userMap = await homeController
                            .getspecificUserFromFireStore(userDetail);
                        var roomId =
                            await homeController.makeRoomId(userDetail);

                        Get.to(() => ChatRoom(
                              title:
                                  "Message to ${client.user?.firstName} ${client.user?.lastName}",
                              chatRoomId: roomId,
                              userMap: userMap,
                            ));
                      }
                    },
                  ),
                  onTap: () {
                    if (client.user != null) {
                      Get.to(() => ClientDetailsScreen(
                            clientUser: client.user!,
                            planId: client.id,
                          ));
                    }

                    // Handle client item tap
                  },
                );
              },
            )
          : CircularProgress()),
    );
  }
}
