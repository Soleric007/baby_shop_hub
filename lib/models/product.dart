class Product {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String description;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.description,
    required this.category,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
  return Product(
    id: map['id'],
    name: map['name'],
    imageUrl: map['imageUrl'],
    price: (map['price'] as num).toDouble(), // ✅ convert safely to double
    description: map['description'],
    category: map['category'],
  );
}


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'description': description,
      'category': category,
    };
  }
}
