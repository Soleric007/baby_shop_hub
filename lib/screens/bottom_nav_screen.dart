// lib/screens/bottom_nav_screen.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/cart_storage.dart'; // Add this import
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCartData();
  }

  // Load cart data when app starts
  Future<void> _loadCartData() async {
    try {
      final loadedCart = await CartStorage.loadCart();
      setState(() {
        cartItems = loadedCart;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading cart: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _addToCart(Product product) async {
    setState(() {
      if (cartItems.containsKey(product)) {
        cartItems[product] = cartItems[product]! + 1;
      } else {
        cartItems[product] = 1;
      }
    });
    
    // Save cart to persistence
    await CartStorage.saveCart(cartItems);
  }

  Future<void> _clearCart() async {
    if (cartItems.isNotEmpty) {
      // Save current cart as an order before clearing
      _orders.add(Map<Product, int>.from(cartItems));
    }
    
    setState(() {
      cartItems.clear();
    });
    
    // Clear cart from persistence
    await CartStorage.clearCart();
  }

  Future<void> _removeFromCart(Product product) async {
    setState(() {
      cartItems.remove(product);
    });
    
    // Save updated cart to persistence
    await CartStorage.saveCart(cartItems);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final _screens = [
      ProductListScreen(onAddToCart: _addToCart),
      CartScreen(
        cartItems: cartItems,
        onCheckout: _clearCart, // This will now properly clear the cart
        onRemoveItem: _removeFromCart,
      ),
      ProfileScreen(orders: _orders),
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