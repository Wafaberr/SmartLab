import 'package:smartlaboratory/features/products/data/models/product_model.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> getProduct(int id);
  Future<void> createProducts({ProductModel product});
  Future<ProductModel> updateProducts({ProductModel product});
  Future<void> deleteProducts({ProductModel product});
}
