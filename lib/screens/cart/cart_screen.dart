import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../cart/checkout_screen.dart';

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
                    subtitle: Text("Qty: $quantity\n₦${product.price}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Remove from cart?"),
                            content: Text(
                                "Are you sure you want to remove ${product.name}?"),
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
              child: ElevatedButton.icon(
                icon: const Icon(Icons.shopping_bag_rounded, size: 20),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckoutPage(
                        cartItems: cartItems,
                        onPlaceOrder: () {
                          // Save to orders, clear cart, navigate back or to orders screen
                        },
                      ),
                    ),
                  );

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[300],
                  foregroundColor: Colors.white,
                  elevation: 4,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                label: const Text(
                  "Proceed to Checkout",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
    );
  }
}
