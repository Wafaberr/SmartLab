import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartlaboratory/core/router/app_router.dart';

import 'package:smartlaboratory/features/auth/data/repository/auth_repository_impl.dart';
import 'package:smartlaboratory/features/auth/domain/repository/auth_repository.dart';
import 'package:smartlaboratory/features/auth/presentation/cubit/auth_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AuthRepository authRepository = AuthRepositoryImpl();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(authRepository)..checkAuth(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: AppRouter.createRoute(context.read<AuthCubit>()),
    );
  }
}
