// data/Enum/shift_status.dart
import 'package:flutter/material.dart';
import 'package:pickup_queue_system/utills/constans.dart';

enum ShiftStatus {
  opened(0, 'Dibuka'),
  closed(1, 'Ditutup');

  final int value;
  final String description;

  const ShiftStatus(this.value, this.description);

  static ShiftStatus fromValue(int value) {
    return values.firstWhere((e) => e.value == value);
  }

  Color get color {
    switch (this) {
      case ShiftStatus.opened:
        return AppColors.blackCalm;
      case ShiftStatus.closed:
        return AppColors.grey;
   
    }
  }
}
