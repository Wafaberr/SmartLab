import 'package:dio/dio.dart';
import 'package:smartlaboratory/core/constants/endpoints.dart';

class DioClient {
  DioClient._();

  static final DioClient instance = DioClient._();

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: Endpoints.baseUrl,
      sendTimeout: Duration(seconds: 15),
      receiveTimeout: Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) {
    return dio.get(path, queryParameters: queryParameters, options: options);
  }

  Future<Response> post(String path, {dynamic data, Options? options}) {
    return dio.post(path, data: data, options: options);
  }

  Future<Response> put(String path, {dynamic data, Options? options}) {
    return dio.put(path, data: data, options: options);
  }

  Future<Response> delete(String path, {dynamic data, Options? options}) {
    return dio.delete(path, data: data, options: options);
  }

  
}
