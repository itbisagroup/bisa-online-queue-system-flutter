class Shift {
  final String? id;
  final ShiftDate? shiftDate;
  final Branch? branch;
  final StatusShift? status;
  final ShiftStartedAt? startedAt;
  final String? endedAt;
  final int? countQueueData;

  Shift({
    this.id,
    this.shiftDate,
    this.countQueueData,
    this.branch,
    this.status,
    this.startedAt,
    this.endedAt,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'],
      shiftDate: ShiftDate.fromJson(json['shiftDate']),
      branch: Branch.fromJson(json['branch']),
      status: StatusShift.fromJson(json['status']),
      startedAt: ShiftStartedAt.fromJson(json['startedAt']),
      endedAt: json['endedAt'] != null ? json['endedAt']['date'] : '',
      countQueueData: json['countQueueData'],
    );
  }
}

class Branch {
  final int? id;
  final String? slug;
  final String? codeName;
  final String? fullName;
  final String? address;
  final String? subdistrict;
  final String? district;
  final String? city;
  final String? postalCode;
  final String? province;
  final String? country;
  final String? phoneNumber;
  final String? faxNumber;
  final String? emailAddress;
  final String? logoUrl;
  final String? description;
  final int? queueCount;
  final int? callCount;
  final int? callRepeat;
  final int? callDelay;
  final bool? playAds;
  final IsActive? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic deletedAt;
  final DateTime? syncedAt;

  Branch({
    this.id,
    this.slug,
    this.codeName,
    this.fullName,
    this.address,
    this.subdistrict,
    this.district,
    this.city,
    this.postalCode,
    this.province,
    this.country,
    this.phoneNumber,
    this.faxNumber,
    this.emailAddress,
    this.description,
    this.queueCount,
    this.callCount,
    this.callRepeat,
    this.callDelay,
    this.playAds,
    this.logoUrl,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.syncedAt,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'],
      slug: json['slug'],
      codeName: json['codeName'],
      fullName: json['fullName'],
      address: json['address'],
      subdistrict: json['subdistrict'],
      district: json['district'],
      city: json['city'],
      postalCode: json['postalCode'],
      province: json['province'],
      country: json['country'],
      description: json['description'],
      queueCount: json['queueCount'],
      logoUrl: json['brand']['logo'],
      callCount: json['callCount'],
      callRepeat: json['callRepeat'],
      callDelay: json['callDelay'],
      playAds: json['playAds'],
      isActive: IsActive.fromJson(json['isActive']),
    );
  }
}

class ShiftDate {
  final String date;
  final int timezoneType;
  final String timezone;

  ShiftDate({
    required this.date,
    required this.timezoneType,
    required this.timezone,
  });

  factory ShiftDate.fromJson(Map<String, dynamic> json) {
    return ShiftDate(
      date: json['date'],
      timezoneType: json['timezone_type'],
      timezone: json['timezone'],
    );
  }
}

class QueueData {
  final Pax pax;
  final StatusShift status;
  final int queueQty;

  final int callCount;
  final DateTime createdAt;
  final String queueCode;
  final DateTime updatedAt;
  final String cancelCode;
  final DateTime? latestCall;
  final int printCount;
  final String queueNumber;

  QueueData({
    required this.pax,
    required this.status,
    required this.queueQty,
    required this.callCount,
    required this.createdAt,
    required this.queueCode,
    required this.updatedAt,
    required this.cancelCode,
    this.latestCall,
    required this.printCount,
    required this.queueNumber,
  });

  factory QueueData.fromJson(Map<String, dynamic> json) {
    return QueueData(
      pax: Pax.fromJson(json['pax']),
      status: StatusShift.fromJson(json['status']),
      queueQty: json['queueQty'],
      callCount: json['callCount'],
      createdAt: DateTime.parse(json['createdAt']['date']),
      queueCode: json['queueCode'],
      updatedAt: DateTime.parse(json['updatedAt']['date']),
      cancelCode: json['cancelCode'],
      latestCall: json['latestCall'] != null
          ? DateTime.parse(json['latestCall']['date'])
          : null,
      printCount: json['printCount'],
      queueNumber: json['queueNumber'],
    );
  }
}

class Pax {
  final String id;
  final int maxQty;
  final int minQty;
  final String variety;
  final IsActive isActive;
  final String notation;
  final String description;

  Pax({
    required this.id,
    required this.maxQty,
    required this.minQty,
    required this.variety,
    required this.isActive,
    required this.notation,
    required this.description,
  });

  factory Pax.fromJson(Map<String, dynamic> json) {
    return Pax(
      id: json['id'],
      maxQty: json['maxQty'],
      minQty: json['minQty'],
      variety: json['variety'],
      isActive: IsActive.fromJson(json['isActive']),
      notation: json['notation'],
      description: json['description'],
    );
  }
}

class IsActive {
  final String icon;
  final String color;
  final String label;
  final int value;

