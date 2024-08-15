import 'package:queue_system/models/status.dart';

class Brand {
  final int? id;
  final String? slug;
  final String? codeName;
  final String? fullName;
  final String? description;
  final String? logo;
  final IsActive? isActive;

  Brand({
    this.id,
    this.slug,
    this.codeName,
    this.fullName,
    this.description,
    this.logo,
    this.isActive,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'],
      slug: json['slug'],
      codeName: json['codeName'],
      fullName: json['fullName'],
      description: json['description'],
      logo: json['logo'],
      isActive: IsActive.fromJson(json['isActive']),
    );
  }
}