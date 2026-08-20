import 'package:dio/dio.dart';

import 'package:logging/logging.dart';
import 'package:smartlaboratory/core/constants/endpoints.dart';
import 'package:smartlaboratory/core/network/dio_client.dart';
import 'package:smartlaboratory/core/storage/shared_perefs_service.dart';
import 'package:smartlaboratory/features/auth/data/models/user_model.dart';

class AuthRemoteDatasource {
  final _logger = Logger("auth");
  final _dio = DioClient.instance;

  Future<User> signup(String name, String email, String password) async {
    try {
      _logger.info('Attempting signup with: $email');
      _logger.info('Calling ${Endpoints.baseUrl}${Endpoints.signup}');
      final response = await _dio.post(
        Endpoints.signup,
        data: {"username": name, "email": email, "password": password},
      );
      _logger.info(response.data.toString());
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        // SimpleJWT returns 'access' and 'refresh'
        await SharedPerefsService.instance.setString(
          'token',
          data["access"].toString(),
        );
        await SharedPerefsService.instance.setString(
          'refresh_token',
          data["refresh"].toString(),
        );

        return User.fromJson(data['user'] as Map<String, dynamic>);
      }
      throw 'error occured when signing up';
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response!.data['message']?.toString() ??
                e.message ??
                'Signup failed'
          : e.message ?? 'Signup failed';
      throw message;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<User> login(String email, String password) async {
    try {
      _logger.info('Attempting login with: $email');
      final response = await _dio.post(
        Endpoints.login,
        data: {"email": email, "password": password},
      );
      _logger.info(response.data);
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        // store access token returned by SimpleJWT
        await SharedPerefsService.instance.setString(
          'token',
          (data["access"] ?? data["accessToken"]).toString(),
        );
        await SharedPerefsService.instance.setString(
          'refresh_token',
          data["refresh"].toString(),
        );

        return User.fromJson(data['user']);
      }
      throw "error occured when login in";
    } on Exception {
      rethrow;
    }
  }

  Future<User> getProfile(String token) async {
    final response = await _dio.get(
      Endpoints.profile,
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    final data = Map<String, dynamic>.from(response.data as Map);
    final userData = data['user'] is Map
        ? Map<String, dynamic>.from(data['user'] as Map)
        : data;
    return User.fromJson(userData);
  }

  Future<User> updateProfile({String? firstName, String? lastName}) async {
    final response = await _dio.put(
      Endpoints.profile,
      data: {'first_name': firstName ?? '', 'last_name': lastName ?? ''},
    );
    return User.fromJson(Map<String, dynamic>.from(response.data as Map));
  }
}
