import 'dart:async';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final _api = AuthRepository();
  final GlobalKey<FormState> gKfS = GlobalKey();
  final TextEditingController keyController = TextEditingController();
  RxString error = ''.obs;

  void setError(String value) => error.value = value;

  void registerLicense() {
    if (!gKfS.currentState!.validate()) return;
    AppDialog.showDialogLoading();
    _api.registerLicenseQueue(keyController.text).then((value) async {
      await SecureStorage().setKey(keyController.text);
      await insertStatusRow();
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

  Future<void> insertStatusRow() async {
    final queueApi = HomeRepository();
    queueApi.getDetailQueue().then((value) async {
      final int id = value['data']['branch']['id'];
      await checkAndInsertStatus(id);
    }).onError((error, stackTrace) {
      setError(error.toString());
      print(error);
    });
  }

  Future<void> checkAndInsertStatus(int id) async {
    final response = await Supabase.instance.client
        .from('status')
        .select()
        .eq('id_branch', id);
    if (response.isEmpty) {
      await Supabase.instance.client
          .from('status')
          .insert({'id_branch': id, 'isActive': false});
      print('Data inserted supabase');
    } else {
      print('Already inserted supabase');
    }
  }

}
