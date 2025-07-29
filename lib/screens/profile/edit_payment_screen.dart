// lib/screens/profile/edit_payment_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditPaymentScreen extends StatefulWidget {
  const EditPaymentScreen({super.key});

  @override
  State<EditPaymentScreen> createState() => _EditPaymentScreenState();
}

class _EditPaymentScreenState extends State<EditPaymentScreen> {
  final cardNumberController = TextEditingController();
  final expiryDateController = TextEditingController();
  final cvvController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadPaymentInfo();
  }

  Future<void> loadPaymentInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('loggedInUser');
    if (userData != null) {
      final user = jsonDecode(userData);
      cardNumberController.text = user['cardNumber'] ?? '';
      expiryDateController.text = user['expiryDate'] ?? '';
      cvvController.text = user['cvv'] ?? '';
    }
  }

  Future<void> savePaymentInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('loggedInUser');

    if (userData != null) {
      final user = jsonDecode(userData);

      user['cardNumber'] = cardNumberController.text.trim();
      user['expiryDate'] = expiryDateController.text.trim();
      user['cvv'] = cvvController.text.trim();

      await prefs.setString('loggedInUser', jsonEncode(user));

      // Update global user list
      final allUsers = prefs.getString('users');
      if (allUsers != null) {
        List users = jsonDecode(allUsers);
        final index = users.indexWhere((u) => u['email'] == user['email']);
        if (index != -1) {
          users[index] = user;
        }
        await prefs.setString('users', jsonEncode(users));
      }

      Navigator.pop(context, true);
    }
  }

  Widget buildInput({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: Colors.teal),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F4),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Edit Payment 💳'),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            buildInput(
              label: 'Card Number',
              hint: 'e.g. 1234 5678 9012 3456',
              controller: cardNumberController,
              icon: Icons.credit_card,
              keyboardType: TextInputType.number,
            ),
            buildInput(
              label: 'Expiry Date',
              hint: 'MM/YY',
              controller: expiryDateController,
              icon: Icons.calendar_today,
              keyboardType: TextInputType.datetime,
            ),
            buildInput(
              label: 'CVV',
              hint: 'e.g. 123',
              controller: cvvController,
              icon: Icons.lock,
              keyboardType: TextInputType.number,
              obscure: true,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: savePaymentInfo,
              icon: const Icon(Icons.save_alt_rounded),
              label: const Text("Save Payment Method 💾"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
