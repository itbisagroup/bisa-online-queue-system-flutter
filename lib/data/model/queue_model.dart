import 'package:pickup_queue_system/data/Enum/queue_status.dart';

class QueueModel {
  final int? id;
  final String queueNumber;
  final String? latestCall;
  final int callCount;
  final QueueStatus status;
  final int shiftId;

  QueueModel({
    this.id,
    required this.queueNumber,
    this.latestCall,
    this.callCount = 0,
    required this.status,
    required this.shiftId,
  });

  factory QueueModel.fromMap(Map<String, dynamic> map) {
    return QueueModel(
      id: map['id'],
      queueNumber: map['queue_number'],
      latestCall: map['latest_call'],
      callCount: map['call_count'],
      status: QueueStatus.fromValue(map['status']),
      shiftId: map['shift_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'queue_number': queueNumber,
      'latest_call': latestCall,
      'call_count': callCount,
      'status': status.value,
      'shift_id': shiftId,
    };
  }

  // Tambahkan method ini ⬇️
  QueueModel copyWith({
    int? id,
    String? queueNumber,
    String? latestCall,
    int? callCount,
    QueueStatus? status,
    int? shiftId,
  }) {
    return QueueModel(
        id: id ?? this.id,
        queueNumber: queueNumber ?? this.queueNumber,
        latestCall: latestCall ?? this.latestCall,
        callCount: callCount ?? this.callCount,
        status: status ?? this.status,
        shiftId: shiftId ?? this.shiftId);
  }
}
