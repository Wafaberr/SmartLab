import 'dart:io';

import 'package:dio/dio.dart';
import 'package:smartlaboratory/core/constants/endpoints.dart';
import 'package:smartlaboratory/core/network/dio_client.dart';
import 'package:smartlaboratory/features/auth/data/models/user_model.dart';

class UserRemoteDatasource {
  final _dio = DioClient.instance;

  Future<List<User>> getUsers() async {
    final response = await _dio.get(Endpoints.users);
    return (response.data as List)
        .map((item) => User.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<User> saveUser({
    int? id,
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    required String role,
    String? password,
    File? imageFile,
  }) async {
    final data = FormData.fromMap({
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      if (password != null && password.isNotEmpty) 'password': password,
      if (imageFile != null)
        'image': await MultipartFile.fromFile(imageFile.path),
    });
    final response = id == null
        ? await _dio.post(Endpoints.users, data: data)
        : await _dio.put('${Endpoints.users}$id/', data: data);
    return User.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<void> deleteUser(int id) async {
    await _dio.delete('${Endpoints.users}$id/');
  }
}
