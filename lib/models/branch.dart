import 'package:queue_system/models/ads.dart';
import 'package:queue_system/models/brand.dart';
import 'package:queue_system/models/pax.dart';
import 'package:queue_system/models/status.dart';

class Branch {
  final int? id;
  final String? slug;
  final String? codeName;
  final String? fullName;
  final String? address;
  final String? subdistrict; // New field
  final String? district;    // New field
  final String? city;
  final String? postalCode;  // New field
  final String? province;
  final String? country;
  final String? phoneNumber; // New field
  final String? faxNumber;   // New field
  final String? emailAddress;
  final String? description; // New field
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
  final DateTime? syncedAt;  // New field
  final List<Pax>? pax;
  final List<Ads>? ads;

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
    this.brand,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.syncedAt,
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
      subdistrict: json['data']['branch']['subdistrict'],
      district: json['data']['branch']['district'],
      city: json['data']['branch']['city'],
      postalCode: json['data']['branch']['postalCode'],
      province: json['data']['branch']['province'],
      country: json['data']['branch']['country'],
      phoneNumber: json['data']['branch']['phoneNumber'],
      faxNumber: json['data']['branch']['faxNumber'],
      emailAddress: json['data']['branch']['emailAddress'],
      description: json['data']['branch']['description'],
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
      syncedAt: DateTime.parse(json['data']['branch']['syncedAt']['date']),
      pax: (json['data']['pax'] as List<dynamic>?)
          ?.map((e) => Pax.fromJson(e))
          .toList(),
      ads: (json['data']['ads'] as List<dynamic>?)
          ?.map((e) => Ads.fromJson(e))
          .toList(),
    );
  }
}







