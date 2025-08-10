import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserStorage {
  static const String _usersKey = 'users';
  static const String _loggedInUserKey = 'loggedInUser';

  // Save a new user during registration
  static Future<bool> saveUser(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);
      List<Map<String, dynamic>> users = [];

      if (usersJson != null) {
        final List<dynamic> decodedUsers = jsonDecode(usersJson);
        users = decodedUsers.map((user) => Map<String, dynamic>.from(user)).toList();
        
        // Check if user already exists
        if (users.any((user) => user['email'].toString().toLowerCase() == 
            userData['email'].toString().toLowerCase())) {
          return false; // User already exists
        }
      }

      // Add timestamps and default role
      userData['created_at'] = DateTime.now().toIso8601String();
      userData['updated_at'] = DateTime.now().toIso8601String();
      userData['role'] = userData['role'] ?? 'user'; // Default role is 'user'

      users.add(userData);
      await prefs.setString(_usersKey, jsonEncode(users));
      return true;
    } catch (e) {
      print('Error saving user: $e');
      return false;
    }
  }

  // Update existing user data
  static Future<bool> updateUser(Map<String, dynamic> updatedUserData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);
      
      if (usersJson == null) return false;

      final List<dynamic> decodedUsers = jsonDecode(usersJson);
      List<Map<String, dynamic>> users = decodedUsers.map((user) => 
          Map<String, dynamic>.from(user)).toList();

      // Find and update the user
      final userIndex = users.indexWhere((user) => 
          user['email'].toString().toLowerCase() == 
          updatedUserData['email'].toString().toLowerCase());

      if (userIndex == -1) return false;

      // Preserve creation date and update timestamp
      updatedUserData['created_at'] = users[userIndex]['created_at'];
      updatedUserData['updated_at'] = DateTime.now().toIso8601String();

      users[userIndex] = updatedUserData;
      await prefs.setString(_usersKey, jsonEncode(users));

      // Also update logged in user if it's the same user
      final loggedInUser = await getLoggedInUser();
      if (loggedInUser != null && 
          loggedInUser['email'].toString().toLowerCase() == 
          updatedUserData['email'].toString().toLowerCase()) {
        await setLoggedInUser(updatedUserData);
      }

      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  // Promote user to admin
  static Future<bool> promoteToAdmin(String email) async {
    try {
      final user = await getUserByEmail(email);
      if (user == null) return false;
      
      user['role'] = 'admin';
      return await updateUser(user);
    } catch (e) {
      print('Error promoting user to admin: $e');
      return false;
    }
  }

  // Demote admin to user
  static Future<bool> demoteFromAdmin(String email) async {
    try {
      final user = await getUserByEmail(email);
      if (user == null) return false;
      
      user['role'] = 'user';
      return await updateUser(user);
    } catch (e) {
      print('Error demoting admin: $e');
      return false;
    }
  }

  // Load all users
  static Future<List<Map<String, dynamic>>> loadUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);
      
      if (usersJson == null) return [];

      final List<dynamic> decodedUsers = jsonDecode(usersJson);
      return decodedUsers.map((user) => Map<String, dynamic>.from(user)).toList();
    } catch (e) {
      print('Error loading users: $e');
      return [];
    }
  }

  // Validate login credentials
  static Future<Map<String, dynamic>?> validateLogin(String email, String password) async {
    try {
      final users = await loadUsers();
      final user = users.firstWhere(
        (u) => u['email'].toString().toLowerCase() == email.toLowerCase() && 
               u['password'] == password,
        orElse: () => {},
      );
      
      return user.isNotEmpty ? user : null;
    } catch (e) {
      print('Error validating login: $e');
      return null;
    }
  }

  // Check if email already exists
  static Future<bool> emailExists(String email) async {
    try {
      final users = await loadUsers();
      return users.any((user) => 
          user['email'].toString().toLowerCase() == email.toLowerCase());
    } catch (e) {
      print('Error checking email existence: $e');
      return false;
    }
  }

  // Set logged in user
  static Future<bool> setLoggedInUser(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_loggedInUserKey, jsonEncode(userData));
      
      // Also set a simple flag for quick login check
      await prefs.setString('loggedInUserEmail', userData['email'] ?? '');
      return true;
    } catch (e) {
      print('Error setting logged in user: $e');
      return false;
    }
  }

  // Get logged in user
  static Future<Map<String, dynamic>?> getLoggedInUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_loggedInUserKey);
      
      if (userJson == null) return null;
      
      return Map<String, dynamic>.from(jsonDecode(userJson));
    } catch (e) {
      print('Error getting logged in user: $e');
      return null;
    }
  }

  // Logout user
  static Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_loggedInUserKey);
      await prefs.remove('loggedInUserEmail');
      return true;
    } catch (e) {
      print('Error logging out: $e');
      return false;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final user = await getLoggedInUser();
      return user != null;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Get user by email
  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final users = await loadUsers();
      final user = users.firstWhere(
        (u) => u['email'].toString().toLowerCase() == email.toLowerCase(),
        orElse: () => {},
      );
      
      return user.isNotEmpty ? user : null;
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

  // Delete user by email
  static Future<bool> deleteUser(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);
      
      if (usersJson == null) return false;

      final List<dynamic> decodedUsers = jsonDecode(usersJson);
      List<Map<String, dynamic>> users = decodedUsers.map((user) => 
          Map<String, dynamic>.from(user)).toList();

      // Remove user with matching email
      users.removeWhere((user) => 
          user['email'].toString().toLowerCase() == email.toLowerCase());

      await prefs.setString(_usersKey, jsonEncode(users));
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  // Clear all user data (for testing purposes)
  static Future<bool> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_usersKey);
      await prefs.remove(_loggedInUserKey);
      await prefs.remove('loggedInUserEmail');
      return true;
    } catch (e) {
      print('Error clearing all data: $e');
      return false;
    }
  }

  // Initialize with default test user (optional - for development)
  static Future<void> initializeTestUser() async {
    try {
      final users = await loadUsers();
      if (users.isEmpty) {
        final testUser = {
          'name': 'Test User',
          'email': 'test@babyshop.com',
          'phone': '1234567890',
          'address': '123 Test Street, Test City, TC 12345',
          'password': '123456',
          'role': 'user',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        await saveUser(testUser);
        
        // Also create a test admin
        final testAdmin = {
          'name': 'Test Admin',
          'email': 'admin@babyshop.com',
          'phone': '0987654321',
          'address': '456 Admin Street, Admin City, AC 54321',
          'password': 'admin123',
          'role': 'admin',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        await saveUser(testAdmin);
      }
    } catch (e) {
      print('Error initializing test users: $e');
    }
  }
}