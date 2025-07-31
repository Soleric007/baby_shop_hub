// lib/models/order.dart
import 'product.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  outForDelivery,
  delivered,
  cancelled
}

class Order {
  final String id;
  final Map<Product, int> items;
  final double total;
  final DateTime orderDate;
  final OrderStatus status;
  final String? trackingNumber;
  final String deliveryAddress;
  final DateTime? estimatedDelivery;
  final List<OrderStatusUpdate> statusHistory;

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.orderDate,
    required this.status,
    this.trackingNumber,
    required this.deliveryAddress,
    this.estimatedDelivery,
    required this.statusHistory,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      items: (map['items'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          Product.fromMap(Map<String, dynamic>.from(value['product'])),
          value['quantity'] as int,
        ),
      ),
      total: (map['total'] as num).toDouble(),
      orderDate: DateTime.parse(map['orderDate']),
      status: OrderStatus.values[map['status']],
      trackingNumber: map['trackingNumber'],
      deliveryAddress: map['deliveryAddress'],
      estimatedDelivery: map['estimatedDelivery'] != null 
          ? DateTime.parse(map['estimatedDelivery']) 
          : null,
      statusHistory: (map['statusHistory'] as List)
          .map((e) => OrderStatusUpdate.fromMap(e))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': items.map((product, quantity) => MapEntry(
        product.id,
        {
          'product': product.toMap(),
          'quantity': quantity,
        },
      )),
      'total': total,
      'orderDate': orderDate.toIso8601String(),
      'status': status.index,
      'trackingNumber': trackingNumber,
      'deliveryAddress': deliveryAddress,
      'estimatedDelivery': estimatedDelivery?.toIso8601String(),
      'statusHistory': statusHistory.map((e) => e.toMap()).toList(),
    };
  }

  String get statusDisplayName {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get statusEmoji {
    switch (status) {
      case OrderStatus.pending:
        return '⏳';
      case OrderStatus.confirmed:
        return '✅';
      case OrderStatus.processing:
        return '📦';
      case OrderStatus.shipped:
        return '🚚';
      case OrderStatus.outForDelivery:
        return '🏃‍♂️';
      case OrderStatus.delivered:
        return '🎉';
      case OrderStatus.cancelled:
        return '❌';
    }
  }
}

class OrderStatusUpdate {
  final OrderStatus status;
  final DateTime timestamp;
  final String? message;

  OrderStatusUpdate({
    required this.status,
    required this.timestamp,
    this.message,
  });

  factory OrderStatusUpdate.fromMap(Map<String, dynamic> map) {
    return OrderStatusUpdate(
      status: OrderStatus.values[map['status']],
      timestamp: DateTime.parse(map['timestamp']),
      message: map['message'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status.index,
      'timestamp': timestamp.toIso8601String(),
      'message': message,
    };
  }
}