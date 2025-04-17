import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:pickup_queue_system/routes/app_pages.dart';

class OutletNotAvaliable extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    readRoute();
    return null;
  }

  Future<void> readRoute() async {

    try {
      const storage = FlutterSecureStorage();
      final outletName = await storage.read(key: 'outlet');

      if (outletName == null) {
        Get.offAllNamed(Routes.initial);
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error reading token: $error');
      }
    }
  }
}


