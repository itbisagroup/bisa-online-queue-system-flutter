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
          title: AppText(
            text: 'config'.tr,
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
                    height: 500,
                    width: 450,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.wifi_tethering,
                              size: 30,
                              color: AppColors.maroon,
                            ),
                            const SizedBox(width: 10),
                            AppText(
                              text: 'connection'.tr,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.maroon,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Form(
                          key: controller.gKfS,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                  text: "base_url".tr,
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
                                decoration: InputDecoration(
                                  hintText: '${'exm'.tr}: https://example.com',
                                  hintStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 1,
                                    wordSpacing: 1,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  border: const OutlineInputBorder(),
                                  labelStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 1,
                                    wordSpacing: 1,
                                  ),
                                ),
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
                              AppText(
                                  text: 'license_key'.tr,
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
                                decoration: InputDecoration(
                                  hintText: '${'exm'.tr}: sxxx:xxxxxxxxxx',
                                  hintStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 1,
                                    wordSpacing: 1,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  border: const OutlineInputBorder(),
                                  labelStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 1,
                                    wordSpacing: 1,
                                  ),
                                ),
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
                              AppText(
                                  text: "rto_title".tr,
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
                                decoration: InputDecoration(
                                  hintText:
                                      '${'exm'.tr}: 20 (${'in_second'.tr})',
                                  hintStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 1,
                                    wordSpacing: 1,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  border: const OutlineInputBorder(),
                                  labelStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 1,
                                    wordSpacing: 1,
                                  ),
                                ),
                                validator: (val) {
                                  if (val!.trim().isEmpty) {
                                    return "🔴 ${'input_rto'.tr}";
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
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.edit_document,
                                  color: AppColors.white,
                                  size: 30,
                                ),
                                const SizedBox(width: 10),
                                AppText(
                                  text: 'save_config'.tr,
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
                    height: 500,
                    width: 450,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.screenshot_monitor,
                              size: 30,
                              color: AppColors.maroon,
                            ),
                            const SizedBox(width: 10),
                            AppText(
                              text: 'customer_screen'.tr,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.maroon,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Form(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                  text: "title_call_queue_text".tr,
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
                                decoration: InputDecoration(
                                  hintText: ' ${'exm'.tr} ${'queue_number'.tr}',
                                  hintStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 1,
                                    wordSpacing: 1,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  border: const OutlineInputBorder(),
                                  labelStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 1,
                                    wordSpacing: 1,
                                  ),
                                ),
                                validator: (val) {
                                  if (val!.trim().isEmpty) {
                                    return "🔴 ${'empty_input'.tr}";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              AppText(
                                  text: "instruction_call_queue_text".tr,
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
                                decoration: InputDecoration(
                                  hintText:
                                      '${'exm'.tr} ${'exm_instruction'.tr} ',
                                  hintStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 1,
                                    wordSpacing: 1,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  border: const OutlineInputBorder(),
                                  labelStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 1,
                                    wordSpacing: 1,
                                  ),
                                ),
                                validator: (val) {
                                  if (val!.trim().isEmpty) {
                                    return "🔴 ${'empty_input'.tr}";
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
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.edit_document,
                                  color: AppColors.white,
                                  size: 30,
                                ),
                                const SizedBox(width: 10),
                                AppText(
                                  text: 'save_config'.tr,
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
                    height: 500,
                    width: 450,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.view_carousel,
                              size: 30,
                              color: AppColors.maroon,
                            ),
                            const SizedBox(width: 10),
                            AppText(
                              text: 'video_config'.tr,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.maroon,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Form(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                  text: "path".tr,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.maroon),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: controller.pathText,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        letterSpacing: 1,
                                        wordSpacing: 1,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: '${'exm'.tr} d:/video/',
                                        hintStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          letterSpacing: 1,
                                          wordSpacing: 1,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        border: const OutlineInputBorder(),
                                        labelStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          letterSpacing: 1,
                                          wordSpacing: 1,
                                        ),
                                      ),
                                      validator: (val) {
                                        if (val!.trim().isEmpty) {
                                          return "🔴 ${'empty_input'.tr}";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  IconButton(
                                      onPressed:
                                          controller.adminController.download,
                                      icon: const Icon(Icons.download)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        AppText(
                            text: "muted_video".tr,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.maroon),
                        Obx(
                          () => Switch(
                            value: controller.adsMutedStatus.value,
                            onChanged: (value) {
                              controller.adsMutedStatus.value = value;
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        AppText(
                            text: "auto_fullscreen".tr,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.maroon),
                        Obx(
                          () => Switch(
                            value: controller.autoFullscreenStatus.value,
                            onChanged: (value) {
                              controller.toggleAutoFullscreen(value);
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Obx(
                          () => Visibility(
                            visible: controller.autoFullscreenStatus.value,
                            child: AppText(
                                text: "timer_fulscreen".tr,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.maroon),
                          ),
                        ),
                        Obx(() {
                          return Visibility(
                            visible: controller.autoFullscreenStatus.value,
                            child: DropdownButton<int>(
                              value: controller.fullscreenTimerSelected.value,
                              hint: AppText(
                                text: 'hint_timer_fulscreen'.tr,
                              ),
                              items: controller.items.map((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: AppText(
                                    text: '$value ${'minute'.tr}',
                                  ),
                                );
                              }).toList(),
                              onChanged: (int? newValue) {
                                controller.setSelected(newValue!);
                              },
                            ),
                          );
                        }),
                        const SizedBox(
                          height: 20,
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
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.edit_document,
                                  color: AppColors.white,
                                  size: 30,
                                ),
                                const SizedBox(width: 10),
                                AppText(
                                  text: 'save_config'.tr,
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
                    height: 500,
                    width: 450,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                FontAwesomeIcons.flag,
                                size: 30,
                                color: AppColors.maroon,
                              ),
                              const SizedBox(width: 10),
                              AppText(
                                text: 'language'.tr,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.maroon,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          AppText(
                              text: "choose_language".tr,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.maroon),
                          const SizedBox(
                            height: 10,
                          ),
                          Obx(
                            () => Wrap(
                              runSpacing: 8,
                              spacing: 8,
                              alignment: WrapAlignment.center,
                              runAlignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                ChoiceChip(
                                  label: const AppText(
                                    text: 'EN',
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black,
                                  ),
                                  avatar: Image.asset('assets/images/us.png'),
                                  selected: controller
                                      .adminController.isEnglishApp.value,
                                  backgroundColor: AppColors.white,
                                  selectedColor: AppColors.pink,
                                  elevation: 4.0,
                                  side: const BorderSide(
                                      color: Colors.transparent),
                                  onSelected: (selected) {
                                    if (!controller
                                        .adminController.isEnglishApp.value) {
                                      controller.adminController.lang();
                                    }
                                  },
                                  showCheckmark: false,
                                ),
                                ChoiceChip(
                                  label: const AppText(
                                    text: 'ID',
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black,
                                  ),
                                  avatar: Image.asset('assets/images/id.png'),
                                  selected: !controller
                                      .adminController.isEnglishApp.value,
                                  selectedColor: AppColors.pink,
                                  backgroundColor: AppColors.white,
                                  elevation: 4.0,
                                  side: const BorderSide(
                                      color: Colors.transparent),
                                  onSelected: (selected) {
                                    if (controller
                                        .adminController.isEnglishApp.value) {
                                      controller.adminController.lang();
                                    }
                                  },
                                  showCheckmark: false,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          AppText(
                              text: "language_print".tr,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.maroon),
                          const SizedBox(
                            height: 10,
                          ),
                          Obx(
                            () => Wrap(
                              runSpacing: 8,
                              spacing: 8,
                              alignment: WrapAlignment.center,
                              runAlignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                ChoiceChip(
                                  label: const AppText(
                                    text: 'EN',
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black,
                                  ),
                                  avatar: Image.asset('assets/images/us.png'),
                                  selected: controller
                                      .adminController.isEnglishPrinter.value,
                                  backgroundColor: AppColors.white,
                                  selectedColor: AppColors.pink,
                                  elevation: 4.0,
                                  side: const BorderSide(
                                      color: Colors.transparent),
                                  onSelected: (selected) {
                                    if (!controller.adminController
                                        .isEnglishPrinter.value) {
                                      controller.adminController.langPrinter();
                                    }
                                  },
                                  showCheckmark: false,
                                ),
                                ChoiceChip(
                                  label: const AppText(
                                    text: 'ID',
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black,
                                  ),
                                  avatar: Image.asset('assets/images/id.png'),
                                  selected: !controller
                                      .adminController.isEnglishPrinter.value,
                                  selectedColor: AppColors.pink,
                                  backgroundColor: AppColors.white,
                                  elevation: 4.0,
                                  side: const BorderSide(
                                      color: Colors.transparent),
                                  onSelected: (selected) {
                                    if (controller.adminController
                                        .isEnglishPrinter.value) {
                                      controller.adminController.langPrinter();
                                    }
                                  },
                                  showCheckmark: false,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Row(
                            children: [
                              const Icon(
                                FontAwesomeIcons.gears,
                                size: 30,
                                color: AppColors.maroon,
                              ),
                              const SizedBox(width: 20),
                              AppText(
                                text: 'more_config'.tr,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.maroon,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          AppText(
                              text: "cron_run".tr,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.maroon),
                          Obx(
                            () => Switch(
                              value: controller
                                  .adminController.isCronRunning.value,
                              onChanged: (value) {
                                controller.toggleCron(value);
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          AppText(
                              text: "show_qr_print".tr,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.maroon),
                          Obx(
                            () => Switch(
                              value: controller.showQrOnPrint.value,
                              onChanged: (value) {
                                controller.toggleShowQr(value);
                              },
                            ),
                          ),
                        ]),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}