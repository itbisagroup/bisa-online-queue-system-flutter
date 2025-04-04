class ShiftDetails {
  final QueueCount? queues;
  final List<ShiftStatus>? status;

  ShiftDetails({this.queues, this.status});

  factory ShiftDetails.fromJson(Map<String, dynamic> json) {
    return ShiftDetails(
      queues: json['queues'] != null ? QueueCount.fromJson(json['queues']) : null,
      status: json['status'] != null
          ? List<ShiftStatus>.from(json['status'].map((x) => ShiftStatus.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'queues': queues?.toJson(),
      'status': status != null ? List<dynamic>.from(status!.map((x) => x.toJson())) : null,
    };
  }
}

class QueueCount {
  final int? count;
  final int? total;

  QueueCount({this.count, this.total});

  factory QueueCount.fromJson(Map<String, dynamic> json) {
    return QueueCount(
      count: json['count'],
      total: json['total'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'total': total,
    };
  }
}

class ShiftStatus {
  final int? count;
  final String? label;
  final int? total;
  final int? value;

  ShiftStatus({this.count, this.label, this.total, this.value});

  factory ShiftStatus.fromJson(Map<String, dynamic> json) {
    return ShiftStatus(
      count: json['count'],
      label: json['label'],
      total: json['total'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'label': label,
      'total': total,
      'value': value,
    };
  }
}
