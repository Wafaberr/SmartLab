import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smartlaboratory/core/router/app_router.dart';
import 'package:smartlaboratory/core/localization/app_locale.dart';
import 'package:smartlaboratory/core/theme/app_theme.dart';
import 'package:smartlaboratory/core/theme/theme_controller.dart';

import 'package:smartlaboratory/features/auth/data/repository/auth_repository_impl.dart';
import 'package:smartlaboratory/features/auth/data/repository/password_reset_repository_impl.dart';
import 'package:smartlaboratory/features/auth/domain/repository/auth_repository.dart';
import 'package:smartlaboratory/features/auth/domain/repository/password_reset_repository.dart';
import 'package:smartlaboratory/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:smartlaboratory/features/auth/presentation/cubit/user_cubit.dart';
import 'package:smartlaboratory/features/auth/data/data_source/user_remote_datasource.dart';
import 'package:smartlaboratory/features/auth/presentation/cubit_2/password_reset_cubit.dart';
import 'package:smartlaboratory/features/products/data/repository/product_repository_impl.dart';
import 'package:smartlaboratory/features/products/domain/repository/product_repository.dart';
import 'package:smartlaboratory/features/products/presentation/cubit/product_cubit.dart';
import 'package:smartlaboratory/features/laboratory/data/repository/laboratory_repository.dart';
import 'package:smartlaboratory/features/laboratory/presentation/cubit/laboratory_cubit.dart';

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
  ProductRepository productRepository = ProductRepositoryImpl();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(authRepository)..checkAuth(),
        ),
        BlocProvider(create: (_) => UserCubit(UserRemoteDatasource())),
        BlocProvider(
          create: (context) => PasswordResetCubit(
            authRepository,
            passwordResetRepository: passwordResetRepository,
          ),
        ),
        BlocProvider(create: (context) => ProductCubit(productRepository)),
        BlocProvider(
          create: (context) => LaboratoryCubit(LaboratoryRepository()),
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
  final _localeController = AppLocaleController();
  final _themeController = ThemeController();
  late final GoRouter _router;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _localeController.addListener(_onLocaleChanged);
    _localeController.load();
    _themeController.addListener(_onThemeChanged);
    _themeController.load();
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
    _localeController.removeListener(_onLocaleChanged);
    _localeController.dispose();
    _themeController.removeListener(_onThemeChanged);
    _themeController.dispose();
    _linkSubscription?.cancel();
    _router.dispose();
    super.dispose();
  }

  void _onLocaleChanged() => setState(() {});

  void _onThemeChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return AppLocaleScope(
      notifier: _localeController,
      child: ThemeScope(
        notifier: _themeController,
        child: AnimatedBuilder(
          animation: _themeController,
          builder: (context, child) => MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: _localeController.text('appName'),
            locale: _localeController.locale,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: _themeController.themeMode,
            routerConfig: _router,
          ),
        ),
      ),
    );
  }
}
