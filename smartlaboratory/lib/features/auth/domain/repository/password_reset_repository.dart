// domain/repositories/password_reset_repository_interface.dart
import 'package:dartz/dartz.dart';

abstract class PasswordResetRepository{
  Future<Either<String, bool>> requestPasswordReset(String email);
  Future<Either<String, bool>> confirmPasswordReset({
    required String token,
    required String newPassword,
    required String confirmPassword,
  });
  Future<Either<String, bool>> validateToken(String token);
  Future<Either<String, bool>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  });
}