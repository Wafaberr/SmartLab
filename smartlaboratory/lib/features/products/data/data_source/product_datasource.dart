import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logging/logging.dart';
import 'package:smartlaboratory/core/constants/endpoints.dart';
import 'package:smartlaboratory/core/network/dio_client.dart';
import 'package:smartlaboratory/features/products/data/models/product_model.dart';
import 'package:smartlaboratory/features/products/data/models/stock_movement_model.dart';

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

  Future<ProductModel> createProduct(
    ProductModel product,
    File? imageFile,
  ) async {
    try {
      final formData = FormData();

      // ==============================
      // DONNÉES DU PRODUIT
      // ==============================

      formData.fields.add(MapEntry('name', product.name));

      formData.fields.add(MapEntry('reference', product.reference));

      formData.fields.add(
        MapEntry('category_id', product.category.id.toString()),
      );

      if (product.supplier != null) {
        formData.fields.add(
          MapEntry('supplier_id', product.supplier.toString()),
        );
      }

      formData.fields.add(MapEntry('unit', product.unit));

      if (product.barcode != null && product.barcode!.isNotEmpty) {
        formData.fields.add(MapEntry('barcode', product.barcode!));
      }

      formData.fields.add(
        MapEntry('stock_quantity', product.stockQuantity.toString()),
      );

      formData.fields.add(
        MapEntry('minimum_stock', product.minimumStock.toString()),
      );

      formData.fields.add(
        MapEntry('maximum_stock', product.maximumStock.toString()),
      );

      formData.fields.add(
        MapEntry('purchase_price', product.purchasePrice.toString()),
      );

      if (product.expirationDate != null &&
          product.expirationDate!.isNotEmpty) {
        formData.fields.add(
          MapEntry('expiration_date', product.expirationDate!),
        );
      }

      formData.fields.add(
        MapEntry('storage_temperature', product.storageTemperature),
      );

      formData.fields.add(MapEntry('description', product.description));

      // ==============================
      // IMAGE
      // ==============================

      if (imageFile != null) {
        final fileName = imageFile.path.split(Platform.pathSeparator).last;

        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(imageFile.path, filename: fileName),
          ),
        );
      }

      // ==============================
      // REQUEST
      // ==============================

      final response = await _dio.post(
        Endpoints.products,
        data: formData,
        options: Options(contentType: Headers.multipartFormDataContentType),
      );

      _logger.info('Created product: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ProductModel.fromJson(Map<String, dynamic>.from(response.data));
      }

      throw Exception('Error creating product');
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final message = responseData is Map
          ? responseData['error']?.toString() ??
                responseData['detail']?.toString() ??
                responseData.entries
                    .map((entry) => '${entry.key}: ${entry.value}')
                    .join(', ')
          : e.message ?? 'Failed to create product';

      throw Exception(message);
    } catch (e) {
      rethrow;
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

  Future<StockMovementModel> createMovement({
    required int productId,
    required String movementType,
    required double quantity,
    String reason = '',
    String comment = '',
  }) async {
    final response = await _dio.post(
      Endpoints.productMovements(productId),
      data: {
        'movement_type': movementType,
        'quantity': quantity,
        'reason': reason,
        'comment': comment,
      },
    );
    return StockMovementModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<List<StockMovementModel>> getMovements(int productId) async {
    final response = await _dio.get(Endpoints.productMovements(productId));
    return (response.data as List<dynamic>)
        .map((item) => StockMovementModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
