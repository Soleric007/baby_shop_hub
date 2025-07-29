import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() {
    final user = widget.userData;
    nameController.text = user['name'] ?? '';
    emailController.text = user['email'] ?? '';
    addressController.text = user['address'] ?? '';
  }

  Future<void> saveChanges() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('loggedInUser');
    if (userData != null) {
      final user = jsonDecode(userData);
      user['name'] = nameController.text.trim();
      user['email'] = emailController.text.trim();
      user['address'] = addressController.text.trim();

      await prefs.setString('loggedInUser', jsonEncode(user));

      // Update in all users
      final allUsers = prefs.getString('users');
      if (allUsers != null) {
        List users = jsonDecode(allUsers);
        final index = users.indexWhere((u) => u['email'] == user['email']);
        if (index != -1) {
          users[index] = user;
        }
        await prefs.setString('users', jsonEncode(users));
      }

      Navigator.pop(context, true); // Return and refresh
    }
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required Icon icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: icon,
        labelStyle: const TextStyle(color: Colors.pinkAccent),
        hintStyle: const TextStyle(color: Colors.pinkAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(fontFamily: 'Poppins'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F4),
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: const Text('Edit Profile ✍️',
            style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Center(
              child: Image.asset('assets/images/baby_icon.png', height: 80),
            ),
            const SizedBox(height: 30),

            buildTextField(
              controller: nameController,
              label: 'Full Name',
              hint: 'e.g. Mummy Chidera',
              icon: const Icon(Icons.person_outline, color: Colors.pink),
            ),
            const SizedBox(height: 20),

            buildTextField(
              controller: emailController,
              label: 'Email Address',
              hint: 'e.g. mummybaby@gmail.com',
              icon: const Icon(Icons.email_outlined, color: Colors.purple),
            ),
            const SizedBox(height: 20),

            buildTextField(
              controller: addressController,
              label: 'Delivery Address',
              hint: 'e.g. 22 Baby Avenue, Enugu',
              icon: const Icon(Icons.home_outlined, color: Colors.deepPurple),
            ),

            const SizedBox(height: 30),

            Center(
              child: ElevatedButton.icon(
                onPressed: saveChanges,
                icon: const Icon(Icons.save_alt_rounded, size: 20),
                label: const Text(
                  "Save Changes 💾",
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
