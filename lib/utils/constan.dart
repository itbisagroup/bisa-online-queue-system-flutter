import 'package:flutter/material.dart';

class AppColors {
  static const maroon = Color(0xFF78251E);
  static const grey = Color(0xFFBDBDBD);
  static const red = Color(0xFFF85046);
  static const confirm = Color(0xFF2196F3);
  static const black =  Color(0xFF1F1F29);
  static const white = Color(0xFFfdfdfd);
  static const teal = Color(0xFFECF9FC);
  static const lessBrown = Color(0xFFFFF6E9);
  static const blackCalm = Color.fromRGBO(64, 75, 96, .9);
  static const stroke = Color(0xFFE7E7E7);
}

class NavigationService { 
  static GlobalKey<NavigatorState> navigatorKey = 
  GlobalKey<NavigatorState>();
}
class SlackInit { 
  static const String url = 'https://hooks.slack.com/services/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';
}

