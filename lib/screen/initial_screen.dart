import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pickup_queue_system/controller/initial_controller.dart';
import 'package:pickup_queue_system/routes/app_pages.dart';
import 'package:pickup_queue_system/utills/constans.dart';
import 'package:pickup_queue_system/utills/widget/app_text.dart';

class InitialScreen extends GetView<InitialController> {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(InitialController());
    return Scaffold(
      body: Center(
        child: Card(
          elevation: 20,
          child: Container(
            padding: const EdgeInsets.all(20),
            color: AppColors.white,
            height: 450,
            width: 450,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 150,
                  width: 150,
                ),
                const AppText(
                  text: 'BISA ONLINE QUEUE SYSTEM',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.black,
                ),
                Form(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: TextEditingController(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1,
                          wordSpacing: 1,
                        ),
                        decoration: const InputDecoration(
                            hintText: 'exm: https://example.com',
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1,
                              wordSpacing: 1,
                              fontStyle: FontStyle.italic,
                            ),
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1,
                              wordSpacing: 1,
                            ),
                            labelText: 'Server API'),
                        validator: (val) {
                          if (val!.trim().isEmpty) {
                            return "🔴 ${'input_url'.tr}";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: TextEditingController(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1,
                          wordSpacing: 1,
                        ),
                        decoration: const InputDecoration(
                            hintText: 'exm: sxxx:xxxxxxxxxx',
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1,
                              wordSpacing: 1,
                              fontStyle: FontStyle.italic,
                            ),
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1,
                              wordSpacing: 1,
                            ),
                            labelText: 'License Key'),
                        validator: (val) {
                          if (val!.trim().isEmpty) {
                            return "🔴 ${'input_key'.tr}";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.offAllNamed(Routes.home);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.maroon,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const AppText(
                        text: 'Submit',
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
