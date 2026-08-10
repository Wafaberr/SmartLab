// data/repositories/password_reset_repository.dart
import 'package:dartz/dartz.dart';
import 'package:smartlaboratory/features/auth/data/data_source/password_reset_remote_datasource.dart';
import 'package:smartlaboratory/features/auth/data/models/password_model.dart';
import 'package:smartlaboratory/features/auth/domain/repository/password_reset_repository.dart';

class PasswordResetRepositoryImpl implements PasswordResetRepository {
  final PasswordResetRemoteDataSource remoteDataSource=PasswordResetRemoteDataSource();

  

  @override
  Future<Either<String, bool>> requestPasswordReset(String email) async {
    try {
      final request = PasswordResetRequestModel(email: email);
      final response = await remoteDataSource.requestPasswordReset(request);

      if (response['success'] == true) {
        return Right(true);
      } else {
        return Left(_responseMessage(response, 'Erreur lors de la demande'));
      }
    } catch (e) {
      return Left('Erreur: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, bool>> confirmPasswordReset({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final request = PasswordResetConfirmModel(
        token: token,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      final response = await remoteDataSource.confirmPasswordReset(request);

      if (response['success'] == true) {
        return Right(true);
      } else {
        return Left(
          _responseMessage(response, 'Erreur lors de la réinitialisation'),
        );
      }
    } catch (e) {
      return Left('Erreur: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, bool>> validateToken(String token) async {
    try {
      final response = await remoteDataSource.validateToken(token);

      if (response['success'] == true) {
        return Right(true);
      } else {
        return Left(_responseMessage(response, 'Token invalide ou expiré'));
      }
    } catch (e) {
      return Left('Erreur: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, bool>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final request = PasswordChangeModel(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      final response = await remoteDataSource.changePassword(request);

      if (response['success'] == true) {
        return Right(true);
      } else {
        return Left(_responseMessage(response, 'Erreur lors du changement'));
      }
    } catch (e) {
      return Left('Erreur: ${e.toString()}');
    }
  }

  String _responseMessage(Map<String, dynamic> response, String fallback) {
    final message = response['message'] ?? response['error'];
    return message?.toString() ?? fallback;
  }
}
