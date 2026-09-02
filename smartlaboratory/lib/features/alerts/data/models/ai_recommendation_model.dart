class AIRecommendation {
  final int id;
  final int productId;
  final String productName;
  final String productReference;
  final String analysisType;
  final String priority;
  final double currentStock;
  final double minimumStock;
  final double dailyConsumption;
  final int? estimatedDaysRemaining;
  final int? daysUntilExpiration;
  final DateTime? expirationDate;
  final String recommendation;
  final double? recommendedQuantity;
  final bool isResolved;
  final DateTime createdAt;
  final DateTime updatedAt;

  AIRecommendation({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productReference,
    required this.analysisType,
    required this.priority,
    required this.currentStock,
    required this.minimumStock,
    required this.dailyConsumption,
    this.estimatedDaysRemaining,
    this.daysUntilExpiration,
    this.expirationDate,
    required this.recommendation,
    this.recommendedQuantity,
    required this.isResolved,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AIRecommendation.fromJson(Map<String, dynamic> json) {
    return AIRecommendation(
      id: json['id'] as int? ?? 0,
      productId: json['product'] as int? ?? 0,
      productName: json['product_name'] as String? ?? 'Produit',
      productReference: json['product_reference'] as String? ?? '',
      analysisType: json['analysis_type'] as String? ?? 'low_stock',
      priority: json['priority'] as String? ?? 'medium',
      currentStock: (json['current_stock'] as num?)?.toDouble() ?? 0.0,
      minimumStock: (json['minimum_stock'] as num?)?.toDouble() ?? 0.0,
      dailyConsumption: (json['daily_consumption'] as num?)?.toDouble() ?? 0.0,
      estimatedDaysRemaining: json['estimated_days_remaining'] as int?,
      daysUntilExpiration: json['days_until_expiration'] as int?,
      expirationDate: json['expiration_date'] != null
          ? DateTime.parse(json['expiration_date'] as String)
          : null,
      recommendation: json['recommendation'] as String? ?? '',
      recommendedQuantity: (json['recommended_quantity'] as num?)?.toDouble(),
      isResolved: json['is_resolved'] as bool? ?? false,
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'product': productId,
    'product_name': productName,
    'product_reference': productReference,
    'analysis_type': analysisType,
    'priority': priority,
    'current_stock': currentStock,
    'minimum_stock': minimumStock,
    'daily_consumption': dailyConsumption,
    'estimated_days_remaining': estimatedDaysRemaining,
    'days_until_expiration': daysUntilExpiration,
    'expiration_date': expirationDate?.toIso8601String(),
    'recommendation': recommendation,
    'recommended_quantity': recommendedQuantity,
    'is_resolved': isResolved,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  AIRecommendation copyWith({
    int? id,
    int? productId,
    String? productName,
    String? productReference,
    String? analysisType,
    String? priority,
    double? currentStock,
    double? minimumStock,
    double? dailyConsumption,
    int? estimatedDaysRemaining,
    int? daysUntilExpiration,
    DateTime? expirationDate,
    String? recommendation,
    double? recommendedQuantity,
    bool? isResolved,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => AIRecommendation(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    productName: productName ?? this.productName,
    productReference: productReference ?? this.productReference,
    analysisType: analysisType ?? this.analysisType,
    priority: priority ?? this.priority,
    currentStock: currentStock ?? this.currentStock,
    minimumStock: minimumStock ?? this.minimumStock,
    dailyConsumption: dailyConsumption ?? this.dailyConsumption,
    estimatedDaysRemaining:
        estimatedDaysRemaining ?? this.estimatedDaysRemaining,
    daysUntilExpiration: daysUntilExpiration ?? this.daysUntilExpiration,
    expirationDate: expirationDate ?? this.expirationDate,
    recommendation: recommendation ?? this.recommendation,
    recommendedQuantity: recommendedQuantity ?? this.recommendedQuantity,
    isResolved: isResolved ?? this.isResolved,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
