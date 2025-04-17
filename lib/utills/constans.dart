import 'package:flutter/material.dart';


class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

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

String timeAgo(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inSeconds < 60) {
    return 'baru saja';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} menit yang lalu';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} jam yang lalu';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} hari yang lalu';
  } else if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return '$weeks minggu yang lalu';
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return '$months bulan yang lalu';
  } else {
    final years = (difference.inDays / 365).floor();
    return '$years tahun yang lalu';
  }
}