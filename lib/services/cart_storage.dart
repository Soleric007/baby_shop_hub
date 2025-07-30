// lib/services/cart_storage.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class CartStorage {
  static const String _cartKey = 'cart_items';

  // Save cart to SharedPreferences
  static Future<void> saveCart(Map<Product, int> cartItems) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Convert cart to JSON format
    final cartJson = cartItems.entries.map((entry) {
      return {
        'product': entry.key.toMap(), // Assuming you have toJson() in Product model
        'quantity': entry.value,
      };
    }).toList();
    
    await prefs.setString(_cartKey, jsonEncode(cartJson));
  }

  // Load cart from SharedPreferences
  static Future<Map<Product, int>> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString(_cartKey);
    
    if (cartString == null || cartString.isEmpty) {
      return {};
    }
    
    try {
      final cartJson = jsonDecode(cartString) as List;
      final Map<Product, int> cartItems = {};
      
      for (final item in cartJson) {
        final product = Product.fromMap(item['product']); // Assuming you have fromJson() in Product model
        final quantity = item['quantity'] as int;
        cartItems[product] = quantity;
      }
      
      return cartItems;
    } catch (e) {
      print('Error loading cart: $e');
      return {};
    }
  }

  // Clear cart from SharedPreferences
  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}