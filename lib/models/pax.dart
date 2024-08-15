class Pax {
  final String? id;
  final String? notation;
  final String? variety;
  final int? minQty;
  final int? maxQty;
  final String? description;

  Pax({
    this.id,
    this.notation,
    this.variety,
    this.minQty,
    this.maxQty,
    this.description,
  });

  factory Pax.fromJson(Map<String, dynamic> json) {
    return Pax(
      id: json['id'],
      notation: json['notation'],
      variety: json['variety'],
      minQty: json['minQty'],
      maxQty: json['maxQty'],
      description: json['description'],
    );
  }
}
