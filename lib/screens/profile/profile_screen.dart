import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile_screen.dart';
import 'order_history_screen.dart';
import 'edit_payment_screen.dart';
import '../../models/product.dart';

class ProfileScreen extends StatefulWidget {
  final List<Map<dynamic, dynamic>> orders; // ✅ Accept orders

  const ProfileScreen({super.key, this.orders = const []}); // ✅ Default empty

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString('loggedInUser');
    if (storedUser != null) {
      setState(() {
        user = jsonDecode(storedUser);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F4),
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: const Text(
          'My Profile 👶',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.pink[100],
                      child: const Icon(Icons.person, size: 60, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 25),

                  const Text(
                    '👩‍🍼 Personal Info',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF444466),
                    ),
                  ),
                  const SizedBox(height: 10),

                  profileTile('👶 Name', user?['name'] ?? 'Not set'),
                  profileTile('📧 Email', user?['email'] ?? 'Not set'),
                  profileTile('🏠 Address', user?['address'] ?? 'Not set'),
                  profileTile('💳 Payment', user?['payment'] ?? 'Not set'),

                  const SizedBox(height: 30),

                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfileScreen(userData: user!),
                        ),
                      );
                      if (result == true) {
                        loadUser(); // Refresh on return
                      }
                    },
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Edit Profile ✏️'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) {
                              final convertedOrders = widget.orders.map<Map<Product, int>>((orderMap) {
                                return orderMap.map((key, value) => MapEntry(
                                  Product.fromMap(Map<String, dynamic>.from(key)),
                                  value as int,
                                ));
                              }).toList();

                              return const OrderHistoryScreen();

                            },
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_bag_rounded),
                      label: const Text('My Orders 🛍️'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),


                  const SizedBox(height: 15),

                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditPaymentScreen(),
                        ),
                      ).then((value) {
                        if (value == true) loadUser(); // Refresh after payment edit
                      });
                    },
                    icon: const Icon(Icons.credit_card),
                    label: const Text('Edit Payment Method 💳'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget profileTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.pink.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.shade50,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 16,
          fontFamily: 'Poppins',
          color: Color(0xFF555577),
        ),
      ),
    );
  }
}