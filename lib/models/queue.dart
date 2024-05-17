class Queue {
  final String? uuid;

   String? queueNumber;
   int? queueId;
   int? waitingCount;
   int? callCount;

  Queue({
    this.uuid,
    this.queueNumber,
    this.queueId,
    this.waitingCount,
    this.callCount,
  });

  factory Queue.fromJson(Map<String, dynamic> json) {
    final String uuid = json.keys.first;
    final Map<String, dynamic>? queueData = json[uuid];
    final String? queueNumber = queueData?['queueNumber'] ?? "0000";
    final int? queueId = queueData?['queueId'] ?? 0;
    final int? waitingCount = queueData?['waitingCount'] ?? 0;
    final int? callCount = queueData?['callCount'] ?? 0;

    return Queue(
      uuid: uuid,
      queueNumber: queueNumber,
      queueId: queueId,
      waitingCount: waitingCount,
      callCount: callCount,
    );
  }
}

class PaxWithQueue {
  final Pax? pax;
  final Queue? queue;

  PaxWithQueue({
    this.pax,
    this.queue,
  });


}

class Pax {
  final String? uuid;
  final String? notation;
  final String? variety;
  final String? description;

  Pax({
    this.uuid,
    this.notation,
    this.variety,
    this.description,
  });

  factory Pax.fromJson(Map<String, dynamic> json) {
    return Pax(
      uuid: json['uuid'],
      notation: json['notation'],
      variety: json['variety'],
      description: json['description'],
    );
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

class Branch {
  final int? id;
  final String? slug;
  final String? codeName;
  final String? fullName;
  final String? address;
  final String? city;
  final String? province;
  final String? country;
  final String? emailAddress;
  final int? queueCount;
  final int? callCount;
  final int? callRepeat;
  final int? callDelay;
  final bool? playAds;
  final Brand? brand;
  final IsActive? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic deletedAt;
  final List<Pax>? pax;
  final List<Ads>? ads;

  Branch({
    this.id,
    this.slug,
    this.codeName,
    this.fullName,
    this.address,
    this.city,
    this.province,
    this.country,
    this.emailAddress,
    this.queueCount,
    this.callCount,
    this.callRepeat,
    this.callDelay,
    this.playAds,
    this.brand,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.pax,
    this.ads,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['data']['branch']['id'],
      slug: json['data']['branch']['slug'],
      codeName: json['data']['branch']['codeName'],
      fullName: json['data']['branch']['fullName'],
      address: json['data']['branch']['address'],
      city: json['data']['branch']['city'],
      province: json['data']['branch']['province'],
      country: json['data']['branch']['country'],
      emailAddress: json['data']['branch']['emailAddress'],
      queueCount: json['data']['branch']['queueCount'],
      callCount: json['data']['branch']['callCount'],
      callRepeat: json['data']['branch']['callRepeat'],
      callDelay: json['data']['branch']['callDelay'],
      playAds: json['data']['branch']['playAds'],
      brand: Brand.fromJson(json['data']['branch']['brand']),
      isActive: IsActive.fromJson(json['data']['branch']['isActive']),
      createdAt: DateTime.parse(json['data']['branch']['createdAt']['date']),
      updatedAt: DateTime.parse(json['data']['branch']['updatedAt']['date']),
      deletedAt: json['data']['branch']['deletedAt'],
      pax: (json['data']['pax'] as List<dynamic>?)
          ?.map((e) => Pax.fromJson(e))
          .toList(),
      ads: (json['data']['ads'] as List<dynamic>?)
          ?.map((e) => Ads.fromJson(e))
          .toList(),
    );
  }
}

class Brand {
  final int? id;
  final String? slug;
  final String? codeName;
  final String? fullName;
  final String? logo;
  final IsActive? isActive;

  Brand({
    this.id,
    this.slug,
    this.codeName,
    this.logo,
    this.fullName,
    this.isActive,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'],
      slug: json['slug'],
      codeName: json['codeName'],
      fullName: json['fullName'],
      logo: json['logo'],
      isActive: IsActive.fromJson(json['isActive']),
    );
  }
}

class IsActive {
  final int? value;
  final String? label;
  final String? icon;
  final String? color;

  IsActive({
    this.value,
    this.label,
    this.icon,
    this.color,
  });

  factory IsActive.fromJson(Map<String, dynamic> json) {
    return IsActive(
      value: json['value'],
      label: json['label'],
      icon: json['icon'],
      color: json['color'],
    );
  }
}

class Ads {
  final String? sequence;
  final String? uuid;
  final String? title;
  final String? description;
  final String? content;

  Ads({
    this.sequence,
    this.uuid,
    this.title,
    this.description,
    this.content,
  });

  factory Ads.fromJson(Map<String, dynamic> json) {
    return Ads(
      sequence: json['sequence'],
      uuid: json['uuid'],
      title: json['title'],
      description: json['description'],
      content: json['content'],
    );
  }
}
