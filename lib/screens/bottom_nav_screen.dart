import 'package:flutter/material.dart';
import '../models/product.dart';
import '../screens/product/product_list_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/profile/profile_screen.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;

  // 🧺 Cart items state
  final List<Product> _cartItems = [];

  // ➕ Add product to cart
  void _addToCart(Product product) {
    setState(() {
      _cartItems.add(product);
    });

    // Optional: feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart 🍼'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.pinkAccent,
      ),
    );
  }

  // ✅ Checkout: clear cart
  void _handleCheckout(List<Product> items) {
    setState(() {
      _cartItems.clear();
    });

    // Confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order placed successfully 💖'),
        backgroundColor: Colors.pink,
      ),
    );
  }

  // 👶 Screens with dynamic cart state
  List<Widget> get _screens => [
        ProductListScreen(onAddToCart: _addToCart),
        CartScreen(cartItems: _cartItems, onCheckout: _handleCheckout),
        const ProfileScreen(),
      ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.pink[50],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.child_care),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
