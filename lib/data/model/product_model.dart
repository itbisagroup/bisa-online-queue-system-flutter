class Product {
  int? id;
  String title;
  String? description;
  double? price;
  String? createdAt;

  Product({
    this.id,
    required this.title,
    this.description,
    this.price,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'createdAt': createdAt,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      price: map['price'],
      createdAt: map['createdAt'],
    );
  }
}