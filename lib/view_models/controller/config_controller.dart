import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:queue_system/data/network/base_api_services.dart';
import 'package:queue_system/repository/auth_repository.dart';
import 'package:queue_system/utils/log.dart';
import 'package:queue_system/utils/secure_storage.dart';
import 'package:queue_system/view_models/controller/admin_controller.dart';
import 'package:queue_system/widget/app_dialog.dart';

class ConfigController extends GetxController {
  final _api = AuthRepository();
  final GlobalKey<FormState> gKfS = GlobalKey();
  final LogApp _logApp = LogApp();
  final TextEditingController keyController = TextEditingController();
  final TextEditingController urlController = TextEditingController();
  final TextEditingController titleText = TextEditingController();
  final TextEditingController labelText = TextEditingController();
  final TextEditingController pathText = TextEditingController();
  final TextEditingController rtoText = TextEditingController();
  RxString error = ''.obs;
  var fullscreenTimerSelected = 2.obs;
  var adsMutedStatus = true.obs;
  var autoFullscreenStatus = true.obs;
  List<int> items = [1, 2, 5, 10];
  final storage = const FlutterSecureStorage();
  final adminController = Get.find<AdminController>();
  var isLoading = false.obs;
  @override
  void onInit() async {
    super.onInit();
    getBaseUrl();
  }

  // Fungsi untuk mengubah item yang dipilih
  void setSelected(int value) {
    fullscreenTimerSelected.value = value;
  }

  Future<void> getBaseUrl() async {
    isLoading(true);
    final url = await SecureStorage().getUrl();
    final key = await SecureStorage().getKey();
    final title = await storage.read(key: 'env_title');
    final label = await storage.read(key: 'env_label');
    final videoPath = await storage.read(key: 'env_path');
    final rto = await storage.read(key: 'rto');
    final autoFullscreen = await storage.read(key: 'auto_fullscreen');
    final autoFullscreenTimer =
        await storage.read(key: 'auto_fullscreen_timer');
    final adsMuted = await storage.read(key: 'ads_muted');

    if (url != null) {
      urlController.text = url;
    }
    if (key != null) {
      keyController.text = key;
    }
    if (rto != null) {
      rtoText.text = rto;
    }
    if (url != null) {
      titleText.text = title!;
    }
    if (url != null) {
      labelText.text = label!;
    }
    if (url != null) {
      pathText.text = videoPath!;
    }
    if (autoFullscreenTimer != null) {
      fullscreenTimerSelected.value = int.parse(autoFullscreenTimer);
    }
    if (adsMuted != null) {
      adsMutedStatus.value = adsMuted == '1' ? true : false;
    }
    if (autoFullscreen != null) {
      autoFullscreenStatus.value = autoFullscreen == '1' ? true : false;
    }
    isLoading(false);
  }

  void setError(String value) => error.value = value;

  void costumerEnv() async {
    await storage.delete(key: 'env_title');
    await storage.delete(key: 'env_label');
    await storage.write(key: 'env_title', value: titleText.text);
    await storage.write(key: 'env_label', value: labelText.text);
    await storage.write(key: 'rto', value: rtoText.text);
    adminController.updateCallText();
    AppDialog.showToastSuccess(title: 'success'.tr, desc: '', func: () {});
  }

  void videoEnv() async {
    await storage.delete(key: 'env_path');
    await storage.write(key: 'env_path', value: pathText.text);
    await storage.delete(key: 'auto_fullscreen_timer');
    await storage.write(
        key: 'auto_fullscreen_timer',
        value: fullscreenTimerSelected.value.toString());
    await storage.write(
        key: 'auto_fullscreen',
        value: autoFullscreenStatus.value == true ? '1' : '0');
    videoAdsMuted();
    await adminController.updatePathVideo();
    await adminController.doFullscreen();
    AppDialog.showToastSuccess(title: 'success'.tr, desc: '', func: () {});
  }

  void registerLicense() {
    if (!gKfS.currentState!.validate()) return;

    AppDialog.showDialogLoading();
    _api
        .registerLicenseQueue(urlController.text, keyController.text)
        .then((value) async {
      Get.back();
      await storage.delete(key: 'base_url');
      await storage.delete(key: 'key');
      await storage.delete(key: 'rto');
      await storage.write(key: 'base_url', value: urlController.text);
      await storage.write(key: 'key', value: keyController.text);
      await storage.write(key: 'rto', value: rtoText.text);
      await BaseApiServices.initializeBaseUrl();
      AppDialog.showToastSuccess(
          title: 'success'.tr,
          desc: 'environment_updated'.tr,
          func: () async {
            await const FlutterSecureStorage().delete(key: 'shift_date');
            Get.back();
            await adminController.updateQueueListApi();
          });
    }).onError((errors, stackTrace) async {
      Get.back();
      setError(errors.toString());
      await _logApp.writeLog(
          " Failled to register license config API ${error.toString()}");
      if (error.value == 'Unauthorized') {
        AppDialog.showToastInfo(
            title: 'invalid_license_key'.tr,
            desc: 'invalid_license_key_desc'.tr,
            func: () {});
      } else if (error.value == 'Forbidden') {
        await storage.delete(key: 'base_url');
        await storage.delete(key: 'key');
        await storage.write(key: 'base_url', value: urlController.text);
        await storage.write(key: 'key', value: keyController.text);
        await BaseApiServices.initializeBaseUrl();
        AppDialog.showToastSuccess(
            title: 'success'.tr,
            desc: 'environment_updated'.tr,
            func: () async {
              await const FlutterSecureStorage().delete(key: 'shift_date');
              Get.back();
              await adminController.updateQueueListApi();
            });
      } else {
        AppDialog.showToastError(
            title: 'not_found'.tr, desc: "server_not_found".tr, func: () {});
      }
    });
  }

  void toggleCron(bool cronRunning) async {
    adminController.isCronRunning.value = cronRunning;
    if (!cronRunning) {
      adminController.cron.close();
    }
  }

  void toggleAutoFullscreen(bool autoFullscreen) async {
    autoFullscreenStatus.value = autoFullscreen;
  }

  void videoAdsMuted() async {
    await storage.delete(key: 'ads_muted');
    await storage.write(
        key: 'ads_muted', value: adsMutedStatus.value == true ? '1' : '0');
  }
  
}
