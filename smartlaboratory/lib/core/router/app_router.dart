import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smartlaboratory/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:smartlaboratory/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:smartlaboratory/features/auth/presentation/screens/login_screen.dart';
import 'package:smartlaboratory/features/auth/presentation/screens/signup_screen.dart';
import 'package:smartlaboratory/features/home/presentation/screens/home_screen.dart';
import 'package:smartlaboratory/features/setting/presentation/screens/profile_screen.dart';
import 'package:smartlaboratory/splash_screen.dart';

class AppRouter {
  static GoRouter createRoute(AuthCubit cubit) => GoRouter(
    initialLocation: '/splash',
    refreshListenable: _AuthCubitListenable(cubit),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => SplashScreen(
          onInit: () async {
            await Future.delayed(Duration(seconds: 5));
          },
        ),
      ),
      GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => SignupScreen()),
      GoRoute(path: '/profile', builder: (context, state) => ProfileScreen()),
      GoRoute(
        path: '/reset_pass',
        builder: (context, state) => ForgotPasswordScreen(),
      ),
    ],
    redirect: (context, state) {
      final status = cubit.state;
      if (status is AuthLoading || status is AuthInitial) return null;

      final isAuthenticated = status is Authentificated;
      List<String> authRoutes = ['/login', '/signup', '/reset_pass'];
      final isAuthRoute = authRoutes.contains(state.matchedLocation);

      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && isAuthRoute) return '/home';
      return null;
    },
  );
}

class _AuthCubitListenable extends ChangeNotifier {
  _AuthCubitListenable(AuthCubit authCubit) {
    _subscription = authCubit.stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
