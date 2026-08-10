// data/datasources/password_reset_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:smartlaboratory/core/constants/endpoints.dart';
import 'package:smartlaboratory/core/network/dio_client.dart';
import 'package:smartlaboratory/features/auth/data/models/password_model.dart';

class PasswordResetRemoteDataSource {
   final _dio = DioClient.instance;
  

  Future<Map<String, dynamic>> requestPasswordReset(
    PasswordResetRequestModel request,
  ) async {
    try {
      final response = await _dio.post(
        Endpoints.forgotPassword,
        data: request.toJson(),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> confirmPasswordReset(
    PasswordResetConfirmModel request,
  ) async {
    try {
      final response = await _dio.post(
        Endpoints.resetPassword,
        data: request.toJson(),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> validateToken(String token) async {
    try {
      final response = await _dio.get(
        '${Endpoints.resetPassword}validate/$token/',
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<Map<String, dynamic>> changePassword(
    PasswordChangeModel request,
  ) async {
    try {
      final response = await _dio.post(
        Endpoints.changePassword,
        data: request.toJson(),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Map<String, dynamic> _handleResponse(Response response) {
    final data = response.data as Map<String, dynamic>? ?? {};

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      return data;
    }

    final message = data['error'] ?? data['message'] ?? 'Erreur serveur';
    throw message;
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response?.data is Map<String, dynamic>) {
        return error.response!.data['message']?.toString() ??
            error.message ??
            'Erreur réseau';
      }
      return error.message ?? 'Erreur réseau';
    }

    return error.toString();
  }
}
