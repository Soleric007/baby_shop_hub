// lib/services/admin_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/admin.dart';
import '../models/product.dart';

class AdminService {
  static const String _adminKey = 'babyshop_admins';
  static const String _loggedInAdminKey = 'logged_in_admin';
  static const String _productsKey = 'babyshop_products';
  static const String _usersKey = 'users';

  // Initialize default admin
  static Future<void> initializeDefaultAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final existingAdmins = prefs.getString(_adminKey);
    
    if (existingAdmins == null) {
      final defaultAdmin = Admin(
        id: 'admin_001',
        email: 'admin@babyshophub.com',
        password: 'admin123',
        name: 'Super Admin',
        createdAt: DateTime.now(),
      );
      
      await prefs.setString(_adminKey, jsonEncode([defaultAdmin.toMap()]));
    }
  }

  // Admin Authentication
  static Future<Admin?> adminLogin(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final adminsData = prefs.getString(_adminKey);
    
    if (adminsData != null) {
      final List adminsList = jsonDecode(adminsData);
      final adminMap = adminsList.firstWhere(
        (admin) => admin['email'] == email && admin['password'] == password,
        orElse: () => null,
      );
      
      if (adminMap != null) {
        final admin = Admin.fromMap(adminMap);
        await prefs.setString(_loggedInAdminKey, jsonEncode(admin.toMap()));
        return admin;
      }
    }
    return null;
  }

  static Future<Admin?> getCurrentAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final adminData = prefs.getString(_loggedInAdminKey);
    
    if (adminData != null) {
      return Admin.fromMap(jsonDecode(adminData));
    }
    return null;
  }

  static Future<void> adminLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInAdminKey);
  }

  // Product Management
  static Future<List<Product>> getAllProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsData = prefs.getString(_productsKey);
    
    if (productsData != null) {
      final List productsList = jsonDecode(productsData);
      return productsList.map((p) => Product.fromMap(p)).toList();
    }
    return [];
  }

  static Future<void> saveProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final productsData = products.map((p) => p.toMap()).toList();
    await prefs.setString(_productsKey, jsonEncode(productsData));
  }

  static Future<void> addProduct(Product product) async {
    final products = await getAllProducts();
    products.add(product);
    await saveProducts(products);
  }

  static Future<void> updateProduct(Product updatedProduct) async {
    final products = await getAllProducts();
    final index = products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      products[index] = updatedProduct;
      await saveProducts(products);
    }
  }

  static Future<void> deleteProduct(String productId) async {
    final products = await getAllProducts();
    products.removeWhere((p) => p.id == productId);
    await saveProducts(products);
  }

  // User Management
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersData = prefs.getString(_usersKey);
    
    if (usersData != null) {
      final List usersList = jsonDecode(usersData);
      return usersList.map((u) => Map<String, dynamic>.from(u)).toList();
    }
    return [];
  }

  static Future<void> deleteUser(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await getAllUsers();
    users.removeWhere((user) => user['email'] == email);
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  // Analytics
  static Future<Map<String, dynamic>> getAnalytics() async {
    final users = await getAllUsers();
    final products = await getAllProducts();
    
    // Get orders from storage
    final prefs = await SharedPreferences.getInstance();
    final ordersData = prefs.getString('babyshop_orders');
    int totalOrders = 0;
    double totalRevenue = 0.0;
    
    if (ordersData != null) {
      final List orders = jsonDecode(ordersData);
      totalOrders = orders.length;
      
      // Calculate revenue (simplified)
      for (var order in orders) {
        for (var item in order) {
          final productPrice = item['product']['price'];
          final quantity = item['quantity'];
          totalRevenue += (productPrice * quantity);
        }
      }
    }
    
    return {
      'totalUsers': users.length,
      'totalProducts': products.length,
      'totalOrders': totalOrders,
      'totalRevenue': totalRevenue,
    };
  }
}