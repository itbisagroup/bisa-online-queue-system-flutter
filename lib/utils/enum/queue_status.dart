import 'package:flutter/material.dart';
import 'package:queue_system/utils/constan.dart';

enum QueueStatus {
  waiting,
  calling,
  lastCall,
  served,
  voided,
  cancelled,
  expired,
}
extension QueueStatusExtension on QueueStatus {
  String get label {
    switch (this) {
      case QueueStatus.waiting:
        return 'waiting';
      case QueueStatus.calling:
        return 'calling';
      case QueueStatus.lastCall:
        return 'last_call';
      case QueueStatus.served:
        return 'served';
      case QueueStatus.voided:
        return 'void';
      case QueueStatus.cancelled:
        return 'cancelled';
      case QueueStatus.expired:
        return 'expired';
      default:
        return '';
    }
  }

  IconData get icon {
    switch (this) {
      case QueueStatus.waiting:
        return Icons.person;
      case QueueStatus.calling:
        return Icons.directions_walk;
      case QueueStatus.lastCall:
        return Icons.person_pin_circle;
      case QueueStatus.served:
        return Icons.check_circle;
      case QueueStatus.voided:
        return Icons.remove_circle;
      case QueueStatus.cancelled:
        return Icons.cancel;
      case QueueStatus.expired:
        return Icons.help;
      default:
        return Icons.help;
    }
  }

  Color get color {
    switch (this) {
      case QueueStatus.waiting:
        return const Color(0xFF008080);
      case QueueStatus.calling:
        return const Color(0xFF4B0082);
      case QueueStatus.lastCall:
        return const Color(0xFFFFA500);
      case QueueStatus.served:
        return  AppColors.confirm;
      case QueueStatus.voided:
        return const Color(0xFF8B0000);
      case QueueStatus.cancelled:
        return const Color(0xFFFF0000);
      case QueueStatus.expired:
        return const Color(0xFF6699CC);
      default:
        return Colors.black;
    }
  }
}