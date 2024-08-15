
import 'package:queue_system/data/network/base_api_services.dart';
import 'package:queue_system/data/network/network_api_services.dart';

class BranchRepository {
  final _apiService = NetworkApiService();

  Future<dynamic> getBranch() async {
    dynamic response =
        await _apiService.getApi(BaseApiServices.branchEndpoint);
    return response;
  }


}
