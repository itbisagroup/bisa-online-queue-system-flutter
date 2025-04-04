import 'package:queue_system/utils/constan.dart';
import 'package:queue_system/view_models/controller/auth_controller.dart';
import 'package:queue_system/widget/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AuthController());
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
                key: controller.gKfS,
                child: Column(
                  children: [
                    TextFormField(
                      controller: controller.urlController,
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
                      controller: controller.keyController,
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
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.maroon),
                  onPressed: controller.registerLicense,
                  child:  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.login,
                        color: AppColors.white,
                        size: 30,
                      ),
                      const SizedBox(width: 3),
                      AppText(
                        text: 'submit'.tr,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                        fontSize: 14,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
