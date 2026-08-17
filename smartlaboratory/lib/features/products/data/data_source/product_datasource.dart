import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:smartlaboratory/core/constants/endpoints.dart';
import 'package:smartlaboratory/core/network/dio_client.dart';
import 'package:smartlaboratory/features/products/data/models/product_model.dart';

class ProductDatasource {
  final _logger = Logger("products");
  final _dio = DioClient.instance;

  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await _dio.get(Endpoints.products);
      _logger.info('Fetched products: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((p) => ProductModel.fromJson(p as Map<String, dynamic>))
            .toList();
      }
      throw 'Error fetching products';
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response!.data['error']?.toString() ??
                e.message ??
                'Failed to fetch products'
          : e.message ?? 'Failed to fetch products';
      throw message;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<ProductModel> getProduct(int id) async {
    try {
      final response = await _dio.get('${Endpoints.products}$id/');
      _logger.info('Fetched product $id: ${response.statusCode}');

      if (response.statusCode == 200) {
        return ProductModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw 'Error fetching product';
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response!.data['error']?.toString() ??
                e.message ??
                'Failed to fetch product'
          : e.message ?? 'Failed to fetch product';
      throw message;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final response = await _dio.post(
        Endpoints.products,
        data: product.toJson(),
      );
      _logger.info('Created product: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ProductModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw 'Error creating product';
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response!.data['error']?.toString() ??
                e.message ??
                'Failed to create product'
          : e.message ?? 'Failed to create product';
      throw message;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      final response = await _dio.put(
        '${Endpoints.products}${product.id}/',
        data: product.toJson(),
      );
      _logger.info('Updated product ${product.id}: ${response.statusCode}');

      if (response.statusCode == 200) {
        return ProductModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw 'Error updating product';
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response!.data['error']?.toString() ??
                e.message ??
                'Failed to update product'
          : e.message ?? 'Failed to update product';
      throw message;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      final response = await _dio.delete('${Endpoints.products}$id/');
      _logger.info('Deleted product $id: ${response.statusCode}');

      if (response.statusCode == 204 || response.statusCode == 200) {
        return;
      }
      throw 'Error deleting product';
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response!.data['error']?.toString() ??
                e.message ??
                'Failed to delete product'
          : e.message ?? 'Failed to delete product';
      throw message;
    } catch (e) {
      throw e.toString();
    }
  }
}
