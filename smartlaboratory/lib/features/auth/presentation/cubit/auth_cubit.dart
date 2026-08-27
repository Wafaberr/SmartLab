import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:smartlaboratory/core/storage/shared_perefs_service.dart';
import 'package:smartlaboratory/features/auth/data/models/user_model.dart';
import 'package:smartlaboratory/features/auth/domain/repository/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthRepository authRepository;
  AuthCubit(this.authRepository) : super(AuthInitial());

  Future<void> checkAuth() async {
    emit(AuthChecking());

    try {
      final token = await SharedPerefsService.instance.getString("token");

      // Aucun token = utilisateur non connecté
      if (token == null || token.isEmpty) {
        emit(UnAuthentificated());
        return;
      }

      // Récupérer le vrai profil depuis Django
      final user = await authRepository.getProfile(token);

      emit(Authentificated(user: user));
    } catch (e) {
      // Token invalide/expiré ou problème serveur
      await SharedPerefsService.instance.remove("token");

      emit(AuthError(message: e.toString()));

      // Tu peux aussi choisir :
      // emit(UnAuthentificated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(email, password);
      emit(Authentificated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> signup(
    String name,
    String email,
    String password, {
    File? imageFile,
  }) async {
    emit(AuthLoading());
    // print('🚀 AuthCubit: Starting ');
    try {
      // print('🚀 AuthCubit: Starting signup');
      final user = await authRepository.signup(
        name,
        email,
        password,
        imageFile: imageFile,
      );
      emit(Authentificated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    File? imageFile,
  }) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.updateProfile(
        firstName: firstName,
        lastName: lastName,
        imageFile: imageFile,
      );
      emit(Authentificated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
      emit(UnAuthentificated());
    } catch (e) {
      emit(AuthError(message: "error ocuured while loggin out "));
    }
  }

  void clearError() {
    emit(AuthInitial());
  }
}
