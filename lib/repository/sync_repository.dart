import 'package:queue_system/data/network/base_api_services.dart';
import 'package:queue_system/data/network/network_api_services.dart';

class SyncRepository {
  final _apiService = NetworkApiService();

  Future<dynamic> getData() async {
    dynamic response =
        await _apiService.getApi('${BaseApiServices.syncsEndpoint}/get-data');
    return response;
  }
  Future<dynamic> sendData() async {
    dynamic response =
        await _apiService.getApi('${BaseApiServices.syncsEndpoint}/send-data');
    return response;
  }

 
}
