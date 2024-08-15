import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:queue_system/utils/constan.dart';
import 'package:queue_system/view_models/controller/config_controller.dart';
import 'package:queue_system/widget/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConfigView extends GetView<ConfigController> {
  const ConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ConfigController());
    return Scaffold(
        appBar: AppBar(
          title: const AppText(
            text: 'Configuration',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.black,
          ),
          backgroundColor: AppColors.white,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Wrap(
              children: [
                Card(
                  elevation: 20,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    color: AppColors.white,
                    height: 450,
                    width: 450,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.gear,
                              size: 30,
                              color: AppColors.maroon,
                            ),
                            AppText(
                              text: ' ENVIRONMENT CONFIGURATION',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.maroon,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Form(
                          key: controller.gKfS,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AppText(
                                  text: "Base Url",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.maroon),
                              TextFormField(
                                obscureText: true,
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
                                ),
                                validator: (val) {
                                  if (val!.trim().isEmpty) {
                                    return "🔴 Base url still empty";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const AppText(
                                  text: "License Key",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.maroon),
                              TextFormField(
                                obscureText: true,
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
                                ),
                                validator: (val) {
                                  if (val!.trim().isEmpty) {
                                    return "🔴 Key still empty";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const AppText(
                                  text: "Request Time Out",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.maroon),
                              TextFormField(
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                controller: controller.rtoText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1,
                                  wordSpacing: 1,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'exm: 20 (in second)',
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
                                ),
                                validator: (val) {
                                  if (val!.trim().isEmpty) {
                                    return "🔴 rto still empty";
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.maroon),
                            onPressed: () {
                              controller.registerLicense();
                            },
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.edit_document,
                                  color: AppColors.white,
                                  size: 30,
                                ),
                                SizedBox(width: 10),
                                AppText(
                                  text: 'Save Configuration',
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
                Card(
                  elevation: 20,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    color: AppColors.white,
                    height: 450,
                    width: 450,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.screenshot_monitor,
                              size: 30,
                              color: AppColors.maroon,
                            ),
                            AppText(
                              text: ' CUSTOMER VIEW CONFIGURATION',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.maroon,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Form(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AppText(
                                  text: "Title",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.maroon),
                              TextFormField(
                                controller: controller.titleText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1,
                                  wordSpacing: 1,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'exm: Queue Number',
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
                                ),
                                validator: (val) {
                                  if (val!.trim().isEmpty) {
                                    return "🔴 Base url still empty";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const AppText(
                                  text: "Label Calling Text",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.maroon),
                              TextFormField(
                                controller: controller.labelText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1,
                                  wordSpacing: 1,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'exm: Please Confirm to Greeter',
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
                                ),
                                validator: (val) {
                                  if (val!.trim().isEmpty) {
                                    return "🔴 Base url still empty";
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.maroon),
                            onPressed: () {
                              controller.costumerEnv();
                            },
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.edit_document,
                                  color: AppColors.white,
                                  size: 30,
                                ),
                                SizedBox(width: 10),
                                AppText(
                                  text: 'Save Configuration',
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
                Card(
                  elevation: 20,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    color: AppColors.white,
                    height: 450,
                    width: 450,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.view_carousel,
                              size: 30,
                              color: AppColors.maroon,
                            ),
                            AppText(
                              text: ' VIDEO CONFIGURATION',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.maroon,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Form(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AppText(
                                  text: "Path",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.maroon),
                              TextFormField(
                                controller: controller.pathText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1,
                                  wordSpacing: 1,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'exm: d:/video/',
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
                                ),
                                validator: (val) {
                                  if (val!.trim().isEmpty) {
                                    return "🔴 Video path still empty";
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.maroon),
                            onPressed: () {
                              controller.videoEnv();
                            },
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.edit_document,
                                  color: AppColors.white,
                                  size: 30,
                                ),
                                SizedBox(width: 10),
                                AppText(
                                  text: 'Save Configuration',
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
              ],
            ),
          ),
        ));
  }
}
