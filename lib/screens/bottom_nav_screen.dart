import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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

  @override
  void initState() {
    super.initState();
    _loadCartData();
  }

  // Load cart data from SharedPreferences
  Future<void> _loadCartData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load cart items
      final cartString = prefs.getString('cart_items');
      if (cartString != null) {
        final cartData = json.decode(cartString) as Map<String, dynamic>;
        final loadedCartItems = <Product, int>{};
        
        cartData.forEach((key, value) {
          final productData = json.decode(key) as Map<String, dynamic>;
          final product = Product.fromMap(productData);
          loadedCartItems[product] = value as int;
        });
        
        setState(() {
          cartItems = loadedCartItems;
        });
      }

      // Load orders
      final ordersString = prefs.getString('orders');
      if (ordersString != null) {
        final ordersData = json.decode(ordersString) as List;
        final loadedOrders = <Map<Product, int>>[];
        
        for (final orderData in ordersData) {
          final orderMap = <Product, int>{};
          (orderData as Map<String, dynamic>).forEach((key, value) {
            final productData = json.decode(key) as Map<String, dynamic>;
            final product = Product.fromMap(productData);
            orderMap[product] = value as int;
          });
          loadedOrders.add(orderMap);
        }
        
        setState(() {
          _orders = loadedOrders;
        });
      }
    } catch (e) {
      debugPrint('Error loading cart data: $e');
    }
  }

  // Save cart data to SharedPreferences
  Future<void> _saveCartData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save cart items
      final cartData = <String, int>{};
      cartItems.forEach((product, quantity) {
        cartData[json.encode(product.toMap())] = quantity;
      });
      await prefs.setString('cart_items', json.encode(cartData));

      // Save orders
      final ordersData = <Map<String, int>>[];
      for (final order in _orders) {
        final orderData = <String, int>{};
        order.forEach((product, quantity) {
          orderData[json.encode(product.toMap())] = quantity;
        });
        ordersData.add(orderData);
      }
      await prefs.setString('orders', json.encode(ordersData));
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

  void _clearCart() {
    if (cartItems.isNotEmpty) {
      // Save current cart as an order before clearing
      setState(() {
        _orders.add(Map<Product, int>.from(cartItems));
        cartItems.clear();
      });

      _saveCartData(); // Save to persistent storage

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
        // onUpdateQuantity: _updateCartQuantity,
      ),
      ProfileScreen(orders: _orders),
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
            selectedItemColor: Colors.pinkAccent,
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
                backgroundColor: Colors.pinkAccent,
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