import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
      const storage = FlutterSecureStorage();
      final baseUrl = await storage.read(key: 'base_url');
      final key = await secureStorage.getKey();

      if (key == null && baseUrl == null) {
        Get.offAllNamed(Routes.auth);
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error reading token: $error');
      }
    }
  }
}


