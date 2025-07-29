// lib/screens/profile/order_history_screen.dart
import 'package:flutter/material.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyOrders = [
      {
        'id': '#BSH1001',
        'status': 'Delivered',
        'items': '2x Baby Lotion, 1x Diaper Pack',
        'date': 'July 26, 2025'
      },
      {
        'id': '#BSH1002',
        'status': 'In Transit',
        'items': '1x Feeding Bottle, 3x Wipes',
        'date': 'July 27, 2025'
      },
    ];

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
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: dummyOrders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 15),
        itemBuilder: (_, index) {
          final order = dummyOrders[index];
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
                Text(order['id']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 5),
                Text("Items: ${order['items']}"),
                Text("Date: ${order['date']}"),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text("Status: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    Chip(
                      label: Text(order['status']!),
                      backgroundColor: order['status'] == 'Delivered'
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                    )
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
