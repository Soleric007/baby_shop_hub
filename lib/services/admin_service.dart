// lib/services/admin_service.dart (Updated)
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/admin.dart';
import '../models/product.dart';
import '../data/user_storage.dart';

class AdminService {
  static const String _adminKey = 'babyshop_admins';
  static const String _loggedInAdminKey = 'logged_in_admin';
  static const String _productsKey = 'babyshop_products';

  // Initialize default admin (now using UserStorage)
  static Future<void> initializeDefaultAdmin() async {
    try {
      // Check if default admin exists in UserStorage
      final existingAdmin = await UserStorage.getUserByEmail('admin@babyshophub.com');
      
      if (existingAdmin == null) {
        final defaultAdminData = {
          'name': 'Super Admin',
          'email': 'admin@babyshophub.com',
          'phone': '1234567890',
          'address': 'Admin Office, BabyShopHub HQ',
          'password': 'admin123',
          'role': 'admin',
        };
        
        await UserStorage.saveUser(defaultAdminData);
      }
    } catch (e) {
      print('Error initializing default admin: $e');
    }
  }

  // Admin Authentication (now uses UserStorage)
  static Future<Map<String, dynamic>?> adminLogin(String email, String password) async {
    try {
      final user = await UserStorage.validateLogin(email, password);
      
      if (user != null && user['role'] == 'admin') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_loggedInAdminKey, jsonEncode(user));
        return user;
      }
      return null;
    } catch (e) {
      print('Error during admin login: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getCurrentAdmin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adminData = prefs.getString(_loggedInAdminKey);
      
      if (adminData != null) {
        return Map<String, dynamic>.from(jsonDecode(adminData));
      }
      return null;
    } catch (e) {
      print('Error getting current admin: $e');
      return null;
    }
  }

  static Future<void> adminLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_loggedInAdminKey);
    } catch (e) {
      print('Error during admin logout: $e');
    }
  }

  // Product Management
  static Future<List<Product>> getAllProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsData = prefs.getString(_productsKey);
      
      if (productsData != null) {
        final List productsList = jsonDecode(productsData);
        return productsList.map((p) => Product.fromMap(p)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting all products: $e');
      return [];
    }
  }

  static Future<bool> saveProducts(List<Product> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsData = products.map((p) => p.toMap()).toList();
      await prefs.setString(_productsKey, jsonEncode(productsData));
      return true;
    } catch (e) {
      print('Error saving products: $e');
      return false;
    }
  }

  static Future<bool> addProduct(Product product) async {
    try {
      final products = await getAllProducts();
      products.add(product);
      return await saveProducts(products);
    } catch (e) {
      print('Error adding product: $e');
      return false;
    }
  }

  static Future<bool> updateProduct(Product updatedProduct) async {
    try {
      final products = await getAllProducts();
      final index = products.indexWhere((p) => p.id == updatedProduct.id);
      if (index != -1) {
        products[index] = updatedProduct;
        return await saveProducts(products);
      }
      return false;
    } catch (e) {
      print('Error updating product: $e');
      return false;
    }
  }

  static Future<bool> deleteProduct(String productId) async {
    try {
      final products = await getAllProducts();
      products.removeWhere((p) => p.id == productId);
      return await saveProducts(products);
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }

  // User Management (now uses UserStorage)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      return await UserStorage.loadUsers();
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  static Future<bool> deleteUser(String email) async {
    try {
      return await UserStorage.deleteUser(email);
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  static Future<bool> promoteUserToAdmin(String email) async {
    try {
      return await UserStorage.promoteToAdmin(email);
    } catch (e) {
      print('Error promoting user to admin: $e');
      return false;
    }
  }

  static Future<bool> demoteAdminToUser(String email) async {
    try {
      return await UserStorage.demoteFromAdmin(email);
    } catch (e) {
      print('Error demoting admin to user: $e');
      return false;
    }
  }

  // Analytics
  static Future<Map<String, dynamic>> getAnalytics() async {
    try {
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
          if (order is List) {
            for (var item in order) {
              final productPrice = (item['product']['price'] as num?)?.toDouble() ?? 0.0;
              final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
              totalRevenue += (productPrice * quantity);
            }
          }
        }
      }
      
      // Count admins and regular users
      final adminCount = users.where((user) => user['role'] == 'admin').length;
      final regularUserCount = users.where((user) => user['role'] != 'admin').length;
      
      return {
        'totalUsers': users.length,
        'totalProducts': products.length,
        'totalOrders': totalOrders,
        'totalRevenue': totalRevenue,
        'adminCount': adminCount,
        'regularUserCount': regularUserCount,
        'inStockProducts': products.where((p) => p.inStock).length,
        'outOfStockProducts': products.where((p) => !p.inStock).length,
      };
    } catch (e) {
      print('Error getting analytics: $e');
      return {
        'totalUsers': 0,
        'totalProducts': 0,
        'totalOrders': 0,
        'totalRevenue': 0.0,
        'adminCount': 0,
        'regularUserCount': 0,
        'inStockProducts': 0,
        'outOfStockProducts': 0,
      };
    }
  }

  // Check if current user is admin
  static Future<bool> isCurrentUserAdmin() async {
    try {
      final currentUser = await UserStorage.getLoggedInUser();
      return currentUser != null && currentUser['role'] == 'admin';
    } catch (e) {
      print('Error checking if current user is admin: $e');
      return false;
    }
  }

  // Get all admin users
  static Future<List<Map<String, dynamic>>> getAllAdmins() async {
    try {
      final users = await getAllUsers();
      return users.where((user) => user['role'] == 'admin').toList();
    } catch (e) {
      print('Error getting all admins: $e');
      return [];
    }
  }

  // Get all regular users
  static Future<List<Map<String, dynamic>>> getRegularUsers() async {
    try {
      final users = await getAllUsers();
      return users.where((user) => user['role'] != 'admin').toList();
    } catch (e) {
      print('Error getting regular users: $e');
      return [];
    }
  }
}