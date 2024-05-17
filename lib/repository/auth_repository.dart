

import 'package:queue_system/data/network/base_api_services.dart';
import 'package:queue_system/data/network/network_api_services.dart';

class AuthRepository {
  final _apiService = NetworkApiService();

  Future<dynamic> registerLicenseQueue(String key) async {

    var body = {
      'secret_key': key,
    };

    dynamic response =
        await _apiService.registerKey(body, BaseApiServices.registerKeyEndpoint);
    return response;
  }

}
