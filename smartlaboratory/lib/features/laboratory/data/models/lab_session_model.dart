class LabSessionModel {
  final int id;
  final String analysisTypeName;
  final String technicianName;
  final int sampleCount;
  final String comment;
  final String status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final List<SessionConsumptionModel> consumptions;

  const LabSessionModel({
    required this.id,
    required this.analysisTypeName,
    required this.technicianName,
    required this.sampleCount,
    required this.comment,
    required this.status,
    required this.startedAt,
    required this.completedAt,
    required this.consumptions,
  });

  factory LabSessionModel.fromJson(Map<String, dynamic> json) {
    final rawConsumptions = json['consumptions'] as List<dynamic>? ?? [];
    return LabSessionModel(
      id: json['id'] as int? ?? 0,
      analysisTypeName: json['analysis_type_name']?.toString() ?? '',
      technicianName: json['technician_name']?.toString() ?? '',
      sampleCount: json['sample_count'] as int? ?? 0,
      comment: json['comment']?.toString() ?? '',
      status: json['status']?.toString() ?? 'draft',
      startedAt: DateTime.tryParse(json['started_at']?.toString() ?? ''),
      completedAt: DateTime.tryParse(json['completed_at']?.toString() ?? ''),
      consumptions: rawConsumptions
          .map(
            (item) =>
                SessionConsumptionModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class SessionConsumptionModel {
  final int id;
  final String productName;
  final double plannedQuantity;
  final double actualQuantity;
  final String unit;

  const SessionConsumptionModel({
    required this.id,
    required this.productName,
    required this.plannedQuantity,
    required this.actualQuantity,
    required this.unit,
  });

  factory SessionConsumptionModel.fromJson(Map<String, dynamic> json) {
    double number(dynamic value) => double.tryParse('$value') ?? 0;
    final product = json['product'];
    final productName = product is Map<String, dynamic>
        ? product['name']?.toString() ?? 'Produit'
        : 'Produit';
    return SessionConsumptionModel(
      id: json['id'] as int? ?? 0,
      productName: productName,
      plannedQuantity: number(json['planned_quantity']),
      actualQuantity: number(json['actual_quantity']),
      unit: json['unit']?.toString() ?? '',
    );
  }
}
