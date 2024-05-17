
import 'package:queue_system/models/queue.dart';

class QueueResponse {
  final bool success;
  final int code;
  final String description;
  final QueueData data;

  QueueResponse({
    required this.success,
    required this.code,
    required this.description,
    required this.data,
  });

  factory QueueResponse.fromJson(Map<String, dynamic> json) {
    return QueueResponse(
      success: json['success'],
      code: json['code'],
      description: json['description'],
      data: QueueData.fromJson(json['data']),
    );
  }
}

class QueueData {
  final List<QueueList> queues;
  final Pages pages;
  final Params params;

  QueueData({
    required this.queues,
    required this.pages,
    required this.params,
  });

  factory QueueData.fromJson(Map<String, dynamic> json) {
    return QueueData(
      queues: (json['queues'] as List)
          .map((queue) => QueueList.fromJson(queue))
          .toList(),
      pages: Pages.fromJson(json['pages']),
      params: Params.fromJson(json['params']),
    );
  }
}

class QueueList {
  final int queueId;
  final String queueNumber;
  final String qrCode;
  final String cancelCode;
  final dynamic latestCall;
  final int callCount;
  final int printCount;

  final Pax pax;
  final StatusQueue status;
  final DateTime createdAt;
  final DateTime updatedAt;

  QueueList({
    required this.queueId,
    required this.queueNumber,
    required this.qrCode,
    required this.cancelCode,
    required this.latestCall,
    required this.callCount,
    required this.printCount,
    required this.pax,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QueueList.fromJson(Map<String, dynamic> json) {
    return QueueList(
      queueId: json['queueId'],
      queueNumber: json['queueNumber'],
      qrCode: json['qrCode'],
      cancelCode: json['cancelCode'],
      latestCall: json['latestCall'],
      callCount: json['callCount'],
      printCount: json['printCount'],

      pax: Pax.fromJson(json['pax']),
      status: StatusQueue.fromJson(json['status']),
      createdAt: DateTime.parse(json['createdAt']['date']),
      updatedAt: DateTime.parse(json['updatedAt']['date']),
    );
  }
}






class Pages {
  final int showData;
  final int totalData;
  final int currentPage;
  final bool firstPage;
  final bool lastPage;
  final int totalPages;

  Pages({
    required this.showData,
    required this.totalData,
    required this.currentPage,
    required this.firstPage,
    required this.lastPage,
    required this.totalPages,
  });

  factory Pages.fromJson(Map<String, dynamic> json) {
    return Pages(
      showData: json['showData'],
      totalData: json['totalData'],
      currentPage: json['currentPage'],
      firstPage: json['firstPage'],
      lastPage: json['lastPage'],
      totalPages: json['totalPages'],
    );
  }
}

class Params {
  final String search;
  final List<dynamic> pax;
  final List<dynamic> status;
  final int page;
  final int limit;

  Params({
    required this.search,
    required this.pax,
    required this.status,
    required this.page,
    required this.limit,
  });

  factory Params.fromJson(Map<String, dynamic> json) {
    return Params(
      search: json['search'],
      pax: json['pax'],
      status: json['status'],
      page: json['page'],
      limit: json['limit'],
    );
  }
}
