import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class BaseApiServices {
  static String? _baseUrl;

  static Future<void> initializeBaseUrl() async {
    const storage = FlutterSecureStorage();
    final rto = await storage.read(key: 'rto');
    if (rto == null) {
      await const FlutterSecureStorage().write(key: 'rto', value: '20');
    }

    _baseUrl = await storage.read(key: 'base_url');
  }

  static String? get baseUrl =>
      _baseUrl ?? 'http://bisa-online-queue.local/api/client/v1';
  static final queueEndpoint = '$baseUrl/queues';
  static final branchEndpoint = '$baseUrl/branches';
  static final shiftEndpoint = '$baseUrl/shifts';
  static final syncsEndpoint = '$baseUrl/syncs';

  static final printQueueEndpoint = '$baseUrl/queues/prints';
  static final callQueueEndpoint = '$baseUrl/queues/calls';
  static final adsEndpoint = '$baseUrl/ads';
  Future<dynamic> getApi(String url);
  Future<dynamic> postApi(
    dynamic data,
    String url,
  );
}
