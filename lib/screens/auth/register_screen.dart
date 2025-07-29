import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String errorMessage = '';

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'All fields are required 😢';
      });
      return;
    }

    if (!isValidEmail(email)) {
      setState(() {
        errorMessage = 'Please enter a valid email 📧';
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final storedUsers = prefs.getString('users');
    List<Map<String, String>> users = [];

    if (storedUsers != null) {
      users = List<Map<String, String>>.from(jsonDecode(storedUsers));
      if (users.any((user) => user['email'] == email)) {
        setState(() {
          errorMessage = 'Oops! This email is already taken 💔';
        });
        return;
      }
    }

    users.add({
      'name': name,
      'email': email,
      'password': password,
    });
    await prefs.setString('users', jsonEncode(users));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("🎉 Account created! Redirecting to login..."),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  InputDecoration _inputDecoration(String hint, IconData icon, Color iconColor) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: iconColor),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F4),
      appBar: AppBar(
        backgroundColor: Colors.pink[100],
        title: const Text('Create Account 🍼'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset('assets/images/baby_icon.png', height: 100),
                const SizedBox(height: 10),
                const Text(
                  'Welcome, Super Parent! 💖',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: nameController,
                  decoration: _inputDecoration("Full Name", Icons.person, Colors.deepPurple),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration("Email", Icons.email, Colors.pinkAccent),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: _inputDecoration("Password", Icons.lock, Colors.purple),
                ),
                const SizedBox(height: 10),
                if (errorMessage.isNotEmpty)
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                    elevation: 4,
                  ),
                  child: const Text('Create Account', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text(
                    "Already have an account? Login 💼",
                    style: TextStyle(color: Colors.pinkAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
