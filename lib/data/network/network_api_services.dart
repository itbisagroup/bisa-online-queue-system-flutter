import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:queue_system/data/app_exceptions.dart';
import 'package:queue_system/data/network/base_api_services.dart';
import 'package:queue_system/data/response/license_key.dart';
import 'package:queue_system/routes/app_pages.dart';

class NetworkApiService extends BaseApiServices {
  @override
  Future<dynamic> getApi(String url) async {
    if (kDebugMode) {
      print(url);
    }
    dynamic responseJson;
    final headers = await LicenseKey().getHeaders();
    try {
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 7));
      responseJson = returnResponse(response);
    } on SocketException {
      throw InternetException('');
    } on TimeoutException {
      throw RequestTimeOut('');
    }
    return responseJson;
  }

  @override
  Future<dynamic> postApi(var data, String url) async {
    if (kDebugMode) {
      print(url);
    }
    dynamic responseJson;
    final headers = await LicenseKey().getHeaders();
    try {
      final response = await http
          .post(Uri.parse(url), body: data, headers: headers)
          .timeout(const Duration(seconds: 15));
      responseJson = returnResponse(response);
    } on SocketException {
      throw InternetException('');
    } on TimeoutException {
      throw RequestTimeOut('');
    }
    return responseJson;
  }

  Future<dynamic> registerKey(var data, String url) async {
    if (kDebugMode) {
      print(url);
    }
    dynamic responseJson;
    try {
      final response = await http
          .post(
            Uri.parse(url),
            body: data,
          )
          .timeout(const Duration(seconds: 10));
      responseJson = returnResponse(response);
    } on SocketException {
      throw InternetException('');
    } on TimeoutException {
      throw RequestTimeOut('');
    }
    return responseJson;
  }

  dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;
      case 201:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;
      case 204:
        return null;
      case 400:
        dynamic responseJson = jsonDecode(response.body);
        throw InvalidUrlException(responseJson['errors'].toString());
      case 401:
        throw UnautorizedException('');
      case 403:
        const storage = FlutterSecureStorage();
        storage.deleteAll();
        Get.offAllNamed(Routes.auth);
        throw UnautorizedException('');
      default:
        throw FetchDataException(
            'Error accourerd while comunicationg with server ${response.statusCode}');
    }
  }
}
