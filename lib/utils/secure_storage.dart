import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  // Create storage
  final storage = const FlutterSecureStorage();

  final String _licenseKey = 'key';

  Future setKey(String key) async {
    await storage.write(key: _licenseKey, value: key);
  }

  Future<String?> getKey() async {
    return await storage.read(key: _licenseKey);
  }
}
