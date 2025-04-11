class Outlet {
  final int? id;
  final String? codeName;
  final String fullName;
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
  final String? description;
  final String? createdAt;
  final String? updatedAt;

  Outlet({
    this.id,
    this.codeName,
    required this.fullName,
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
    this.createdAt,
    this.updatedAt,
  });

  factory Outlet.fromMap(Map<String, dynamic> map) => Outlet(
        id: map['id'],
        codeName: map['code_name'],
        fullName: map['full_name'],
        address: map['address'],
        subdistrict: map['subdistrict'],
        district: map['district'],
        city: map['city'],
        postalCode: map['postal_code'],
        province: map['province'],
        country: map['country'],
        phoneNumber: map['phone_number'],
        faxNumber: map['fax_number'],
        emailAddress: map['email_address'],
        description: map['description'],
        createdAt: map['createdAt'],
        updatedAt: map['updatedAt'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'code_name': codeName,
        'full_name': fullName,
        'address': address,
        'subdistrict': subdistrict,
        'district': district,
        'city': city,
        'postal_code': postalCode,
        'province': province,
        'country': country,
        'phone_number': phoneNumber,
        'fax_number': faxNumber,
        'email_address': emailAddress,
        'description': description,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}
