


import 'package:queue_system/data/network/network_api_services.dart';

class AuthRepository {
  final _apiService = NetworkApiService();

  Future<dynamic> registerLicenseQueue(String url,String key,) async {

    var body = {
      'Authorization': 'Bearer $key'
    };

    dynamic response =
        await _apiService.registerKey('$url/queues/views', body);
    return response;
  }

}
