part of 'product_cubit.dart';

@immutable
sealed class ProductState {}

final class ProductInitial extends ProductState {}

final class ProductLoading extends ProductState {
  final List<ProductModel>? products;

  ProductLoading({this.products});
}

final class ProductDetailLoading extends ProductState {
  final List<ProductModel>? products;

  ProductDetailLoading({this.products});
}

final class ProductLoaded extends ProductState {
  final List<ProductModel> products;

  ProductLoaded({required this.products});
}

final class ProductDetailLoaded extends ProductState {
  final ProductModel product;
  final List<ProductModel>? products;

  ProductDetailLoaded({required this.product, this.products});
}

final class ProductError extends ProductState {
  final String message;

  ProductError({required this.message});
}
