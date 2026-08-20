import 'dart:io';

import 'package:smartlaboratory/features/products/data/models/product_model.dart';
import 'package:smartlaboratory/features/products/data/models/stock_movement_model.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> getProduct(int id);
  Future<void> createProducts({ProductModel? product, File? imageFile});
  Future<ProductModel> updateProducts({ProductModel product});
  Future<void> deleteProducts({ProductModel product});
  Future<StockMovementModel> createMovement({required int productId, required String movementType, required double quantity, String reason, String comment});
  Future<List<StockMovementModel>> getMovements(int productId);
}
