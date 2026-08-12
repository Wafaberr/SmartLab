import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smartlaboratory/core/router/app_router.dart';

import 'package:smartlaboratory/features/auth/data/repository/auth_repository_impl.dart';
import 'package:smartlaboratory/features/auth/data/repository/password_reset_repository_impl.dart';
import 'package:smartlaboratory/features/auth/domain/repository/auth_repository.dart';
import 'package:smartlaboratory/features/auth/domain/repository/password_reset_repository.dart';
import 'package:smartlaboratory/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:smartlaboratory/features/auth/presentation/cubit_2/password_reset_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appLinks = AppLinks();
  Uri? initialUri;
  try {
    initialUri = await appLinks.getInitialLink();
  } catch (_) {
    // Start normally when the app was not opened by a deep link.
  }

  AuthRepository authRepository = AuthRepositoryImpl();
  PasswordResetRepository passwordResetRepository =
      PasswordResetRepositoryImpl();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(authRepository)..checkAuth(),
        ),
        BlocProvider(
          create: (context) => PasswordResetCubit(
            authRepository,
            passwordResetRepository: passwordResetRepository,
          ),
        ),
      ],
      child: MyApp(initialUri: initialUri),
    ),
  );
}

class MyApp extends StatefulWidget {
  final Uri? initialUri;

  const MyApp({super.key, this.initialUri});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.createRoute(
      context.read<AuthCubit>(),
      initialLocation: _initialLocation,
    );
    _listenForDeepLinks();
  }

  String get _initialLocation {
    final token = _resetTokenFromUri(widget.initialUri);

    if (token == null || token.isEmpty) return '/splash';
    return '/reset-password/${Uri.encodeComponent(token)}';
  }

  String? _resetTokenFromUri(Uri? uri) {
    if (uri == null) return null;

    if (uri.queryParameters['token'] != null) {
      return uri.queryParameters['token'];
    }

    if (uri.host == 'reset-password' && uri.pathSegments.length == 1) {
      return uri.pathSegments.first;
    }

    final segments = uri.pathSegments;
    if (segments.isNotEmpty && segments.first == 'reset-password') {
      return segments.length > 1 ? segments[1] : null;
    }

    final resetIndex = segments.indexOf('reset-password');
    if (resetIndex >= 0 && resetIndex + 1 < segments.length) {
      if (segments[resetIndex + 1] == 'link' &&
          resetIndex + 2 < segments.length) {
        return segments[resetIndex + 2];
      }
      return segments[resetIndex + 1];
    }

    return null;
  }

  Future<void> _listenForDeepLinks() async {
    // The initial link is handled before the router is created.

    _linkSubscription = _appLinks.uriLinkStream.listen(
      _openResetPasswordLink,
      onError: (_) {},
    );
  }

  void _openResetPasswordLink(Uri? uri) {
    final token = _resetTokenFromUri(uri);

    if (token == null || token.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _router.go('/reset-password/${Uri.encodeComponent(token)}');
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: _router,
    );
  }
}
