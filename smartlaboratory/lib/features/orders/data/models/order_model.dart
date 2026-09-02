class Order {
  final int id;
  final String orderNumber;
  final DateTime orderDate;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final String supplierId;
  final String? notes;
  final DateTime? expectedDeliveryDate;

  Order({
    required this.id,
    required this.orderNumber,
    required this.orderDate,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.supplierId,
    this.notes,
    this.expectedDeliveryDate,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      orderNumber: json['order_number'] as String,
      orderDate: DateTime.parse(json['order_date'] as String),
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'] as String,
      supplierId: json['supplier_id'] as String,
      notes: json['notes'] as String?,
      expectedDeliveryDate: json['expected_delivery_date'] != null
          ? DateTime.parse(json['expected_delivery_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_number': orderNumber,
      'order_date': orderDate.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'total_amount': totalAmount,
      'status': status,
      'supplier_id': supplierId,
      'notes': notes,
      'expected_delivery_date': expectedDeliveryDate?.toIso8601String(),
    };
  }
}

class OrderItem {
  final int productId;
  final String productName;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double totalPrice;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit': unit,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }
}
