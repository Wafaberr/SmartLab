import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smartlaboratory/features/auth/presentation/cubit/auth_cubit.dart';

class SplashScreen extends StatefulWidget {
  final Future<void> Function() onInit;

  const SplashScreen({super.key, required this.onInit});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _scale = 0.3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _scale = 1.0);
      initialize();
    });
  }

  void initialize() async {
    await widget.onInit();
    if (!mounted) return;

    final currentPath = GoRouterState.of(context).uri.path;
    if (currentPath.startsWith('/reset-password')) return;

    final isAuth = context.read<AuthCubit>().state is Authentificated;
    context.go(isAuth ? "/home" : "/login");
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedContainer(
          duration: Duration(milliseconds: 1000),
          curve: Curves.easeOutBack,
          transform: Matrix4.diagonal3Values(_scale, _scale, 1),
          transformAlignment: Alignment.center,

          child: Text(
            "FlavorLy",
            style: TextStyle(
              color: Colors.blue,
              fontSize: 48,
              fontWeight: FontWeight.w900,
              letterSpacing: 6,
            ),
          ),
        ),
      ),
    );
  }
}
