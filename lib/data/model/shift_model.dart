// data/model/shift_model.dart
class Shift {
  final int? id;
  final String shiftDate;
  final String shiftEndDate;
  final int outletId;
  final int status;
  final int isSynch;
  final String createdAt;
  final String updatedAt;

  Shift({
    this.id,
    required this.shiftDate,
    required this.shiftEndDate,
    required this.outletId,
    required this.status,
    required this.isSynch,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Shift.fromMap(Map<String, dynamic> map) {
    return Shift(
      id: map['id'],
      shiftDate: map['shift_date'],
      shiftEndDate: map['shift_end_date'],
      outletId: map['outlet_id'],
      status: map['status'],
      isSynch: map['is_synch'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shift_date': shiftDate,
      'shift_end_date': shiftEndDate,
      'outlet_id': outletId,
      'status': status,
      'is_synch': isSynch,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Shift copyWith({
    int? id,
    String? shiftDate,
    String? shiftEndDate,
    int? outletId,
    int? status,
    int? isSynch,
    String? createdAt,
    String? updatedAt,
  }) {
    return Shift(
      id: id ?? this.id,
      shiftDate: shiftDate ?? this.shiftDate,
      shiftEndDate: shiftEndDate ?? this.shiftEndDate,
      outletId: outletId ?? this.outletId,
      status: status ?? this.status,
      isSynch: isSynch ?? this.isSynch,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
