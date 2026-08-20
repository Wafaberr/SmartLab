class StockMovementModel {
  final int id;
  final String movementType;
  final double quantity;
  final double stockBefore;
  final double stockAfter;
  final String reason;
  final String comment;
  final DateTime? createdAt;

  const StockMovementModel({
    required this.id,
    required this.movementType,
    required this.quantity,
    required this.stockBefore,
    required this.stockAfter,
    required this.reason,
    required this.comment,
    required this.createdAt,
  });

  factory StockMovementModel.fromJson(Map<String, dynamic> json) {
    double number(dynamic value) => double.tryParse('$value') ?? 0;
    return StockMovementModel(
      id: json['id'] ?? 0,
      movementType: json['movement_type'] ?? 'entry',
      quantity: number(json['quantity']),
      stockBefore: number(json['stock_before']),
      stockAfter: number(json['stock_after']),
      reason: json['reason'] ?? '',
      comment: json['comment'] ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}
