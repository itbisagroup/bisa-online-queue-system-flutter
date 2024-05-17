
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:queue_system/routes/app_pages.dart';
import 'package:queue_system/utils/secure_storage.dart';

class KeyNotAvaliable extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    readRoute();
    return null;
  }

  Future<void> readRoute() async {
    final secureStorage = SecureStorage();

    try {
      final key = await secureStorage.getKey();
      if (key == null) {
        Get.offAllNamed(Routes.auth);
      }
    } catch (error) {
      print('Error reading token: $error');
    }
  }
}
