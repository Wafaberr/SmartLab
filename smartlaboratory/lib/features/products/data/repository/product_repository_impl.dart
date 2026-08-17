import 'package:smartlaboratory/features/products/data/data_source/product_datasource.dart';
import 'package:smartlaboratory/features/products/data/models/product_model.dart';
import 'package:smartlaboratory/features/products/domain/repository/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductDatasource _productDatasource = ProductDatasource();

  @override
  Future<void> createProducts({ProductModel? product}) async {
    try {
      if (product == null) throw 'Product cannot be null';
      await _productDatasource.createProduct(product);
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
}
