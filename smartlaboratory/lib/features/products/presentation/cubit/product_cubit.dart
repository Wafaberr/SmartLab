import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:smartlaboratory/features/products/data/models/product_model.dart';
import 'package:smartlaboratory/features/products/data/models/stock_movement_model.dart';
import 'package:smartlaboratory/features/products/domain/repository/product_repository.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository productRepository;

  ProductCubit(this.productRepository) : super(ProductInitial());

  Future<void> getProducts() async {
    emit(ProductLoading());
    try {
      final products = await productRepository.getProducts();
      emit(ProductLoaded(products: products));
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  Future<void> getProduct(int id) async {
    emit(ProductLoading());
    try {
      final product = await productRepository.getProduct(id);
      emit(ProductDetailLoaded(product: product));
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  Future<void> createProduct(ProductModel product, {File? imageFile}) async {
    emit(ProductLoading());

    try {
      await productRepository.createProducts(
        product: product,
        imageFile: imageFile,
      );

      await getProducts();
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    emit(ProductLoading());
    try {
      await productRepository.updateProducts(product: product);
      // After updating, refresh the products list
      await getProducts();
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  Future<void> deleteProduct(ProductModel product) async {
    emit(ProductLoading());
    try {
      await productRepository.deleteProducts(product: product);
      // After deleting, refresh the products list
      await getProducts();
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  Future<void> createMovement({
    required int productId,
    required String movementType,
    required double quantity,
    String reason = '',
    String comment = '',
  }) async {
    try {
      await productRepository.createMovement(
        productId: productId,
        movementType: movementType,
        quantity: quantity,
        reason: reason,
        comment: comment,
      );
      await getProduct(productId);
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  Future<List<StockMovementModel>> getMovements(int productId) {
    return productRepository.getMovements(productId);
  }

  void clearError() {
    emit(ProductInitial());
  }
}
