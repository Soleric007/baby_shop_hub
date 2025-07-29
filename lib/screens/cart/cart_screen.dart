import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../cart/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final List<Product> cartItems;
  final Function(List<Product>) onCheckout;

  const CartScreen({
    super.key,
    required this.cartItems,
    required this.onCheckout,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<Product> _cartItems;

  @override
  void initState() {
    super.initState();
    _cartItems = List.from(widget.cartItems);
  }

  void _handleCheckout() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          cartItems: _cartItems,
          onPlaceOrder: () {
            Navigator.pop(context, true);
          },
        ),
      ),
    );

    // If checkout was successful, clear the cart
    if (result == true) {
      setState(() {
        _cartItems.clear();
      });
      widget.onCheckout(_cartItems); // Inform parent to update cart
    }
  }

  @override
  Widget build(BuildContext context) {
    double total = _cartItems.fold(0.0, (sum, item) => sum + item.price);

    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: const Text('🛒 My Cart'),
        backgroundColor: Colors.pink[100],
      ),
      body: _cartItems.isEmpty
          ? const Center(
              child: Text(
                "🍼 Your cart is empty, little one!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.pink,
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final product = _cartItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        color: Colors.pink[100],
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(product.imageUrl),
                          ),
                          title: Text(product.name),
                          subtitle:
                              Text("\$${product.price.toStringAsFixed(2)}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _cartItems.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        "Total: \$${total.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _handleCheckout,
                        icon: const Icon(Icons.shopping_bag),
                        label: const Text("Proceed to Checkout"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
