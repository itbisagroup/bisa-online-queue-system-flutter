import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../routes/app_pages.dart';

class LicenseKey {
  Future<Map<String, String>> getHeaders() async {
    const storage = FlutterSecureStorage();

    try {
      final key = await storage.read(key: 'key');

      return {
        'Queue': key!,
      };
    } catch (error) {
      throw Exception('Error getting headers: $error');
    }
  }

  Future<void> handleTokenError() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'key');
    Get.offAllNamed(Routes.auth);
  }
}
