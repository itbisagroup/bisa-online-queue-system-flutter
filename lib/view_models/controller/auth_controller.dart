import 'dart:async';
import 'dart:io';
import 'package:queue_system/data/network/base_api_services.dart';
import 'package:queue_system/models/queue.dart';
import 'package:queue_system/repository/auth_repository.dart';
import 'package:queue_system/repository/home_repository.dart';
import 'package:queue_system/routes/app_pages.dart';
import 'package:queue_system/utils/secure_storage.dart';
import 'package:queue_system/widget/app_dialog.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class AuthController extends GetxController {
  final _api = AuthRepository();
  final GlobalKey<FormState> gKfS = GlobalKey();
  final TextEditingController keyController = TextEditingController();
  final ads = <Ads>[].obs;
  RxString error = ''.obs;

  void setError(String value) => error.value = value;

  void registerLicense() {
    AppDialog.showDialogLoading();
    _api.registerLicenseQueue(keyController.text).then((value) async {
      await SecureStorage().setKey(keyController.text);
      await fetchAds();
      Get.offAllNamed(Routes.home);
    }).onError((errors, stackTrace) {
      Get.back();
      setError(errors.toString());
      print(error.value);
      if (error.value ==
          '{secret_key: The Secret Key is invalid or unknown.}') {
        AppDialog.showDialogMsg(
            title: 'Invalid license key!',
            icon: FontAwesomeIcons.triangleExclamation,
            func: Get.back,
            textFunc: 'Try Again');
      } else {
        AppDialog.showDialogMsg(
            title: error.value.toString(),
            icon: FontAwesomeIcons.circleXmark,
            func: Get.back,
            textFunc: 'Try Again');
      }
    });
  }

  Future<void> fetchAds() async {
    final queueApi = HomeRepository();
    queueApi.getDetailQueue().then((value) async {
      final List<dynamic> listAds = value['data']['ads'];
      ads.addAll(listAds.map((json) => Ads.fromJson(json)).toList());
      await downloadAds();
    }).onError((error, stackTrace) {
      setError(error.toString());
      print(error);
    });
  }

  Future<void> downloadAds() async {
    try {
      for (var ad in ads) {
        final url =
            Uri.parse('${BaseApiServices.adsEndpoint}/${ad.uuid}/download');
        Map<String, String> requestExtraHeaders = {'Queue': keyController.text};
        final response = await http.get(url, headers: requestExtraHeaders);
        if (response.statusCode == 200) {
          var videoDirectory = await getApplicationDocumentsDirectory();

          var path = "${videoDirectory.path}/assets/videos/";
          var filePathAndName = '$path/${ad.content}';

          await Directory(path).create(recursive: true);
          File video = File(filePathAndName);
          video.writeAsBytesSync(response.bodyBytes);
          print('success  ${ad.uuid}');
        } else {
          AppDialog.showToastInfo(msg: response.statusCode.toString());
          print('Failed to download ad with UUID:  ${ad.uuid}');
          print('Failed to download ad with UUID:  ${response.body}');
          print('Failed to download ad with UUID:  $url');
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
