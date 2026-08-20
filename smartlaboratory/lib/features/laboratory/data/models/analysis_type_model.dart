class AnalysisTypeModel {
  final int id;
  final String name;
  final int durationMinutes;
  final double price;

  const AnalysisTypeModel({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.price,
  });

  factory AnalysisTypeModel.fromJson(Map<String, dynamic> json) =>
      AnalysisTypeModel(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        durationMinutes: json['duration_minutes'] ?? 0,
        price: double.tryParse('${json['price']}') ?? 0,
      );
}
