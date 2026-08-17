class CategoryModel {
  final int id;
  final String name;
  final String description;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory CategoryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}