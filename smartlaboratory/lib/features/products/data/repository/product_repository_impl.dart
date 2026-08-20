import 'dart:io';

import 'package:smartlaboratory/features/products/data/data_source/product_datasource.dart';
import 'package:smartlaboratory/features/products/data/models/product_model.dart';
import 'package:smartlaboratory/features/products/data/models/stock_movement_model.dart';
import 'package:smartlaboratory/features/products/domain/repository/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductDatasource _productDatasource = ProductDatasource();

  @override
  Future<void> createProducts({ProductModel? product,File? imageFile}) async {
    try {
      if (product == null) throw 'Product cannot be null';
      await _productDatasource.createProduct(product,imageFile);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteProducts({ProductModel? product}) async {
    try {
      if (product == null) throw 'Product cannot be null';
      await _productDatasource.deleteProduct(product.id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ProductModel> getProduct(int id) async {
    try {
      return await _productDatasource.getProduct(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      return await _productDatasource.getProducts();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ProductModel> updateProducts({ProductModel? product}) async {
    try {
      if (product == null) throw 'Product cannot be null';
      return await _productDatasource.updateProduct(product);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<StockMovementModel> createMovement({required int productId, required String movementType, required double quantity, String reason = '', String comment = ''}) {
    return _productDatasource.createMovement(productId: productId, movementType: movementType, quantity: quantity, reason: reason, comment: comment);
  }

  @override
  Future<List<StockMovementModel>> getMovements(int productId) {
    return _productDatasource.getMovements(productId);
  }
}
