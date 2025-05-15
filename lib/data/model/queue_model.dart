class QueueModel {
  final int? id;
  final String queueNumber;
  final String? description;
  final String? latestCall;
  final int callCount;
  final int status;
  final int shiftId;
  final int isSynch;
  final String createdAt;
  final String updatedAt;

  QueueModel({
    this.id,
    required this.queueNumber,
    this.description,
    this.latestCall,
    this.callCount = 0,
    required this.status,
    required this.shiftId,
    required this.isSynch,
    required this.createdAt,
    required this.updatedAt,
  });

  // Add this copyWith method
  QueueModel copyWith({
    int? id,
    String? queueNumber,
    String? description,
    String? latestCall,
    int? callCount,
    int? status,
    int? shiftId,
    int? isSynch,
    String? createdAt,
    String? updatedAt,
  }) {
    return QueueModel(
      id: id ?? this.id,
      queueNumber: queueNumber ?? this.queueNumber,
      description: description ?? this.description,
      latestCall: latestCall ?? this.latestCall,
      callCount: callCount ?? this.callCount,
      status: status ?? this.status,
      shiftId: shiftId ?? this.shiftId,
      isSynch: isSynch ?? this.isSynch,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory QueueModel.fromMap(Map<String, dynamic> map) {
    return QueueModel(
      id: map['id'],
      queueNumber: map['queue_number'],
      description: map['description'],
      latestCall: map['latest_call'],
      callCount: map['call_count'],
      status: map['status'],
      shiftId: map['shift_id'],
      isSynch: map['is_synch'] ?? 0,
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'queue_number': queueNumber,
      'description': description,
      'latest_call': latestCall,
      'call_count': callCount,
      'status': status,
      'shift_id': shiftId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
