import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 0.42, 1],
          colors: [
            colors.primaryContainer.withValues(alpha: 0.55),
            colors.surface,
            colors.surfaceContainerLowest,
          ],
        ),
      ),
      child: child,
    );
  }
}
