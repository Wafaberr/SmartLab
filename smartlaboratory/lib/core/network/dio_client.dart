import 'package:dio/dio.dart';
import 'package:smartlaboratory/core/constants/endpoints.dart';
import 'package:smartlaboratory/core/storage/shared_perefs_service.dart';

class DioClient {
  DioClient._() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.extra['skipAuth'] == true) {
            handler.next(options);
            return;
          }
          final token = await SharedPerefsService.instance.getString('token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final options = error.requestOptions;
          if (error.response?.statusCode != 401 ||
              options.extra['retried'] == true) {
            handler.next(error);
            return;
          }

          final refreshToken = await SharedPerefsService.instance.getString(
            'refresh_token',
          );
          if (refreshToken == null || refreshToken.isEmpty) {
            handler.next(error);
            return;
          }

          try {
            final refreshResponse = await dio.post(
              Endpoints.refreshToken,
              data: {'refresh': refreshToken},
              options: Options(extra: {'skipAuth': true}),
            );
            final accessToken = refreshResponse.data['access']?.toString();
            if (accessToken == null || accessToken.isEmpty) {
              handler.next(error);
              return;
            }

            await SharedPerefsService.instance.setString('token', accessToken);
            options.headers['Authorization'] = 'Bearer $accessToken';
            options.extra['retried'] = true;
            handler.resolve(await dio.fetch(options));
          } on DioException {
            await SharedPerefsService.instance.remove('token');
            await SharedPerefsService.instance.remove('refresh_token');
            handler.next(error);
          }
        },
      ),
    );
  }

  static final DioClient instance = DioClient._();

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: Endpoints.baseUrl,
      sendTimeout: Duration(seconds: 15),
      receiveTimeout: Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
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
