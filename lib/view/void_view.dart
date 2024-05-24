import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:queue_system/routes/app_pages.dart';
import 'package:queue_system/utils/constan.dart';
import 'package:queue_system/view_models/controller/customer_controller.dart';

class VoidView extends GetView<CustomerController> {
  const VoidView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(CustomerController());

    return  Obx(() => Stack(
              children: [
                controller.adminController.branch.value.playAds!
                    ? Video(controller: controller. adminController.controllerVideo)
                    : Image.asset(
                      'assets/images/noads.gif',
                      fit: BoxFit.cover,
                    ),
                Positioned(
                    left: 1,
                    top: 3,
                    child: GestureDetector(
                      onTap: () {
                        Get.offAllNamed(Routes.home);
                      },
                      child: const Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: Colors.white,
                      ),
                    ))
              ],
            ));
  }
}
