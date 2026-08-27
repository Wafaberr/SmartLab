part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthChecking extends AuthState {}

final class AuthLoading extends AuthState {}

final class Authentificated extends AuthState {
  final User user;

  Authentificated({required this.user});
}

final class UnAuthentificated extends AuthState {}

final class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});
}
