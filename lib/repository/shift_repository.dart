import 'package:queue_system/data/network/base_api_services.dart';
import 'package:queue_system/data/network/network_api_services.dart';

class ShiftRepository {
  final _apiService = NetworkApiService();

  Future<dynamic> getAllShift(int page) async {
    dynamic response =
        await _apiService.getApi('${BaseApiServices.shiftEndpoint}?page=$page');
    return response;
  }

  Future<dynamic> searchAllShift(String search) async {
    dynamic response = await _apiService
        .getApi('${BaseApiServices.shiftEndpoint}?search=$search');
    return response;
  }

  Future<dynamic> getDetailShift(String id) async {
    dynamic response =
        await _apiService.getApi('${BaseApiServices.shiftEndpoint}/$id');
    return response;
  }

  Future<dynamic> addNewShift() async {
    var body = {};
    dynamic response =
        await _apiService.postApi(body, BaseApiServices.shiftEndpoint);
    return response;
  }

  Future<dynamic> endShift() async {
    var body = {};
    dynamic response = await _apiService.postApi(
        body, '${BaseApiServices.shiftEndpoint}/ends');
    return response;
  }
}
