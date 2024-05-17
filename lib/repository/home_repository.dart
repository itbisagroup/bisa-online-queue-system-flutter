
import 'package:queue_system/data/network/base_api_services.dart';
import 'package:queue_system/data/network/network_api_services.dart';

class HomeRepository {
  final _apiService = NetworkApiService();

  Future<dynamic> getDetailQueue() async {
    dynamic response =
        await _apiService.getApi('${BaseApiServices.queueEndpoint}/details');
    return response;
  }
  Future<dynamic> getAllQueue(int page) async {
    dynamic response =
        await _apiService.getApi('${BaseApiServices.queueEndpoint}/lists?page=$page');
    return response;
  }
  Future<dynamic> searchAllQueue(String search) async {
    dynamic response =
        await _apiService.getApi('${BaseApiServices.queueEndpoint}/lists?search=$search');
    return response;
  }

  Future<dynamic> addNewQueue(String paxId) async {
    var body = {
      'pax_id': paxId,
    };
    dynamic response =
        await _apiService.postApi(body, BaseApiServices.newQueueEndpoint);
    return response;
  }
  Future<dynamic> printQueue(String queueId) async {
    var body = {
      'queue_id': queueId,
    };
    dynamic response =
        await _apiService.postApi(body, BaseApiServices.printQueueEndpoint);
    return response;
  }
  Future<dynamic>callQueue(String paxId) async {
    var body = {
      'pax_id': paxId,
    };
    dynamic response =
        await _apiService.postApi(body, BaseApiServices.callQueueEndpoint);
    return response;
  }
  Future<dynamic>addStatusQueue(int queueId,String status) async {
    var body = {
      'queue_id': queueId.toString(),
      'status': status,
    };
    dynamic response =
        await _apiService.postApi(body, BaseApiServices.addStatusQueueEndpoint);
    return response;
  }
  Future<dynamic>reset() async {
    var body = {
      'reset': 'true',
    };
    dynamic response =
        await _apiService.postApi(body, BaseApiServices.resetQueueEndpoint);
    return response;
  }
}
