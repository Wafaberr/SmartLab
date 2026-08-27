import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smartlaboratory/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:smartlaboratory/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:smartlaboratory/features/auth/presentation/screens/login_screen.dart';
import 'package:smartlaboratory/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:smartlaboratory/features/auth/presentation/screens/signup_screen.dart';
import 'package:smartlaboratory/features/auth/presentation/screens/users_management_screen.dart';
import 'package:smartlaboratory/features/home/presentation/screens/home_screen.dart';
import 'package:smartlaboratory/features/products/presentation/screens/add_product_screen.dart';
import 'package:smartlaboratory/features/products/presentation/screens/stock_entry_screen.dart';
import 'package:smartlaboratory/features/products/presentation/screens/stock_history_screen.dart';
import 'package:smartlaboratory/features/products/presentation/screens/stock_exit_screen.dart';
import 'package:smartlaboratory/features/laboratory/presentation/screens/analysis_types_screen.dart';
import 'package:smartlaboratory/features/laboratory/presentation/screens/new_analysis_session_screen.dart';
import 'package:smartlaboratory/features/laboratory/presentation/screens/lab_sessions_screen.dart';
import 'package:smartlaboratory/features/laboratory/presentation/screens/session_detail_screen.dart';
import 'package:smartlaboratory/features/settings/presentation/screens/profile_screen.dart';
import 'package:smartlaboratory/splash_screen.dart';

class AppRouter {
  static GoRouter createRoute(
    AuthCubit cubit, {
    String initialLocation = '/splash',
  }) => GoRouter(
    initialLocation: initialLocation,
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
      GoRoute(
        path: '/users',
        builder: (context, state) => const UsersManagementScreen(),
      ),
      GoRoute(path: '/profile', builder: (context, state) => ProfileScreen()),
      GoRoute(path: '/UsersManagementScreen', builder: (context, state) => UsersManagementScreen()),
      GoRoute(path: '/addProduct', builder: (context, state) =>  AddProductScreen()),
      GoRoute(
        path: '/session',
        builder: (context, state) => NewAnalysisSessionScreen(),
      ),
      GoRoute(
        path: '/historique/:productId',
        builder: (context, state) => StockHistoryScreen(
          productId: int.parse(state.pathParameters['productId']!),
        ),
      ),
      GoRoute(
        path: '/stock/exit/:productId',
        builder: (context, state) => StockExitScreen(
          productId: int.parse(state.pathParameters['productId']!),
        ),
      ),
      GoRoute(
        path: '//stock/input/:productId',
        builder: (context, state) => StockEntryScreen(productId: int.parse(state.pathParameters['productId']!),),
      ),
      GoRoute(
        path: '/analyses',
        builder: (context, state) => const AnalysisTypesScreen(),
      ),
      GoRoute(
        path: '/analyses/new',
        builder: (context, state) => const NewAnalysisSessionScreen(),
      ),
      GoRoute(
        path: '/analyses/sessions',
        builder: (context, state) => const LabSessionsScreen(),
      ),
      GoRoute(
        path: '/analyses/sessions/:sessionId',
        builder: (context, state) => SessionDetailScreen(
          sessionId: int.parse(state.pathParameters['sessionId']!),
        ),
      ),
      GoRoute(
        path: '/reset_pass',
        builder: (context, state) => ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password/:token',
        builder: (context, state) =>
            ResetPasswordScreen(token: state.pathParameters['token']!),
      ),
    ],
    redirect: (context, state) {
      final status = cubit.state;
      if (status is AuthChecking || status is AuthInitial) return null;

      final isAuthenticated = status is Authentificated;
      final isPasswordResetRoute = state.uri.path.startsWith(
        '/reset-password/',
      );
      if (isPasswordResetRoute) return null;

      const authRoutes = ['/login', '/signup', '/reset_pass'];
      final isAuthRoute = authRoutes.contains(state.matchedLocation);

      if (!isAuthenticated && !isAuthRoute) return '/login';
      final isAdmin = status is Authentificated && status.user.isAdmin;
      if (state.matchedLocation == '/users' && !isAdmin) {
        return '/home';
      }
      if (isAuthenticated && authRoutes.contains(state.matchedLocation)) {
        return '/home';
      }
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
