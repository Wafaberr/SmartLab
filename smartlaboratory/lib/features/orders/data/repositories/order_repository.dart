import 'package:smartlaboratory/core/constants/endpoints.dart';
import 'package:smartlaboratory/core/network/dio_client.dart';
import '../models/order_model.dart';

class OrderRepository {
  final DioClient _dioClient;

  OrderRepository({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient.instance;

  Future<List<Order>> getOrders({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (status != null) queryParameters['status'] = status;
      if (startDate != null) {
        queryParameters['order_date_after'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParameters['order_date_before'] = endDate.toIso8601String();
      }

      final response = await _dioClient.dio.get(
        '${Endpoints.baseUrl}orders/',
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );

      if (response.statusCode == 200) {
        List<dynamic> results = [];
        if (response.data is List<dynamic>) {
          results = response.data as List<dynamic>;
        } else if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          results = data['results'] as List<dynamic>? ?? [];
        }
        return results
            .map((json) => Order.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Erreur lors du chargement des commandes');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Order> getOrder(int id) async {
    try {
      final response = await _dioClient.dio.get(
        '${Endpoints.baseUrl}orders/$id/',
      );

      if (response.statusCode == 200) {
        return Order.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Erreur lors du chargement de la commande');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Order> createOrder({
    required String supplierId,
    required List<Map<String, dynamic>> items,
    String? notes,
    DateTime? expectedDeliveryDate,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '${Endpoints.baseUrl}orders/',
        data: {
          'supplier_id': supplierId,
          'items': items,
          'notes': notes,
          'expected_delivery_date': expectedDeliveryDate?.toIso8601String(),
        },
      );

      if (response.statusCode == 201) {
        return Order.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Erreur lors de la création de la commande');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<Order> updateOrder(
    int id, {
    String? status,
    String? notes,
    DateTime? expectedDeliveryDate,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (status != null) data['status'] = status;
      if (notes != null) data['notes'] = notes;
      if (expectedDeliveryDate != null) {
        data['expected_delivery_date'] = expectedDeliveryDate.toIso8601String();
      }

      final response = await _dioClient.dio.patch(
        '${Endpoints.baseUrl}orders/$id/',
        data: data,
      );

      if (response.statusCode == 200) {
        return Order.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Erreur lors de la mise à jour de la commande');
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<void> cancelOrder(int id) async {
    try {
      final response = await _dioClient.dio.patch(
        '${Endpoints.baseUrl}orders/$id/',
        data: {'status': 'cancelled'},
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur lors de l\'annulation de la commande');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}
