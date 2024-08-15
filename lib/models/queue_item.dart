import 'package:queue_system/models/pax.dart';
import 'package:queue_system/models/queue.dart';





class QueueList {
  final String queueCode;
  final int queueQty;
  final String queueNumber;
  final String cancelCode;
  final String latestCall;
  final String createdAt;
  final int callCount;
  final int printCount;
  final Pax pax;
  final StatusQueue status;

  QueueList({
    required this.queueCode,
    required this.queueQty,
    required this.queueNumber,
    required this.cancelCode,
    required this.latestCall,
    required this.createdAt,
    required this.callCount,
    required this.printCount,
    required this.pax,
    required this.status,
  });

  factory QueueList.fromJson(Map<String, dynamic> json) {
    return QueueList(
      queueCode: json['queueCode'],
      queueQty: json['queueQty'],
      queueNumber: json['queueNumber'],
      cancelCode: json['cancelCode'],
      latestCall:json['latestCall'] != null ? json['latestCall']['date'] : '',
      createdAt:json['createdAt'] != null ? json['createdAt']['date'] : '',
      callCount: json['callCount'],
      printCount: json['printCount'],
      pax: Pax.fromJson(json['pax']),
      status: StatusQueue.fromJson(json['status']),
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
