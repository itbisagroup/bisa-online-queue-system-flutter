import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:queue_system/data/network/base_api_services.dart';

import 'package:queue_system/routes/app_pages.dart';
import 'package:queue_system/utils/secure_storage.dart';

class KeyAvaliable extends GetMiddleware {
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

      if (key != null && baseUrl != null) {
        await BaseApiServices.initializeBaseUrl();
        Get.offAllNamed(Routes.home);
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error reading key: $error');
      }
    }
  }
}
