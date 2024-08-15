
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LicenseKey {
  Future<Map<String, String>> getHeaders() async {
     const storage = FlutterSecureStorage();


      final key = await storage.read(key: 'key');

    return {'Authorization': 'Bearer $key'};
  }


}
