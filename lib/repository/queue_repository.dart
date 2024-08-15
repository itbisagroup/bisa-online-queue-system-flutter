
import 'package:queue_system/data/network/base_api_services.dart';
import 'package:queue_system/data/network/network_api_services.dart';

class QueueRepository {
  final _apiService = NetworkApiService();

  Future<dynamic> getDetailQueue() async {
    dynamic response =
        await _apiService.getApi('${BaseApiServices.queueEndpoint}/views');
    return response;
  }
  Future<dynamic> getAllQueue(int page,String status) async {
    dynamic response =
        await _apiService.getApi('${BaseApiServices.queueEndpoint}?page=$page&status=$status');
    return response;
  }
  Future<dynamic> searchAllQueue(String search) async {
    dynamic response =
        await _apiService.getApi('${BaseApiServices.queueEndpoint}?search=$search');
    return response;
  }

  Future<dynamic> addNewQueue(String paxId,String paxQuantity) async {
    var body = {
      'pax_id': paxId,
      'queue_quantity': paxQuantity,
    };
    dynamic response =
        await _apiService.postApi(body, BaseApiServices.queueEndpoint);
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
  Future<dynamic>addStatusQueue(String queueId,String status) async {
    var body = {
      'status': status,
    };
    dynamic response =
        await _apiService.postApi(body,'${BaseApiServices.queueEndpoint}/$queueId/status');
    return response;
  }
  Future<dynamic>updateQty(String queueId,String qty) async {
    var body = {
      'queue_quantity': qty,
    };
    dynamic response =
        await _apiService.postApi(body,'${BaseApiServices.queueEndpoint}/$queueId');
    return response;
  }

}
