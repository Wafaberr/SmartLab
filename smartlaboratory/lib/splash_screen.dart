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

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Animation Controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Animation d'échelle (effet bounce)
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    // Animation d'opacité
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Animation de rotation (pour l'icône)
    _rotationAnimation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    // Animation de slide pour le texte
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
          ),
        );

    // Animation de pulsation pour le loader
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Démarrer les animations
    _controller.forward();

    // Démarrer l'initialisation après un délai
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
        initialize();
      }
    });
  }

  void initialize() async {
    await widget.onInit();
    if (!mounted) return;

    // Vérifier si on est sur la page de reset password
    final currentPath = GoRouterState.of(context).uri.path;
    if (currentPath.startsWith('/reset-password')) return;

    // Vérifier l'état d'authentification via Bloc
    final isAuth = context.read<AuthCubit>().state is Authentificated;

    // Animation de sortie avant navigation
    await _controller.reverse();
    if (!mounted) return;

    // Navigation avec GoRouter
    context.go(isAuth ? "/home" : "/login");
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo animé avec rotation et échelle
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF1A3A7A),
                              Color(0xFF0F2B5C),
                              Color(0xFF1A3A7A),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(35),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1A3A7A).withValues(alpha: 0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.science,
                          color: Colors.white,
                          size: 65,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Titre avec animation de slide
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _opacityAnimation,
                  child: const Text(
                    'SmartLab Stock AI',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A3A7A),
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Sous-titre avec animation de slide (décalée)
              SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _controller,
                        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
                      ),
                    ),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
                    ),
                  ),
                  child: Text(
                    'Gestion intelligente du stock\n d’un laboratoire d’analyses médicales',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // Loader avec animation de pulsation
              if (_isLoading)
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final pulseValue =
                        1.0 +
                        0.1 *
                            (_pulseAnimation.value - 1.0) *
                            (1 + 0.3 * (1 - _controller.value * 2).abs());

                    return Transform.scale(
                      scale: pulseValue,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 45,
                            height: 45,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFF1A3A7A),
                              ),
                              strokeWidth: 4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chargement...',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

              // Petite animation de particules (cercles décoratifs)
              if (!_isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildParticle(0.2, Colors.blue.shade100),
                      const SizedBox(width: 8),
                      _buildParticle(0.4, Colors.blue.shade200),
                      const SizedBox(width: 8),
                      _buildParticle(
                        0.6,
                        const Color(0xFF1A3A7A).withValues(alpha: 0.3),
                      ),
                      const SizedBox(width: 8),
                      _buildParticle(0.8, Colors.blue.shade200),
                      const SizedBox(width: 8),
                      _buildParticle(1.0, Colors.blue.shade100),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticle(double delay, Color color) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = (_controller.value - delay).clamp(0.0, 1.0);
        final opacity = 1.0 - progress;
        final size = 6.0 * (1.0 + progress * 2);

        return Transform.scale(
          scale: 1.0 + progress * 0.5,
          child: Opacity(
            opacity: opacity * 0.6,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        );
      },
    );
  }
}
