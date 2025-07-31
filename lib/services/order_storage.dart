// lib/services/order_storage.dart
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/order.dart';

class OrderStorage {
  static const _key = 'babyshop_orders_v2';

  // Create a new order with tracking simulation
  static Future<String> createOrder(
    Map<Product, int> cartItems,
    String deliveryAddress,
  ) async {
    final orderId = _generateOrderId();
    final trackingNumber = _generateTrackingNumber();
    final total = cartItems.entries.fold(
      0.0,
      (sum, entry) => sum + (entry.key.price * entry.value),
    );
    
    final now = DateTime.now();
    final estimatedDelivery = now.add(const Duration(days: 3));
    
    final order = Order(
      id: orderId,
      items: cartItems,
      total: total,
      orderDate: now,
      status: OrderStatus.pending,
      trackingNumber: trackingNumber,
      deliveryAddress: deliveryAddress,
      estimatedDelivery: estimatedDelivery,
      statusHistory: [
        OrderStatusUpdate(
          status: OrderStatus.pending,
          timestamp: now,
          message: 'Order placed successfully',
        ),
      ],
    );

    await _saveOrder(order);
    
    // Simulate order progression
    _simulateOrderProgress(orderId);
    
    return orderId;
  }

  static Future<void> _saveOrder(Order order) async {
    final orders = await loadOrders();
    final existingIndex = orders.indexWhere((o) => o.id == order.id);
    
    if (existingIndex != -1) {
      orders[existingIndex] = order;
    } else {
      orders.insert(0, order);
    }
    
    await _saveAllOrders(orders);
  }

  static Future<void> _saveAllOrders(List<Order> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = orders.map((order) => order.toMap()).toList();
    await prefs.setString(_key, jsonEncode(encoded));
  }

  static Future<List<Order>> loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];

    final decoded = jsonDecode(raw) as List;
    return decoded.map<Order>((orderData) => Order.fromMap(orderData)).toList();
  }

  static Future<Order?> getOrderById(String orderId) async {
    final orders = await loadOrders();
    try {
      return orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateOrderStatus(
    String orderId,
    OrderStatus newStatus, {
    String? message,
  }) async {
    final order = await getOrderById(orderId);
    if (order == null) return;

    final updatedStatusHistory = [...order.statusHistory];
    updatedStatusHistory.add(OrderStatusUpdate(
      status: newStatus,
      timestamp: DateTime.now(),
      message: message ?? _getDefaultStatusMessage(newStatus),
    ));

    final updatedOrder = Order(
      id: order.id,
      items: order.items,
      total: order.total,
      orderDate: order.orderDate,
      status: newStatus,
      trackingNumber: order.trackingNumber,
      deliveryAddress: order.deliveryAddress,
      estimatedDelivery: order.estimatedDelivery,
      statusHistory: updatedStatusHistory,
    );

    await _saveOrder(updatedOrder);
  }

  // Simulate realistic order progression
  static void _simulateOrderProgress(String orderId) {
    Future.delayed(const Duration(minutes: 2), () async {
      await updateOrderStatus(orderId, OrderStatus.confirmed);
    });

    Future.delayed(const Duration(minutes: 5), () async {
      await updateOrderStatus(orderId, OrderStatus.processing);
    });

    Future.delayed(const Duration(hours: 1), () async {
      await updateOrderStatus(orderId, OrderStatus.shipped);
    });

    Future.delayed(const Duration(days: 1), () async {
      await updateOrderStatus(orderId, OrderStatus.outForDelivery);
    });

    Future.delayed(const Duration(days: 2), () async {
      await updateOrderStatus(orderId, OrderStatus.delivered);
    });
  }

  static String _generateOrderId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(1000);
    return 'BSH${timestamp}${random}';
  }

  static String _generateTrackingNumber() {
    final letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final numbers = '0123456789';
    final random = Random();
    
    String result = '';
    for (int i = 0; i < 2; i++) {
      result += letters[random.nextInt(letters.length)];
    }
    for (int i = 0; i < 8; i++) {
      result += numbers[random.nextInt(numbers.length)];
    }
    
    return result;
  }

  static String _getDefaultStatusMessage(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Order received and awaiting confirmation';
      case OrderStatus.confirmed:
        return 'Order confirmed and being prepared';
      case OrderStatus.processing:
        return 'Your items are being packed';
      case OrderStatus.shipped:
        return 'Order has been shipped';
      case OrderStatus.outForDelivery:
        return 'Out for delivery to your address';
      case OrderStatus.delivered:
        return 'Order successfully delivered';
      case OrderStatus.cancelled:
        return 'Order has been cancelled';
    }
  }

  // Legacy support for old order format
  static Future<void> migrateLegacyOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final legacyKey = 'babyshop_orders';
    final legacyRaw = prefs.getString(legacyKey);
    
    if (legacyRaw != null) {
      try {
        final legacyOrders = jsonDecode(legacyRaw) as List;
        final orders = await loadOrders();
        
        for (int i = 0; i < legacyOrders.length; i++) {
          final legacyOrderData = legacyOrders[i] as List;
          final items = <Product, int>{};
          
          for (var entry in legacyOrderData) {
            final product = Product.fromMap(entry['product']);
            final quantity = entry['quantity'] as int;
            items[product] = quantity;
          }
          
          final total = items.entries.fold(
            0.0,
            (sum, entry) => sum + (entry.key.price * entry.value),
          );
          
          final order = Order(
            id: _generateOrderId(),
            items: items,
            total: total,
            orderDate: DateTime.now().subtract(Duration(days: 30 - i)),
            status: OrderStatus.delivered,
            trackingNumber: _generateTrackingNumber(),
            deliveryAddress: 'Legacy Address',
            estimatedDelivery: DateTime.now().subtract(Duration(days: 27 - i)),
            statusHistory: [
              OrderStatusUpdate(
                status: OrderStatus.delivered,
                timestamp: DateTime.now().subtract(Duration(days: 27 - i)),
                message: 'Legacy order - marked as delivered',
              ),
            ],
          );
          
          orders.add(order);
        }
        
        await _saveAllOrders(orders);
        await prefs.remove(legacyKey); // Remove legacy data
      } catch (e) {
        print('Error migrating legacy orders: $e');
      }
    }
  }
}