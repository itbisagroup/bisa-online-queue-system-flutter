import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LicenseKey {
  Future<Map<String, String>> getHeaders() async {
    const storage = FlutterSecureStorage();

    final key = await storage.read(key: 'key');
    final lang = await storage.read(key: 'lang');
    return {
      'Authorization': 'Bearer $key',
      'Accept-Language': lang ?? 'en',
    };
  }
}
