class Product {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String description; // ✅ Add this line
  final String category; // ✅ Add this line

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.description,
    required this.category // ✅ Also add here
  });
}
