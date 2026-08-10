// presentation/cubits/password_reset/password_reset_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartlaboratory/features/auth/domain/repository/auth_repository.dart';
import 'package:smartlaboratory/features/auth/domain/repository/password_reset_repository.dart';
import 'package:smartlaboratory/features/auth/presentation/cubit_2/password_reset_state.dart';

class PasswordResetCubit extends Cubit<PasswordResetState> {
  final PasswordResetRepository passwordResetRepository;

  PasswordResetCubit(AuthRepository authRepository, {
    required this.passwordResetRepository,
  }) : super(PasswordResetInitial());

  // Demander la réinitialisation
  Future<void> requestPasswordReset(String email) async {
    emit(PasswordResetLoading());
    
    final result = await passwordResetRepository.requestPasswordReset(email);
    
    result.fold(
      (failure) => emit(PasswordResetFailure(error: failure)),
      (success) => emit(
        PasswordResetSuccess(
          message: 'Un email de réinitialisation a été envoyé',
        ),
      ),
    );
  }

  // Confirmer la réinitialisation
  Future<void> confirmPasswordReset({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    emit(PasswordResetLoading());
    
    final result = await passwordResetRepository.confirmPasswordReset(
      token: token,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    
    result.fold(
      (failure) => emit(PasswordResetFailure(error: failure)),
      (success) => emit(
        PasswordResetSuccess(
          message: 'Mot de passe réinitialisé avec succès',
        ),
      ),
    );
  }

  // Valider un token
  Future<void> validateToken(String token) async {
    emit(PasswordResetLoading());
    
    final result = await passwordResetRepository.validateToken(token);
    
    result.fold(
      (failure) => emit(TokenInvalid(error: failure)),
      (success) => emit(
        TokenValidated(
          email: 'Utilisateur trouvé',
        ),
      ),
    );
  }

  // Changer le mot de passe (authentifié)
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    emit(PasswordResetLoading());
    
    final result = await passwordResetRepository.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    
    result.fold(
      (failure) => emit(PasswordResetFailure(error: failure)),
      (success) => emit(
        PasswordResetSuccess(
          message: 'Mot de passe changé avec succès',
        ),
      ),
    );
  }

  // Reset state
  void reset() {
    emit(PasswordResetInitial());
  }
}