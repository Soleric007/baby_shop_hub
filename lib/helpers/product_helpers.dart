// lib/helpers/product_helpers.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../data/mock_products.dart';

class ProductHelpers {
  // Get similar products based on category and brand
  static List<Product> getSimilarProducts(Product product, {int limit = 4}) {
    return mockProducts
        .where((p) => 
            p.id != product.id && 
            (p.category == product.category || p.brand == product.brand))
        .take(limit)
        .toList();
  }

  // Get products by category
  static List<Product> getProductsByCategory(String category) {
    if (category == 'All') return mockProducts;
    return mockProducts.where((p) => p.category == category).toList();
  }

  // Get products by brand
  static List<Product> getProductsByBrand(String brand) {
    if (brand == 'All Brands') return mockProducts;
    return mockProducts.where((p) => p.brand == brand).toList();
  }

  // Get top rated products
  static List<Product> getTopRatedProducts({int limit = 5}) {
    final sortedProducts = List<Product>.from(mockProducts);
    sortedProducts.sort((a, b) => b.rating.compareTo(a.rating));
    return sortedProducts.take(limit).toList();
  }

  // Get products on sale (mock - in real app this would be based on actual sale data)
  static List<Product> getProductsOnSale({int limit = 5}) {
    // For demo purposes, return products with rating > 4.0
    return mockProducts
        .where((p) => p.rating > 4.0)
        .take(limit)
        .toList();
  }

  // Search products
  static List<Product> searchProducts(String query) {
    if (query.isEmpty) return mockProducts;
    
    return mockProducts
        .where((product) => product.matchesSearch(query))
        .toList();
  }

  // Filter products
  static List<Product> filterProducts({
    String? category,
    String? brand,
    double? minPrice,
    double? maxPrice,
    bool? inStockOnly,
    double? minRating,
  }) {
    return mockProducts
        .where((product) => product.matchesFilters(
              selectedCategory: category,
              selectedBrand: brand,
              minPrice: minPrice,
              maxPrice: maxPrice,
              inStockOnly: inStockOnly,
              minRating: minRating,
            ))
        .toList();
  }

  // Get product recommendations based on user's cart or purchase history
  static List<Product> getRecommendedProducts(List<Product> userProducts, {int limit = 4}) {
    if (userProducts.isEmpty) return getTopRatedProducts(limit: limit);

    // Get categories and brands from user's products
    final userCategories = userProducts.map((p) => p.category).toSet();
    final userBrands = userProducts.map((p) => p.brand).toSet();
    final userProductIds = userProducts.map((p) => p.id).toSet();

    // Find products in similar categories/brands that user doesn't have
    final recommendations = mockProducts
        .where((p) => 
            !userProductIds.contains(p.id) &&
            (userCategories.contains(p.category) || userBrands.contains(p.brand)))
        .toList();

    // Sort by rating
    recommendations.sort((a, b) => b.rating.compareTo(a.rating));
    
    return recommendations.take(limit).toList();
  }

  // Get recently viewed products (would use SharedPreferences in real app)
  static Future<List<Product>> getRecentlyViewedProducts() async {
    // Mock implementation - in real app, load from SharedPreferences
    return mockProducts.take(3).toList();
  }

  // Calculate average rating for a category
  static double getCategoryAverageRating(String category) {
    final categoryProducts = getProductsByCategory(category);
    if (categoryProducts.isEmpty) return 0.0;
    
    final totalRating = categoryProducts.fold<double>(
      0.0, 
      (sum, product) => sum + product.rating,
    );
    
    return totalRating / categoryProducts.length;
  }

  // Get price range for category
  static Map<String, double> getCategoryPriceRange(String category) {
    final categoryProducts = getProductsByCategory(category);
    if (categoryProducts.isEmpty) {
      return {'min': 0.0, 'max': 0.0};
    }
    
    final prices = categoryProducts.map((p) => p.price).toList();
    return {
      'min': prices.reduce((a, b) => a < b ? a : b),
      'max': prices.reduce((a, b) => a > b ? a : b),
    };
  }

