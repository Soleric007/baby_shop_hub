import 'package:flutter/material.dart';
import '../../models/product.dart';

class CheckoutScreen extends StatelessWidget {
  final List<Product> cartItems;
  final VoidCallback onPlaceOrder;

  const CheckoutScreen({super.key, required this.cartItems, required this.onPlaceOrder});

  @override
  Widget build(BuildContext context) {
    double total = cartItems.fold(0, (sum, item) => sum + item.price);

    return Scaffold(
      appBar: AppBar(
        title: const Text("🧾 Checkout"),
        backgroundColor: Colors.pink[100],
      ),
      backgroundColor: Colors.pink[50],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Confirm Your Order",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ...cartItems.map((item) => ListTile(
                  title: Text(item.name),
                  trailing: Text("\$${item.price.toStringAsFixed(2)}"),
                )),
            const Divider(),
            Text(
              "Total: \$${total.toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: onPlaceOrder,
              child: const Text("Place Order"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
