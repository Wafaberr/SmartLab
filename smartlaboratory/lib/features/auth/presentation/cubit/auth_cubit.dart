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
    emit(AuthLoading());
    try {
      final token = await SharedPerefsService.instance.getString("token");
      // final user = await AuthRemoteDatasource.getProfile(token);
      if (token != null) {
        emit(
          Authentificated(
            user: User(id: "", name: "", email: ""),
          ),
        );
        return;
      }
      emit(UnAuthentificated());
    } catch (e) {
      emit(AuthError(message: "error occured"));
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

  Future<void> signup(String name, String email, String password) async {
    emit(AuthLoading());
    print('🚀 AuthCubit: Starting ');
    try {
      print('🚀 AuthCubit: Starting signup');
      final user = await authRepository.signup(name, email, password);
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
