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
  final storage = const FlutterSecureStorage();
  final adminController = Get.find<AdminController>();
  var isLoading = false.obs;
  @override
  void onInit() async {
    super.onInit();
    getBaseUrl();
  }

  Future<void> getBaseUrl() async {
    isLoading(true);
    final url = await SecureStorage().getUrl();
    final key = await SecureStorage().getKey();
    final title = await  storage.read(key: 'env_title');
    final label = await  storage.read(key: 'env_label');
    final videoPath = await  storage.read(key: 'env_path');
    final rto = await  storage.read(key: 'rto');

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
    AppDialog.showToastSuccess(title: "Success", desc: '', func: () {});
  }

  void videoEnv() async {
    await storage.delete(key: 'env_path');
    await storage.write(key: 'env_path', value: pathText.text);
    adminController.updatePathVideo();
    AppDialog.showToastSuccess(title: "Success", desc: '', func: () {});
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
          title: 'Success!',
          desc: 'Environment has been updated!',
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
            title: 'Invalid license key!',
            desc: 'Please enter a valid license key.',
            func: () {});
      } else if (error.value == 'Forbidden') {
        await storage.delete(key: 'base_url');
        await storage.delete(key: 'key');
        await storage.write(key: 'base_url', value: urlController.text);
        await storage.write(key: 'key', value: keyController.text);
        await BaseApiServices.initializeBaseUrl();
        AppDialog.showToastSuccess(
            title: 'Success!',
            desc: 'Environment has been updated!',
            func: () async {
              await const FlutterSecureStorage().delete(key: 'shift_date');
              Get.back();
              await adminController.updateQueueListApi();
            });
      } else {
        AppDialog.showToastError(
            title: 'Not Found!', desc: " Server not found", func: () {});
      }
    });
  }
}
