// data/model/outlet_model.dart
class Outlet {
  final int? id;
  final String? codeName;
  final String fullName;
  final String logo;
  final String? address;
  final String? phoneNumber;
  final String? subdistrict;
  final String? district;
  final String? city;
  final String? postalCode;
  final String? province;
  final String? country;
  final String? faxNumber;
  final String? emailAddress;
  final String? description;
  final String? createdAt;
  final String? updatedAt;

  Outlet({
    this.id,
    this.codeName,
    required this.fullName,
    required this.logo,
    this.address,
    this.phoneNumber,
    this.subdistrict,
    this.district,
    this.city,
    this.postalCode,
    this.province,
    this.country,
    this.faxNumber,
    this.emailAddress,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code_name': codeName,
      'full_name': fullName,
      'logo': logo,
      'address': address,
      'phone_number': phoneNumber,
      'subdistrict': subdistrict,
      'district': district,
      'city': city,
      'postal_code': postalCode,
      'province': province,
      'country': country,
      'fax_number': faxNumber,
      'email_address': emailAddress,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Outlet.fromMap(Map<String, dynamic> map) {
    return Outlet(
      id: map['id'],
      codeName: map['code_name'],
      fullName: map['full_name'],
      logo: map['logo'],
      address: map['address'],
      phoneNumber: map['phone_number'],
      subdistrict: map['subdistrict'],
      district: map['district'],
      city: map['city'],
      postalCode: map['postal_code'],
      province: map['province'],
      country: map['country'],
      faxNumber: map['fax_number'],
      emailAddress: map['email_address'],
      description: map['description'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }
  Outlet copyWith({
    int? id,
    String? codeName,
    String? fullName,
    String? logo,
    String? address,
    String? phoneNumber,
    String? subdistrict,
    String? district,
    String? city,
    String? postalCode,
    String? province,
    String? country,
    String? faxNumber,
    String? emailAddress,
    String? description,
    String? createdAt,
    String? updatedAt,
  }) {
    return Outlet(
      id: id ?? this.id,
      codeName: codeName ?? this.codeName,
      fullName: fullName ?? this.fullName,
      logo: logo ?? this.logo,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      subdistrict: subdistrict ?? this.subdistrict,
      district: district ?? this.district,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      province: province ?? this.province,
      country: country ?? this.country,
      faxNumber: faxNumber ?? this.faxNumber,
      emailAddress: emailAddress ?? this.emailAddress,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
