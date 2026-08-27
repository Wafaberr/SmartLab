import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartlaboratory/features/auth/data/models/user_model.dart';
import 'package:smartlaboratory/features/auth/domain/repository/auth_repository.dart';
import 'package:smartlaboratory/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:smartlaboratory/main.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<User> login(String email, String password) =>
      Future.error(UnimplementedError());

  @override
  Future<User> signup(
    String name,
    String email,
    String password, {
    File? imageFile,
  }) => Future.error(UnimplementedError());

  @override
  Future<void> logout() async {}

  @override
  Future<User> getProfile(String token) => Future.error(UnimplementedError());

  @override
  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    File? imageFile,
  }) {
    // TODO: implement updateProfile
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('SmartLab app starts on the splash screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => AuthCubit(_FakeAuthRepository()),
        child: const MyApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 6));

    expect(find.text('SmartLab Stock AI'), findsOneWidget);
  });
}
