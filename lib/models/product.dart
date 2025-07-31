class Product {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String description;
  final String category;
  final String brand;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final List<String> tags;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.description,
    required this.category,
    required this.brand,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.inStock = true,
    this.tags = const [],
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      brand: map['brand'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (map['reviewCount'] as int?) ?? 0,
      inStock: map['inStock'] as bool? ?? true,
      tags: List<String>.from(map['tags'] ?? []),
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
      'brand': brand,
      'rating': rating,
      'reviewCount': reviewCount,
      'inStock': inStock,
      'tags': tags,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  // Helper methods
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
  
  String get stockStatus => inStock ? 'In Stock' : 'Out of Stock';
  
  String get ratingText => rating > 0 ? '${rating.toStringAsFixed(1)} ⭐' : 'No rating';
  
  String get reviewText {
    if (reviewCount == 0) return 'No reviews';
    if (reviewCount == 1) return '1 review';
    return '$reviewCount reviews';
  }

  bool matchesSearch(String query) {
    if (query.isEmpty) return true;
    
    final searchLower = query.toLowerCase();
    return name.toLowerCase().contains(searchLower) ||
           brand.toLowerCase().contains(searchLower) ||
           category.toLowerCase().contains(searchLower) ||
           description.toLowerCase().contains(searchLower) ||
           tags.any((tag) => tag.toLowerCase().contains(searchLower));
  }

  bool matchesFilters({
    String? selectedCategory,
    String? selectedBrand,
    double? minPrice,
    double? maxPrice,
    bool? inStockOnly,
    double? minRating,
  }) {
    // Category filter
    if (selectedCategory != null && 
        selectedCategory != 'All' && 
        category != selectedCategory) {
      return false;
    }

    // Brand filter
    if (selectedBrand != null && 
        selectedBrand != 'All Brands' && 
        brand != selectedBrand) {
      return false;
    }

    // Price range filter
    if (minPrice != null && price < minPrice) return false;
    if (maxPrice != null && price > maxPrice) return false;

    // Stock filter
    if (inStockOnly == true && !inStock) return false;

    // Rating filter
    if (minRating != null && rating < minRating) return false;

    return true;
  }
}