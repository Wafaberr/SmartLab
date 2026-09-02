import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:smartlaboratory/features/products/data/models/category_model.dart';
import 'package:smartlaboratory/features/products/data/models/product_model.dart';
import 'package:smartlaboratory/features/products/data/models/stock_movement_model.dart';
import 'package:smartlaboratory/features/products/domain/repository/product_repository.dart';
import 'package:smartlaboratory/features/products/presentation/cubit/product_cubit.dart';

class _FakeProductRepository implements ProductRepository {
  @override
  Future<List<ProductModel>> getProducts() async {
    return [
      ProductModel(
        id: 1,
        name: 'Produit test',
        reference: 'REF-001',
        barcode: '123456',
        category: CategoryModel(id: 1, name: 'Réactifs', description: ''),
        supplier: null,
        unit: 'pièce',
        stockQuantity: 12,
        minimumStock: 8,
        maximumStock: 50,
        purchasePrice: 10,
        expirationDate: '2026-12-31',
        storageTemperature: '2-8°C',
        image: null,
        description: 'Test',
        isLowStock: false,
      ),
    ];
  }

  @override
  Future<ProductModel> getProduct(int id) async {
    return ProductModel(
      id: id,
      name: 'Produit test',
      reference: 'REF-001',
      barcode: '123456',
      category: CategoryModel(id: 1, name: 'Réactifs', description: ''),
      supplier: null,
      unit: 'pièce',
      stockQuantity: 6,
      minimumStock: 8,
      maximumStock: 50,
      purchasePrice: 10,
      expirationDate: '2026-12-31',
      storageTemperature: '2-8°C',
      image: null,
      description: 'Test',
      isLowStock: true,
    );
  }

  @override
  Future<void> createProducts({ProductModel? product, File? imageFile}) async {}

  @override
  Future<ProductModel> updateProducts({ProductModel? product}) async =>
      product ??
      ProductModel(
        id: 1,
        name: 'Produit test',
        reference: 'REF-001',
        barcode: '123456',
        category: CategoryModel(id: 1, name: 'Réactifs', description: ''),
        supplier: null,
        unit: 'pièce',
        stockQuantity: 12,
        minimumStock: 8,
        maximumStock: 50,
        purchasePrice: 10,
        expirationDate: '2026-12-31',
        storageTemperature: '2-8°C',
        image: null,
        description: 'Test',
        isLowStock: false,
      );

  @override
  Future<void> deleteProducts({ProductModel? product}) async {}

  @override
  Future<StockMovementModel> createMovement({
    required int productId,
    required String movementType,
    required double quantity,
    String reason = '',
    String comment = '',
  }) async {
    return StockMovementModel(
      id: 1,
      movementType: movementType,
      quantity: quantity,
      stockBefore: 10,
      stockAfter: 12,
      reason: reason,
      comment: comment,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<StockMovementModel>> getMovements(int productId) async => [];
}

void main() {
  test(
    'Product detail fetch keeps the last list available while loading and after detail load',
    () async {
      final cubit = ProductCubit(_FakeProductRepository());

      await cubit.getProducts();
      expect(cubit.state, isA<ProductLoaded>());

      final future = cubit.getProduct(1);
      expect(cubit.state, isA<ProductDetailLoading>());
      expect((cubit.state as ProductDetailLoading).products, hasLength(1));

      await future;
      expect(cubit.state, isA<ProductDetailLoaded>());
      expect((cubit.state as ProductDetailLoaded).products, hasLength(1));
    },
  );
}
