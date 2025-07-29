import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/order_storage.dart'; // ✅ Add this line

class CheckoutPage extends StatelessWidget {
  final Map<Product, int> cartItems;
  final VoidCallback onPlaceOrder;

  const CheckoutPage({
    super.key,
    required this.cartItems,
    required this.onPlaceOrder,
  });

  double getTotal() {
    return cartItems.entries
        .fold(0.0, (sum, entry) => sum + (entry.key.price * entry.value));
  }

  @override
  Widget build(BuildContext context) {
    final entries = cartItems.entries.toList();

    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: const Text('Checkout 🍼'),
        backgroundColor: Colors.pink[200],
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final product = entry.key;
                final quantity = entry.value;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(product.imageUrl),
                  ),
                  title: Text(product.name),
                  subtitle: Text(
                      "$quantity x ₦${product.price.toStringAsFixed(2)}"),
                  trailing: Text(
                    "₦${(product.price * quantity).toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
          const Divider(thickness: 2),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text("₦${getTotal().toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
              ),
              onPressed: () async {
                final existingOrders = await OrderStorage.loadOrders();
                final newOrder = Map<Product, int>.from(cartItems);

                await OrderStorage.saveOrders([...existingOrders, newOrder]);

                onPlaceOrder(); // ✅ Still calls your original callback
                if (context.mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.check_circle),
              label: const Text(
                "Place Order 🎀",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
