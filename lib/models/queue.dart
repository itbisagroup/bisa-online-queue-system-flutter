import 'package:queue_system/models/pax.dart';

class Queue {
  final String? id;
  final String? queueCode;
  final String? queueNumber;
  final String? nextQueue;
  final int? queueQty; // Updated field name
  final int? waitingCount;
  final int? printCount; // New field
  final int? callCount;
  final DateTime? createdDate;

  Queue({
    this.id,
    this.queueCode,
    this.queueNumber,
    this.queueQty,
    this.waitingCount,
    this.printCount,
    this.callCount,
    this.createdDate,
    this.nextQueue,
  });

  factory Queue.fromJson(Map<String, dynamic> json) {
    final String id = json.keys.first;
    final Map<String, dynamic>? queueData = json[id];
    return Queue(
      id: id,
      queueCode: queueData?['queueCode'] ?? "0000",
      queueNumber: queueData?['queueNumber'] ?? "0000",
      queueQty: queueData?['queueQty'] ?? 0,
      waitingCount: queueData?['waitingCount'] ?? 0,
      printCount: queueData?['printCount'] ?? 0,
      nextQueue: queueData?['nextQueue']?['queueNumber'] ?? '0000',
      callCount: queueData?['callCount'] ?? 0,
      createdDate:
          DateTime.parse(queueData?['createdAt']['date'] ?? '0000-00-00'),
    );
  }
}

class Withhold {
  final String? id;
  String? queueNumber;
  String? queueCode;
  int? callCount;
  int? queueQty;

  Withhold({
    this.id,
    this.queueNumber,
    this.queueCode,
    this.callCount,
    this.queueQty,
  });

  // Parse a list of Withhold entries for each Pax ID
  static List<Withhold> listFromJson(Map<String, dynamic> json) {
    final String id = json.keys.first;
    final List<dynamic>? queueDataList = json[id];
    if (queueDataList != null && queueDataList.isNotEmpty) {
      return queueDataList.map((queueData) {
        return Withhold(
          id: id,
          queueNumber: queueData['queueNumber'],
          queueCode: queueData['id'],
          callCount: queueData['callCount'],
          queueQty: queueData['queueQty'],
        );
      }).toList();
    } else {
      return [
        Withhold(
          id: id,
          queueNumber: "0000",
          queueCode: '0',
          callCount: 0,
          queueQty: 0,
        )
      ];
    }
  }
}

class StatusQueue {
  final int? value;
  final String? label;
  final String? icon;
  final String? color;

  StatusQueue({
    this.value,
    this.label,
    this.icon,
    this.color,
  });

  factory StatusQueue.fromJson(Map<String, dynamic> json) {
    return StatusQueue(
      value: json['value'],
      label: json['label'],
      icon: json['icon'],
      color: json['color'],
    );
  }
}

class PaxWithQueue {
  final Pax? pax;
  final Queue? queue;
  final List<Withhold>? withhold;

  PaxWithQueue({
    this.pax,
    this.queue,
    this.withhold,
  });
}
