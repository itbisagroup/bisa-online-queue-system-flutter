
import 'package:flutter_dotenv/flutter_dotenv.dart';


abstract class BaseApiServices {
  static final String? url = dotenv.env['API_BASE_URL'];
  static const String apiPath = '/api/v1';
  static final String baseUrl = url! + apiPath;
  static final registerKeyEndpoint = '$baseUrl/queues/registers';
  static final queueEndpoint = '$baseUrl/queues';
  static final newQueueEndpoint = '$baseUrl/queues/new';
  static final printQueueEndpoint = '$baseUrl/queues/prints';
  static final callQueueEndpoint = '$baseUrl/queues/calls';
  static final addStatusQueueEndpoint = '$baseUrl/queues/status';
  static final resetQueueEndpoint = '$baseUrl/queues/resets';
  static final adsEndpoint = '$baseUrl/ads';
  Future<dynamic> getApi(String url);
  Future<dynamic> postApi(
    dynamic data,
    String url,
  );

}
