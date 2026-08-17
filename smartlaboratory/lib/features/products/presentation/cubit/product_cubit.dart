import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:smartlaboratory/features/products/data/models/product_model.dart';
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

  Future<void> createProduct(ProductModel product) async {
    emit(ProductLoading());
    try {
      await productRepository.createProducts(product: product);
      // After creating, refresh the products list
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

  void clearError() {
    emit(ProductInitial());
  }
}
