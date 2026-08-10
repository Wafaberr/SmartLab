import 'package:smartlaboratory/features/auth/data/models/user_model.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> signup(String name,String email, String password);
  Future<void> logout();
}
