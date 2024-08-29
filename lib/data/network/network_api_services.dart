import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:queue_system/data/app_exceptions.dart';
import 'package:queue_system/data/network/base_api_services.dart';
import 'package:queue_system/data/response/license_key.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class NetworkApiService extends BaseApiServices {
  @override
  Future<dynamic> getApi(String url) async {
    if (kDebugMode) {
      print(url);
    }
    dynamic responseJson;
    final headers = await LicenseKey().getHeaders();
    final rto = await const FlutterSecureStorage().read(key: 'rto');
    try {
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout( Duration(seconds: int.parse(rto ?? '20')));
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
     final rto = await const FlutterSecureStorage().read(key: 'rto');
    try {
      final response = await http
          .post(Uri.parse(url), body: data, headers: headers)
          .timeout( Duration(seconds: int.parse(rto ?? '20')));
      responseJson = returnResponse(response);
    } on SocketException {
      throw InternetException('');
    } on TimeoutException {
      throw RequestTimeOut('');
    }
    return responseJson;
  }

  Future<dynamic> registerKey(String url, Map<String, String> header) async {
    if (kDebugMode) {
      print(url);
    }
    dynamic responseJson;
    
    try {
      final response = await http
          .get(Uri.parse(url), headers: header)
          .timeout(const Duration(seconds: 20));
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
        throw ForbidenException('');
      case 502:
        throw BadGateway('');
      case 429:
        throw ToManyRequest('');
      default:
        throw FetchDataException(response.statusCode.toString());
    }
  }
}
