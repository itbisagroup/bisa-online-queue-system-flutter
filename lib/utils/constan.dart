import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppColors {
  static const maroon = Color(0xFF78251E);
  static const grey = Color(0xFFBDBDBD);
  static const red = Color(0xFFF85046);
  static const confirm = Color(0xFF2196F3);
  static const black = Color(0xFF1F1F29);
  static const white = Color(0xFFfdfdfd);
  static const teal = Color(0xFFECF9FC);
  static const lessBrown = Color(0xFFFFF6E9);
  static const blackCalm = Color.fromRGBO(64, 75, 96, .9);
  static const stroke = Color(0xFFE7E7E7);
  static const pink = Color(0xFFfef0ef);
}

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

class TelegramUrl {
  static const String localUrl = 'http://bisa-telegram-bot-ci4.192.168.1.66.nip.io/api/v1';
  static const String liveUrl = 'https://telegrambot.bisagroup.co.id/api/v1';
}

class VersionApp {
  static const String apkName = 'BISA Online Queue System';
  static const String version = '1.5.0';
  static String get copyright => 'BISA Group © ${DateTime.now().year} ${'all_rights_reserved'.tr}';
}

