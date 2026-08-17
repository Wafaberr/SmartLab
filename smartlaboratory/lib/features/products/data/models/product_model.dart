import 'package:smartlaboratory/features/products/data/models/category_model.dart';

class ProductModel {
  final int id;
  final String name;
  final String reference;
  final String? barcode;

  final CategoryModel category;

  final dynamic supplier;

  final String unit;

  final double stockQuantity;
  final double minimumStock;
  final double maximumStock;

  final double purchasePrice;

  final String? expirationDate;

  final String storageTemperature;

  final String? image;

  final String description;

  final bool isLowStock;

  ProductModel({
    required this.id,
    required this.name,
    required this.reference,
    required this.barcode,
    required this.category,
    required this.supplier,
    required this.unit,
    required this.stockQuantity,
    required this.minimumStock,
    required this.maximumStock,
    required this.purchasePrice,
    required this.expirationDate,
    required this.storageTemperature,
    required this.image,
    required this.description,
    required this.isLowStock,
  });

  // ============================================================
  // FROM JSON
  // ============================================================

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      if (value == null) {
        return 0.0;
      }

      return double.tryParse(value.toString()) ?? 0.0;
    }

    return ProductModel(
      // --------------------------------------------------------
      // ID
      // --------------------------------------------------------
      id: json['id'] ?? 0,

      // --------------------------------------------------------
      // BASIC INFORMATION
      // --------------------------------------------------------
      name: json['name'] ?? '',

      reference: json['reference'] ?? '',

      barcode: json['barcode'],

      // --------------------------------------------------------
      // CATEGORY
      // --------------------------------------------------------
      //
      // IMPORTANT :
      // Django renvoie "category", pas "categorie".
      //
      // "category": {
      //   "id": 1,
      //   "name": "Réactifs"
      // }
      //
      // --------------------------------------------------------
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : CategoryModel(id: 0, name: 'Sans catégorie', description: ''),

      // --------------------------------------------------------
      // SUPPLIER
      // --------------------------------------------------------
      //
      // Peut être null :
      //
      // "supplier": null
      //
      // --------------------------------------------------------
      supplier: json['supplier'],

      // --------------------------------------------------------
      // UNIT
      // --------------------------------------------------------
      unit: json['unit'] ?? 'piece',

      // --------------------------------------------------------
      // STOCK
      // --------------------------------------------------------
      stockQuantity: toDouble(json['stock_quantity']),

      minimumStock: toDouble(json['minimum_stock']),

      maximumStock: toDouble(json['maximum_stock']),

      // --------------------------------------------------------
      // PRICE
      // --------------------------------------------------------
      purchasePrice: toDouble(json['purchase_price']),

      // --------------------------------------------------------
      // EXPIRATION
      // --------------------------------------------------------
      expirationDate: json['expiration_date'] as String?,

      // --------------------------------------------------------
      // STORAGE
      // --------------------------------------------------------
      storageTemperature: json['storage_temperature'] ?? '',

      // --------------------------------------------------------
      // IMAGE
      // --------------------------------------------------------
      image: json['image'] as String?,

      // --------------------------------------------------------
      // DESCRIPTION
      // --------------------------------------------------------
      description: json['description'] ?? '',

      // --------------------------------------------------------
      // LOW STOCK
      // --------------------------------------------------------
      isLowStock: json['is_low_stock'] ?? false,
    );
  }

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'name': name,

      'reference': reference,

      // Django attend l'ID de la catégorie
      'category': category.id,

      // Peut être null
      'supplier': supplier,

      'unit': unit,

      'barcode': barcode,

      // Django utilise snake_case
      'stock_quantity': stockQuantity,

      'minimum_stock': minimumStock,

      'maximum_stock': maximumStock,

      'purchase_price': purchasePrice,

      'expiration_date': expirationDate,

      'storage_temperature': storageTemperature,

      'image': image,

      'description': description,

      'is_low_stock': isLowStock,
    };
  }
}
