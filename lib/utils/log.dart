import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:queue_system/utils/constan.dart';
import 'package:windows_system_info/windows_system_info.dart';

class LogApp {
  //file log
  Future<String> get _localPath async {
    final directory = await getApplicationCacheDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/queue_logs.txt');
  }

  Future<File> writeLog(String message) async {
    final file = await _localFile;
    final currentTime = DateTime.now();
    final logMessage = '$currentTime: $message\n';
    return file.writeAsString(logMessage, mode: FileMode.append);
  }

  //telegram log
  Future<void> sendTelegramLog(String message, String threshold) async {
    String userAgent = '';
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;

    await WindowsSystemInfo.initWindowsInfo(
        requiredValues: [WindowsSystemInfoFeat.cpu]);
    if (await WindowsSystemInfo.isInitilized) {
      userAgent =
         '(Flutter) V.${VersionApp.version} ${windowsInfo.computerName} (${windowsInfo.productName} ${windowsInfo.displayVersion})';
    }

    final res = await http.post(
        Uri.parse(
          '${TelegramUrl.liveUrl}/messages/sends',
        ),
        headers: {
          'User-Agent': userAgent,
        },
        body: {
          'username': 'bisa_online_queue_bot',
          'threshold': threshold,
          'message': message,
        }).timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) {
      if (kDebugMode) {
        print('code :${res.statusCode}');
      }
      await writeLog('Failed to send telegram log');
    }
  }
}
