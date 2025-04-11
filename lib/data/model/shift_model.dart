import 'package:pickup_queue_system/data/Enum/shift_status.dart';

class Shift {
  final int? id;
  final String shiftDate;
  final int outletId;
  final ShiftStatus status;
  final String? createdAt;
  final String? updatedAt;

  Shift({
    this.id,
    required this.shiftDate,
    required this.outletId,
    this.status = ShiftStatus.opened,
    this.createdAt,
    this.updatedAt,
  });

  factory Shift.fromMap(Map<String, dynamic> map) => Shift(
        id: map['id'],
        shiftDate: map['shift_date'],
        outletId: map['outlet_id'],
        status: ShiftStatus.fromValue(map['status']),
        createdAt: map['createdAt'],
        updatedAt: map['updatedAt'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'shift_date': shiftDate,
        'outlet_id': outletId,
        'status': status.value,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  Shift copyWith({
    int? id,
    String? shiftDate,
    int? outletId,
    ShiftStatus? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return Shift(
      id: id ?? this.id,
      shiftDate: shiftDate ?? this.shiftDate,
      outletId: outletId ?? this.outletId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
