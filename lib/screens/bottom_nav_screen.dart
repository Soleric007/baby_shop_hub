// lib/screens/bottom_nav_screen.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product/product_list_screen.dart';
import 'cart/cart_screen.dart';
import 'profile/profile_screen.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;
  Map<Product, int> cartItems = {};
  List<Map<Product, int>> _orders = [];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addToCart(Product product) {
    setState(() {
      if (cartItems.containsKey(product)) {
        cartItems[product] = cartItems[product]! + 1;
      } else {
        cartItems[product] = 1;
      }
    });
  }

  void _clearCart() {
    if (cartItems.isNotEmpty) {
      // Save current cart as an order before clearing
      _orders.add(Map<Product, int>.from(cartItems));
    }
    setState(() {
      cartItems.clear();
    });
  }

  void _removeFromCart(Product product) {
    setState(() {
      cartItems.remove(product);
    });
  }

  @override
  Widget build(BuildContext context) {
    final _screens = [
      ProductListScreen(onAddToCart: _addToCart),
      CartScreen(
        cartItems: cartItems,
        onCheckout: _clearCart,
        onRemoveItem: _removeFromCart,
      ),
      ProfileScreen(orders: _orders), // updated
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.pink[50],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.child_care), label: 'Profile'),
        ],
      ),
    );
  }
}
