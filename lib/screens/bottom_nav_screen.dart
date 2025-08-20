import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/product.dart';
import '../services/order_storage.dart';
import '../data/user_storage.dart';
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
  List<Map<Product, int>> _orders = []; // Keep for backward compatibility

  @override
  void initState() {
    super.initState();
    _loadCartData();
  }

  // Load cart data from SharedPreferences
  Future<void> _loadCartData() async {
    try {
      // Load cart items using the existing cart storage format
      final cartStorage = await CartStorage.loadCart();
      setState(() {
        cartItems = cartStorage;
      });

      // Load orders for the profile screen (legacy format) - REMOVED DUPLICATION
      // The profile screen now loads orders directly from OrderStorage
    } catch (e) {
      debugPrint('Error loading cart data: $e');
    }
  }

  // Save cart data to SharedPreferences
  Future<void> _saveCartData() async {
    try {
      await CartStorage.saveCart(cartItems);
    } catch (e) {
      debugPrint('Error saving cart data: $e');
    }
  }

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

    _saveCartData(); // Save to persistent storage

    // Show snackbar confirmation with enhanced styling
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.shopping_cart, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${product.name} added to cart!',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _selectedIndex = 1; // Switch to cart tab
            });
          },
        ),
      ),
    );
  }

  Future<void> _clearCart() async {
    if (cartItems.isNotEmpty) {
      try {
        // Get current user
        final currentUser = await UserStorage.getLoggedInUser();
        if (currentUser != null) {
          // Create and save order using OrderStorage - ONLY ONCE
          final order = await OrderStorage.createOrderFromCart(
            cartItems,
            currentUser['email'] ?? '',
          );

          if (order != null) {
            // Clear cart items - REMOVED DUPLICATE ORDER ADDITION
            setState(() {
              cartItems.clear();
            });

            await _saveCartData(); // Save cleared cart

            // Show enhanced success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Order placed successfully!',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                duration: const Duration(seconds: 3),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                action: SnackBarAction(
                  label: 'VIEW ORDERS',
                  textColor: Colors.white,
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 2; // Switch to profile tab
                    });
                  },
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to place order. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please login to place an order.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error placing order: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to place order. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeFromCart(Product product) {
    setState(() {
      cartItems.remove(product);
    });
    _saveCartData(); // Save to persistent storage
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} removed from cart'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _updateCartQuantity(Product product, int newQuantity) {
    setState(() {
      if (newQuantity <= 0) {
        cartItems.remove(product);
      } else {
        cartItems[product] = newQuantity;
      }
    });
    _saveCartData(); // Save to persistent storage
  }

  int _getCartItemCount() {
    int count = 0;
    cartItems.forEach((product, quantity) {
      count += quantity;
    });
    return count;
  }

  double _getCartTotal() {
    double total = 0;
    cartItems.forEach((product, quantity) {
      total += product.price * quantity;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final cartItemCount = _getCartItemCount();

    final screens = [
      ProductListScreen(onAddToCart: _addToCart),
      CartScreen(
        cartItems: cartItems,
        onCheckout: _clearCart,
        onRemoveItem: _removeFromCart,
        onUpdateQuantity: _updateCartQuantity,
      ),
      ProfileScreen(orders: _orders), // Keep legacy format for compatibility
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, -3),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onTabTapped,
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.grey[400],
            backgroundColor: Colors.white,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 11,
            ),
            items: [
              const BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.storefront_outlined, size: 24),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.storefront, size: 26),
                ),
                label: 'Shop',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.shopping_cart_outlined, size: 24),
                      if (cartItemCount > 0)
                        Positioned(
                          right: -8,
                          top: -8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Text(
                              cartItemCount > 99 ? '99+' : cartItemCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                activeIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.shopping_cart, size: 26),
                      if (cartItemCount > 0)
                        Positioned(
                          right: -8,
                          top: -8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Text(
                              cartItemCount > 99 ? '99+' : cartItemCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                label: 'Cart',
              ),
              const BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.person_outline, size: 24),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.person, size: 26),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
      
      // Floating cart summary (optional - shows when items in cart)
      floatingActionButton: cartItemCount > 0 && _selectedIndex != 1
          ? Container(
              margin: const EdgeInsets.only(bottom: 80),
              child: FloatingActionButton.extended(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1; // Switch to cart
                  });
                },
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.shopping_cart),
                label: Text(
                  '$cartItemCount items • \$${_getCartTotal().toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            )
          : null,
    );
  }
}

// Cart Storage helper class
class CartStorage {
  static const String _cartKey = 'cart_items';

  static Future<Map<Product, int>> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartString = prefs.getString(_cartKey);
      
      if (cartString != null) {
        final cartData = jsonDecode(cartString) as Map<String, dynamic>;
        final loadedCartItems = <Product, int>{};
        
        cartData.forEach((key, value) {
          try {
            final productData = jsonDecode(key) as Map<String, dynamic>;
            final product = Product.fromMap(productData);
            loadedCartItems[product] = value as int;
          } catch (e) {
            debugPrint('Error parsing cart item: $e');
          }
        });
        
        return loadedCartItems;
      }
      return {};
    } catch (e) {
      debugPrint('Error loading cart: $e');
      return {};
    }
  }

  static Future<bool> saveCart(Map<Product, int> cartItems) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = <String, int>{};
      
      cartItems.forEach((product, quantity) {
        cartData[jsonEncode(product.toMap())] = quantity;
      });
      
      await prefs.setString(_cartKey, jsonEncode(cartData));
      return true;
    } catch (e) {
      debugPrint('Error saving cart: $e');
      return false;
    }
  }

  static Future<bool> clearCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cartKey);
      return true;
    } catch (e) {
      debugPrint('Error clearing cart: $e');
      return false;
    }
  }
}