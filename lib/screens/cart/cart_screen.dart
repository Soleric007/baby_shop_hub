// lib/screens/cart/cart_screen.dart
import 'package:flutter/material.dart';
import '../../models/product.dart';

class CartScreen extends StatelessWidget {
  final Map<Product, int> cartItems;
  final VoidCallback onCheckout;
  final Function(Product) onRemoveItem;

  const CartScreen({
    super.key,
    required this.cartItems,
    required this.onCheckout,
    required this.onRemoveItem,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: const Text('Your Cart 🛒'),
        centerTitle: true,
        backgroundColor: Colors.pink[100],
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Text("Cart is empty 💔",
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
            )
          : ListView(
              padding: const EdgeInsets.all(12),
              children: cartItems.entries.map((entry) {
                final product = entry.key;
                final quantity = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Image.network(product.imageUrl, width: 50),
                    title: Text(product.name),
                    subtitle: Text("Qty: $quantity\n\$${product.price}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Remove from cart?"),
                            content: Text("Are you sure you want to remove ${product.name}?"),
                            actions: [
                              TextButton(
                                child: const Text("Cancel"),
                                onPressed: () => Navigator.pop(context),
                              ),
                              TextButton(
                                child: const Text("Remove"),
                                onPressed: () {
                                  onRemoveItem(product);
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton(
                onPressed: () {
                  onCheckout();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Order placed! 🍼")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Proceed to checkout", style: TextStyle(fontSize: 16)),
              ),
            ),
    );
  }
}
