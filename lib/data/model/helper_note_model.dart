class HelperNote {
  int? id;
  String name;
  String? createdAt;
  String? updatedAt;

  HelperNote({
    this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory HelperNote.fromMap(Map<String, dynamic> map) {
    return HelperNote(
      id: map['id'],
      name: map['name'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }
}