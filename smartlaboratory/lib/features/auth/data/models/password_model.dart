// data/models/auth_models.dart
import 'package:equatable/equatable.dart';

class PasswordResetRequestModel extends Equatable {
  final String email;

  const PasswordResetRequestModel({required this.email});

  Map<String, dynamic> toJson() => {'email': email};

  @override
  List<Object?> get props => [email];
}

class PasswordResetConfirmModel extends Equatable {
  final String token;
  final String newPassword;
  final String confirmPassword;

  const PasswordResetConfirmModel({
    required this.token,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
        'token': token,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      };

  @override
  List<Object?> get props => [token, newPassword, confirmPassword];
}

class PasswordChangeModel extends Equatable {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  const PasswordChangeModel({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
        'old_password': oldPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      };

  @override
  List<Object?> get props => [oldPassword, newPassword, confirmPassword];
}

class TokenValidationModel extends Equatable {
  final String token;

  const TokenValidationModel({required this.token});

  @override
  List<Object?> get props => [token];
}