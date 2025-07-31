import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/bottom_nav_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.pinkAccent,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      initialRoute: isLoggedIn ? '/home' : '/login',
      routes: {
        '/home': (context) => const BottomNavScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}

// Remove the unused HomeScreen class since we're using BottomNavScreen as the main screen