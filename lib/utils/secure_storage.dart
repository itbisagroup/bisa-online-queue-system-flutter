import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  // Create storage
  final storage = const FlutterSecureStorage();

  final String _licenseKey = 'key';
  final String _url = 'base_url';

  Future setKey(String key) async {
    await storage.write(key: _licenseKey, value: key);
  }
  Future setUrl(String url) async {
    await storage.write(key: _url, value: url);
  }

  Future<String?> getKey() async {
    return await storage.read(key: _licenseKey);
  }
  Future<String?> getUrl() async {
    return await storage.read(key: _url);
  }
}