  // Get category statistics
  static Map<String, dynamic> getCategoryStats(String category) {
    final products = getProductsByCategory(category);
    final inStock = products.where((p) => p.inStock).length;
    final priceRange = getCategoryPriceRange(category);
    
    return {
      'totalProducts': products.length,
      'inStock': inStock,
      'outOfStock': products.length - inStock,
      'averageRating': getCategoryAverageRating(category),
      'minPrice': priceRange['min'],
      'maxPrice': priceRange['max'],
      'averagePrice': products.isEmpty ? 0.0 : 
          products.fold<double>(0.0, (sum, p) => sum + p.price) / products.length,
    };
  }

  // Sort products by different criteria
  static List<Product> sortProducts(List<Product> products, String sortBy) {
    final sortedProducts = List<Product>.from(products);
    
    switch (sortBy) {
      case 'name_asc':
        sortedProducts.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'name_desc':
        sortedProducts.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'price_asc':
        sortedProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        sortedProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating_asc':
        sortedProducts.sort((a, b) => a.rating.compareTo(b.rating));
        break;
      case 'rating_desc':
        sortedProducts.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'popularity':
        sortedProducts.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
      default: // 'featured' or default
        sortedProducts.sort((a, b) => b.rating.compareTo(a.rating));
    }
    
    return sortedProducts;
  }

  // Get trending products (mock - based on high ratings and review counts)
  static List<Product> getTrendingProducts({int limit = 6}) {
    final trendingProducts = List<Product>.from(mockProducts);
    
    // Sort by a combination of rating and review count
    trendingProducts.sort((a, b) {
      final aScore = (a.rating * 0.7) + (a.reviewCount * 0.3 / 100);
      final bScore = (b.rating * 0.7) + (b.reviewCount * 0.3 / 100);
      return bScore.compareTo(aScore);
    });
    
    return trendingProducts.take(limit).toList();
  }

  // Get new arrivals (mock - last few products added)
  static List<Product> getNewArrivals({int limit = 6}) {
    // In a real app, this would be sorted by creation date
    // For demo, return last few products from the list
    return mockProducts.reversed.take(limit).toList();
  }

  // Get featured products for homepage
  static List<Product> getFeaturedProducts({int limit = 8}) {
    // Mix of top-rated and trending products
    final featured = <Product>[];
    final topRated = getTopRatedProducts(limit: limit ~/ 2);
    final trending = getTrendingProducts(limit: limit ~/ 2);
    
    featured.addAll(topRated);
    
    // Add trending products that aren't already in featured
    for (final product in trending) {
      if (!featured.any((p) => p.id == product.id) && featured.length < limit) {
        featured.add(product);
      }
    }
    
    return featured;
  }

  // Check if product is in user's wishlist
  static Future<bool> isInWishlist(String productId) async {
    // Mock implementation - in real app, check SharedPreferences or backend
    return Future.value(false);
  }

  // Add/remove from wishlist
  static Future<void> toggleWishlist(String productId) async {
    // Mock implementation - in real app, update SharedPreferences or backend
    return Future.value();
  }

  // Get discount percentage (mock - in real app this would come from product data)
  static double getDiscountPercentage(Product product) {
    // Mock discount based on rating (higher rating = higher discount for demo)
    if (product.rating >= 4.5) return 0.15; // 15% off
    if (product.rating >= 4.0) return 0.10; // 10% off
    if (product.rating >= 3.5) return 0.05; // 5% off
    return 0.0; // No discount
  }

  // Get discounted price
  static double getDiscountedPrice(Product product) {
    final discount = getDiscountPercentage(product);
    return product.price * (1 - discount);
  }

  // Format currency
  static String formatPrice(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }

  // Get stock status with color
  static Map<String, dynamic> getStockInfo(Product product) {
    if (product.inStock) {
      return {
        'text': 'In Stock',
        'color': Colors.green,
        'icon': Icons.check_circle,
      };
    } else {
      return {
        'text': 'Out of Stock',
        'color': Colors.red,
        'icon': Icons.cancel,
      };
    }
  }
}