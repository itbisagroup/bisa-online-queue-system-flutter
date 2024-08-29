import 'package:flutter/material.dart';

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
}

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

class SlackInit {
  static const String url =
      'https://hooks.slack.com/services/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';
}

class MessagesDialogError {
  static const String createQueue = 'Unable to create queue. Please try again';
  static const String printQueue = 'Unable to print queue. Please try again';
  static const String servedQueue =
      'Unable update status served!. Please try again';
  static const String voidQueue =
      'Unable update status void!. Please try again';
  static const String updateQtyQueue =
      'Unable update quantity!. Please try again';
  static const String callQueue =
      'Unable to call or maybe the queue is already canceled';
}

class MessagesDialogSuccess {
  static const String servedQueue = 'Status successfully updated to served';
  static const String voidQueue = 'Status successfully updated to void';
  static const String updateQtyQueue = 'Quantity successfully updated to';
}

class MessagesDialogInfo {
  static const String dialogEndShift =
      "Don't forget to end the shift. Would you like to end it now?";
  static const String printerNotSelectet =
      'Printer is not selected. Please select printer first in setting menu';
}
