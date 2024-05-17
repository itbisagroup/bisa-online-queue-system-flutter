class QueueData {
  final int? queueId;
  final String? queueNumber;
  final String? qrCode;
  final String? cancelCode;
  final BrandNew? brand;
  final BranchNew? branch;
  final PaxNew? pax;
  final StatusNew? status;
  final CreatedAtNew? createdAt;
  final UpdatedAtNew? updatedAt;

  QueueData({
    this.queueId,
    this.queueNumber,
    this.qrCode,
    this.cancelCode,
    this.brand,
    this.branch,
    this.pax,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory QueueData.fromJson(Map<String, dynamic> json) {
    return QueueData(
      queueId: json['queueId'] ?? '',
      queueNumber: json['queueNumber'] ?? '',
      qrCode: json['qrCode'] ?? '',
      cancelCode: json['cancelCode'] ?? '',
      brand: BrandNew.fromJson(json['brand'] ?? ''),
      branch: BranchNew.fromJson(json['branch'] ?? ''),
      pax: PaxNew.fromJson(json['pax'] ?? ''),
      status: StatusNew.fromJson(json['status'] ?? ''),
      createdAt: CreatedAtNew.fromJson(json['createdAt'] ?? ''),
      updatedAt: UpdatedAtNew.fromJson(json['updatedAt'] ?? ''),
    );
  }
}

class BrandNew {
  final String? codeName;
  final String? fullName;

  BrandNew({
    this.codeName,
    this.fullName,
  });

  factory BrandNew.fromJson(Map<String, dynamic> json) {
    return BrandNew(
      codeName: json['codeName'],
      fullName: json['fullName'],
    );
  }
}

class BranchNew {
  final String? codeName;
  final String? fullname;
  final String? address;
  final String? subdistrict;
  final String? district;
  final String? city;
  final String? postalCode;
  final String? province;
  final String? country;

  BranchNew({
    this.codeName,
    this.fullname,
    this.address,
    this.subdistrict,
    this.district,
    this.city,
    this.postalCode,
    this.province,
    this.country,
  });

  factory BranchNew.fromJson(Map<String, dynamic> json) {
    return BranchNew(
      codeName: json['codeName'] ?? '',
      fullname: json['fullname'] ?? '',
      address: json['address'] ?? '',
      subdistrict: json['subdistrict'] ?? '',
      district: json['district'] ?? '',
      city: json['city'] ?? '',
      postalCode: json['postalCode'] ?? '',
      province: json['province'] ?? '',
      country: json['country'] ?? '',
    );
  }
}

class PaxNew {
  final String? uuid;
  final String? notation;
  final String? variety;
  final String? description;
  final IsActiveNew? isActive;

  PaxNew({
    this.uuid,
    this.notation,
    this.variety,
    this.description,
    this.isActive,
  });

  factory PaxNew.fromJson(Map<String, dynamic> json) {
    return PaxNew(
      uuid: json['uuid'] ?? '',
      notation: json['notation'] ?? '',
      variety: json['variety'] ?? '',
      description: json['description'] ?? '',
      isActive: IsActiveNew.fromJson(json['isActive'] ?? ''),
    );
  }
}

class IsActiveNew {
  final int? value;
  final String? label;
  final String? icon;
  final String? color;

  IsActiveNew({
    this.value,
    this.label,
    this.icon,
    this.color,
  });

  factory IsActiveNew.fromJson(Map<String, dynamic> json) {
    return IsActiveNew(
      value: json['value'] ?? '',
      label: json['label'] ?? '',
      icon: json['icon'] ?? '',
      color: json['color'] ?? '',
    );
  }
}

class StatusNew {
  final int? value;
  final String? label;
  final String? icon;
  final String? color;

  StatusNew({
    this.value,
    this.label,
    this.icon,
    this.color,
  });

  factory StatusNew.fromJson(Map<String, dynamic> json) {
    return StatusNew(
      value: json['value'] ?? '',
      label: json['label'] ?? '',
      icon: json['icon'] ?? '',
      color: json['color'] ?? '',
    );
  }
}

class CreatedAtNew {
  final String? date;
  final int? timezoneType;
  final String? timezone;

  CreatedAtNew({
    this.date,
    this.timezoneType,
    this.timezone,
  });

  factory CreatedAtNew.fromJson(Map<String, dynamic> json) {
    return CreatedAtNew(
      date: json['date'] ?? '',
      timezoneType: json['timezone_type'] ?? '',
      timezone: json['timezone'] ?? '',
    );
  }
}

class UpdatedAtNew {
  final String? date;
  final int? timezoneType;
  final String? timezone;

  UpdatedAtNew({
    this.date,
    this.timezoneType,
    this.timezone,
  });

  factory UpdatedAtNew.fromJson(Map<String, dynamic> json) {
    return UpdatedAtNew(
      date: json['date'] ?? '',
      timezoneType: json['timezone_type'] ?? '',
      timezone: json['timezone'] ?? '',
    );
  }
}
