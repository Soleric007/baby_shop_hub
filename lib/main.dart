import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/product/product_list_screen.dart';
import 'screens/bottom_nav_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  // Changed to check for 'loggedInUser' instead of 'loggedInUserEmail'
  final loggedInUser = prefs.getString('loggedInUser');
  final isLoggedIn = loggedInUser != null;

  runApp(BabyShopHubApp(isLoggedIn: isLoggedIn));
}

class BabyShopHubApp extends StatelessWidget {
  final bool isLoggedIn;

  const BabyShopHubApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BabyShopHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.pink,
      ),
      initialRoute: isLoggedIn ? '/home' : '/login',
      routes: {
        '/home': (context) => const BottomNavScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
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
              final prefs = await SharedPreferences.getInstance();
              // Changed to remove 'loggedInUser' instead of 'loggedInUserEmail'
              await prefs.remove('loggedInUser');
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}