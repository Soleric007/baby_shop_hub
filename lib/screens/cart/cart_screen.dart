// lib/screens/cart/cart_screen.dart
import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../cart/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  final Map<Product, int> cartItems;
  final VoidCallback onCheckout;
  final Function(Product) onRemoveItem;
  final Function(Product, int) onUpdateQuantity; // Added this parameter

  const CartScreen({
    super.key,
    required this.cartItems,
    required this.onCheckout,
    required this.onRemoveItem,
    required this.onUpdateQuantity, // Added this parameter
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
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        // Product Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            product.imageUrl, 
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Product Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "₦${product.price.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.pink[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Quantity Controls
                        Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Decrease quantity button
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.pink[100],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: IconButton(
                                    onPressed: quantity > 1
                                        ? () => onUpdateQuantity(product, quantity - 1)
                                        : null,
                                    icon: const Icon(Icons.remove, size: 18),
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    color: quantity > 1 ? Colors.pink[700] : Colors.grey,
                                  ),
                                ),
                                
                                // Quantity display
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.pink[200]!),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    quantity.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                
                                // Increase quantity button
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.pink[100],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: IconButton(
                                    onPressed: () => onUpdateQuantity(product, quantity + 1),
                                    icon: const Icon(Icons.add, size: 18),
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    color: Colors.pink[700],
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Remove button
                            TextButton.icon(
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
                              icon: const Icon(Icons.delete_outline, size: 16),
                              label: const Text("Remove", style: TextStyle(fontSize: 12)),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red[600],
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              ),
                            ),
                          ],
                        ),
                      ],
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
                          // This callback will clear the cart
                          onCheckout();
                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Order placed successfully! 🎉'),
                              backgroundColor: Colors.green,
                            ),
                          );
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