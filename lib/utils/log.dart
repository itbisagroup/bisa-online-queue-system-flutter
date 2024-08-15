import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:slack_logger/slack_logger.dart';

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

  Future<void> sendSlackLog(String branch, String message) async {
    final SlackLogger slack = SlackLogger.instance;
    slack.send(
      '$branch : $message',
    );
  }
}
