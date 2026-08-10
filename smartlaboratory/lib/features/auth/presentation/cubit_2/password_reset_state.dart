// presentation/cubits/password_reset/password_reset_state.dart
import 'package:equatable/equatable.dart';

abstract class PasswordResetState extends Equatable {
  const PasswordResetState();

  @override
  List<Object?> get props => [];
}

class PasswordResetInitial extends PasswordResetState {}

class PasswordResetLoading extends PasswordResetState {}

class PasswordResetSuccess extends PasswordResetState {
  final String message;
  final Map<String, dynamic>? data;

  const PasswordResetSuccess({required this.message, this.data});

  @override
  List<Object?> get props => [message, data];
}

class PasswordResetFailure extends PasswordResetState {
  final String error;
  final Map<String, dynamic>? errors;

  const PasswordResetFailure({required this.error, this.errors});

  @override
  List<Object?> get props => [error, errors];
}

class TokenValidated extends PasswordResetState {
  final String email;

  const TokenValidated({required this.email});

  @override
  List<Object?> get props => [email];
}

class TokenInvalid extends PasswordResetState {
  final String error;

  const TokenInvalid({required this.error});

  @override
  List<Object?> get props => [error];
}