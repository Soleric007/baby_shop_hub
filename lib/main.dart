// lib/main.dart (Fixed)
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/product/product_list_screen.dart';
import 'screens/bottom_nav_screen.dart'; 
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'services/admin_service.dart';
import 'data/user_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize admin service and test user
  await AdminService.initializeDefaultAdmin();
  await UserStorage.initializeTestUser();
  
  runApp(const BabyShopHubApp());
}

class BabyShopHubApp extends StatelessWidget {
  const BabyShopHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BabyShopHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.pink,
      ),
      // Always start with splash screen
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const BottomNavScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/admin-login': (context) => const AdminLoginScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
        '/products': (context) => ProductListScreen(
          onAddToCart: (product) {
            debugPrint('Added ${product.name}');
          },
        ),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        backgroundColor: Colors.pink[200],
        title: const Text("Welcome 💝"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: Text(
              "You are logged in! 🎉",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await UserStorage.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}