// lib/screens/auth/login_screen.dart (Updated)
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../bottom_nav_screen.dart';
import '../admin/admin_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String errorMessage = '';

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final prefs = await SharedPreferences.getInstance();
    final storedUsers = prefs.getString('users');

    if (storedUsers != null) {
      final List users = jsonDecode(storedUsers);
      final user = users.firstWhere(
        (u) => u['email'] == email && u['password'] == password,
        orElse: () => null,
      );

      if (user != null) {
        await prefs.setString('loggedInUser', jsonEncode(user));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BottomNavScreen()),
        );
      } else {
        setState(() {
          errorMessage = 'Invalid email or password';
        });
      }
    } else {
      setState(() {
        errorMessage = 'No users found. Please register first 👶';
      });
    }
  }

  Widget _buildFancyInput({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool obscure = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.shade100.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.pink.shade200),
          prefixIcon: Icon(icon, color: Colors.pinkAccent),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
        style: const TextStyle(color: Colors.black87),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F4),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/baby_icon.png', height: 120),
            const SizedBox(height: 20),
            const Text(
              'Welcome Back 👶💕',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF444466),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Login to your BabyShopHub account',
              style: TextStyle(fontSize: 16, color: Color(0xFF888899)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // 👉 Fancy Inputs
            _buildFancyInput(
              hint: 'Email',
              icon: Icons.email_rounded,
              controller: emailController,
            ),
            _buildFancyInput(
              hint: 'Password',
              icon: Icons.lock_rounded,
              controller: passwordController,
              obscure: true,
            ),

            const SizedBox(height: 10),
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
              ),
              child: const Text('Login', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/register');
              },
              child: const Text(
                "Don't have an account? Sign Up 🍼",
                style: TextStyle(color: Colors.pinkAccent),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Admin Access Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepPurple.shade200),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                  );
                },
                icon: const Icon(Icons.admin_panel_settings, color: Colors.deepPurple),
                label: const Text(
                  'Admin Access 🔐',
                  style: TextStyle(color: Colors.deepPurple, fontSize: 16),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}