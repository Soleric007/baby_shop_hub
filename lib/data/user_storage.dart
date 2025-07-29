import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserStorage {
  static const _key = 'babyshop_users';

  // Save user
  static Future<void> saveUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final rawUsers = prefs.getStringList(_key) ?? [];

    // Check if user already exists
    final exists = rawUsers.any((user) {
      final u = jsonDecode(user);
      return u['email'] == email;
    });

    if (!exists) {
      rawUsers.add(jsonEncode({'email': email, 'password': password}));
      await prefs.setStringList(_key, rawUsers);
    }
  }

  // Load users
  static Future<List<Map<String, String>>> loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final rawUsers = prefs.getStringList(_key) ?? [];
    return rawUsers.map((u) => Map<String, String>.from(jsonDecode(u))).toList();
  }

  // Validate login
  static Future<bool> validateLogin(String email, String password) async {
    final users = await loadUsers();
    return users.any((u) => u['email'] == email && u['password'] == password);
  }
}