  IsActive({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  factory IsActive.fromJson(Map<String, dynamic> json) {
    return IsActive(
      icon: json['icon'],
      color: json['color'],
      label: json['label'],
      value: json['value'],
    );
  }
}

class StatusShift {
  final String icon;
  final String color;
  final String label;
  final int value;

  StatusShift({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  factory StatusShift.fromJson(Map<String, dynamic> json) {
    return StatusShift(
      icon: json['icon'],
      color: json['color'],
      label: json['label'],
      value: json['value'],
    );
  }
}

class ShiftData {
  final Recaps recaps;

  ShiftData({
    required this.recaps,
  });

  factory ShiftData.fromJson(Map<String, dynamic> json) {
    return ShiftData(
      recaps: Recaps.fromJson(json['recaps']),
    );
  }
}

class Groups {
  final Map<String, List<QueueData>> pax;
  final Map<String, List<QueueData>> status;
  final Map<String, Map<String, List<QueueData>>> paxStatus;

  Groups({
    required this.pax,
    required this.status,
    required this.paxStatus,
  });

  factory Groups.fromJson(Map<String, dynamic> json) {
    Map<String, List<QueueData>> parseQueueDataList(Map<String, dynamic> map) {
      return map.map((key, value) => MapEntry(key,
          (value as List).map((item) => QueueData.fromJson(item)).toList()));
    }

    return Groups(
      pax: parseQueueDataList(json['pax']),
      status: parseQueueDataList(json['status']),
      paxStatus: (json['paxStatus'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          (value as Map<String, dynamic>).map(
            (key2, value2) => MapEntry(
              key2,
              (value2 as List).map((item) => QueueData.fromJson(item)).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class Recaps {
  final List<RecapStatus> status;
  final int records;

  Recaps({
    required this.status,
    required this.records,
  });

  factory Recaps.fromJson(Map<String, dynamic> json) {
    return Recaps(
      status: (json['status'] as List)
          .map((item) => RecapStatus.fromJson(item))
          .toList(),
      records: json['records'],
    );
  }
}

class RecapStatus {
  final int count;
  final String label;
  final int value;

  RecapStatus({
    required this.count,
    required this.label,
    required this.value,
  });

  factory RecapStatus.fromJson(Map<String, dynamic> json) {
    return RecapStatus(
      count: json['count'],
      label: json['label'],
      value: json['value'],
    );
  }
}

class ShiftStartedAt {
  final String date;
  final int timezoneType;
  final String timezone;

  ShiftStartedAt({
    required this.date,
    required this.timezoneType,
    required this.timezone,
  });

  factory ShiftStartedAt.fromJson(Map<String, dynamic> json) {
    return ShiftStartedAt(
      date: json['date'],
      timezoneType: json['timezone_type'],
      timezone: json['timezone'],
    );
  }
}

class ShiftEndedAt {
  final String? date;
  final int? timezoneType;
  final String? timezone;

  ShiftEndedAt({
    this.date,
    this.timezoneType,
    this.timezone,
  });

  factory ShiftEndedAt.fromJson(Map<String, dynamic> json) {
    return ShiftEndedAt(
      date: json['date'],
      timezoneType: json['timezone_type'],
      timezone: json['timezone'],
    );
  }
}

class ShiftUpdatedAt {
  final String date;
  final int timezoneType;
  final String timezone;

  ShiftUpdatedAt({
    required this.date,
    required this.timezoneType,
    required this.timezone,
  });

  factory ShiftUpdatedAt.fromJson(Map<String, dynamic> json) {
    return ShiftUpdatedAt(
      date: json['date'],
      timezoneType: json['timezone_type'],
      timezone: json['timezone'],
    );
  }
}

class PageInfo {
  final int currentPage;
  final int totalItems;
  final int totalPages;
  final int itemsPerPage;
  final int count;

  PageInfo({
    required this.currentPage,
    required this.totalItems,
    required this.totalPages,
    required this.itemsPerPage,
    required this.count,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    return PageInfo(
      currentPage: json['currentPage'],
      totalItems: json['totalItems'],
      totalPages: json['totalPages'],
      itemsPerPage: json['itemsPerPage'],
      count: json['count'],
    );
  }
}

class Params {
  final String branchId;
  final String date;

  Params({
    required this.branchId,
    required this.date,
  });

  factory Params.fromJson(Map<String, dynamic> json) {
    return Params(
      branchId: json['branch_id'],
      date: json['date'],
    );
  }
}

class DetailShift {
  final String? id;

  final ShiftDate? shiftDate;

  final Branch? branch;
  final List<QueueData>? queue;
  final StatusShift? status;
  final ShiftStartedAt? startedAt;
  final String? endedAt;

  DetailShift({
    this.id,
    this.shiftDate,
        this.branch,
    this.queue,

    this.status,
    this.startedAt,
    this.endedAt,
  });

  factory DetailShift.fromJson(Map<String, dynamic> json) {
    return DetailShift(
      id: json['id'],
      shiftDate: ShiftDate.fromJson(json['shiftDate']),
      branch: Branch.fromJson(json['branch']),
      queue: json['queueData'] != null
          ? (json['queueData'] as List)
              .map((item) => QueueData.fromJson(item))
              .toList()
          : null,
      status: StatusShift.fromJson(json['status']),
      startedAt: ShiftStartedAt.fromJson(json['startedAt']),
      endedAt: json['endedAt'] != null ? json['endedAt']['date'] : '',
    );
  }
}
