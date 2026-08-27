import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:smartlaboratory/features/auth/data/data_source/user_remote_datasource.dart';
import 'package:smartlaboratory/features/auth/data/models/user_model.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserRemoteDatasource datasource;

  UserCubit(this.datasource) : super(UserInitial());

  Future<void> loadUsers() async {
    emit(UserLoading());
    try {
      emit(UserLoaded(await datasource.getUsers()));
    } catch (error) {
      emit(UserError(error.toString()));
    }
  }

  Future<void> saveUser({
    int? id,
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    required String role,
    String? password,
    File? imageFile,
  }) async {
    emit(UserLoading());
    try {
      await datasource.saveUser(
        id: id,
        username: username,
        email: email,
        firstName: firstName,
        lastName: lastName,
        role: role,
        password: password,
        imageFile: imageFile,
      );
      await loadUsers();
    } catch (error) {
      emit(UserError(error.toString()));
    }
  }

  Future<void> deleteUser(int id) async {
    emit(UserLoading());
    try {
      await datasource.deleteUser(id);
      await loadUsers();
    } catch (error) {
      emit(UserError(error.toString()));
    }
  }
}
