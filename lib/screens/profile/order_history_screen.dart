import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/order_storage.dart'; // ✅ New import

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Map<Product, int>> orders = [];

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  void loadOrders() async {
    final loaded = await OrderStorage.loadOrders();
    setState(() => orders = loaded);
  }

  double calculateTotal(Map<Product, int> order) {
    return order.entries.fold(
      0,
      (sum, entry) => sum + (entry.key.price * entry.value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F4),
      appBar: AppBar(
        backgroundColor: Colors.pink[100],
        title: const Text('My Orders 🧺'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: orders.isEmpty
          ? const Center(
              child: Text(
                "No orders yet 😢",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 15),
              itemBuilder: (_, index) {
                final order = orders[index];
                final total = calculateTotal(order);

                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.pink.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.shade50,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order #${index + 1} 🎁",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...order.entries.map((entry) {
                        final product = entry.key;
                        final quantity = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text("${quantity}x ${product.name}"),
                              ),
                              Text(
                                  "₦${(product.price * quantity).toStringAsFixed(2)}"),
                            ],
                          ),
                        );
                      }).toList(),
                      const Divider(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Total: ₦${total.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
