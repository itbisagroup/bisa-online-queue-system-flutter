// data/model/shift_model.dart
class Shift {
  final int? id;
  final String shiftDate;
  final int outletId;
  final int status;
  final String createdAt;
  final String updatedAt;

  Shift({
    this.id,
    required this.shiftDate,
    required this.outletId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Shift.fromMap(Map<String, dynamic> map) {
    return Shift(
      id: map['id'],
      shiftDate: map['shift_date'],
      outletId: map['outlet_id'],
      status: map['status'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shift_date': shiftDate,
      'outlet_id': outletId,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Shift copyWith({
    int? id,
    String? shiftDate,
    int? outletId,
    int? status,
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