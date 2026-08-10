
import 'package:smartlaboratory/core/storage/shared_perefs_service.dart';
import 'package:smartlaboratory/features/auth/data/data_source/auth_remote_datasource.dart';
import 'package:smartlaboratory/features/auth/data/models/user_model.dart';
import 'package:smartlaboratory/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRemoteDatasource authRemoteDatasource = AuthRemoteDatasource();
  @override
  Future<User> login(String email, String password) async{
    try {
      final user = await authRemoteDatasource.login(email, password);
      return user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout()async {
    await SharedPerefsService.instance.remove("token");
  }

  @override
  Future<User> signup(String name, String email, String password) async{
    try {
      final user =await authRemoteDatasource.signup(name, email, password);
      return user;
    } catch (e) {
      rethrow;
    }
  }
}
