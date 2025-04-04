import 'dart:async';
import 'package:queue_system/data/network/base_api_services.dart';
import 'package:queue_system/repository/auth_repository.dart';
import 'package:queue_system/routes/app_pages.dart';
import 'package:queue_system/utils/log.dart';
import 'package:queue_system/utils/secure_storage.dart';
import 'package:queue_system/widget/app_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {

  final _api = AuthRepository();
  final GlobalKey<FormState> gKfS = GlobalKey();
    final LogApp _logApp = LogApp();
  final TextEditingController keyController = TextEditingController();
  final TextEditingController urlController = TextEditingController();
  RxString error = ''.obs;

  void setError(String value) => error.value = value;

  void registerLicense() {
    if (!gKfS.currentState!.validate()) return;

    AppDialog.showDialogLoading();
    _api
        .registerLicenseQueue(urlController.text, keyController.text)
        .then((value) async {
      await SecureStorage().setUrl(urlController.text);
      await SecureStorage().setKey(keyController.text);
      await BaseApiServices.initializeBaseUrl();
      Get.offAllNamed(Routes.home);
    }).onError((errors, stackTrace) async {
      Get.back();
      setError(errors.toString());
      await _logApp.writeLog(" Failed register ${error.value}");

      if (error.value == 'Unauthorized') {
        await SecureStorage().setUrl(urlController.text);
        await SecureStorage().setKey(keyController.text);
        await BaseApiServices.initializeBaseUrl();
        Get.offAllNamed(Routes.home);
      } else if (error.value == 'Forbidden') {
        await SecureStorage().setUrl(urlController.text);
        await SecureStorage().setKey(keyController.text);
        await BaseApiServices.initializeBaseUrl();
        Get.offAllNamed(Routes.home);
      } else {
        AppDialog.showToastError(
            title: 'failed_register_key'.tr,
            desc: "failed_register_key_desc".tr,
            func: Get.back);
      }
    });
  }
}
