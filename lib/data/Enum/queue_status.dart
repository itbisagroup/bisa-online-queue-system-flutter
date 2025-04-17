import 'package:flutter/material.dart';

enum QueueStatus {
  waiting(1, 'Menunggu'),
  calling(2, 'Memanggil'),
  completed(3, 'Selesai'),
  none(4, 'Tidak Diketahui');

  final int value;
  final String description;

  const QueueStatus(this.value, this.description);

  static QueueStatus fromValue(int value) {
    return values.firstWhere((e) => e.value == value, orElse: () => QueueStatus.none);
  }

  IconData get icon {
    switch (this) {
      case QueueStatus.waiting:
        return Icons.hourglass_empty;
      case QueueStatus.calling:
        return Icons.campaign;
      case QueueStatus.completed:
        return Icons.check_circle;
      case QueueStatus.none:
        return Icons.remove_circle_outline;
    }
  }

  Color get color {
    switch (this) {
      case QueueStatus.waiting:
        return Colors.grey;
      case QueueStatus.calling:
        return Colors.orange;
      case QueueStatus.completed:
        return Colors.blue;
      case QueueStatus.none:
        return Colors.red;
    }
  }
}
