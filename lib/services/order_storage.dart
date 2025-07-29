import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class OrderStorage {
  static const _key = 'babyshop_orders';

  static Future<void> saveOrders(List<Map<Product, int>> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedOrders = orders.map((order) {
      return order.entries.map((entry) {
        return {
          'product': entry.key.toMap(),
          'quantity': entry.value,
        };
      }).toList();
    }).toList();

    await prefs.setString(_key, jsonEncode(encodedOrders));
  }

  static Future<List<Map<Product, int>>> loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];

    final decoded = jsonDecode(raw) as List;
    return decoded.map<Map<Product, int>>((orderList) {
      final entries = orderList as List;
      return {
        for (var entry in entries)
          Product.fromMap(entry['product']): entry['quantity'],
      };
    }).toList();
  }
}
