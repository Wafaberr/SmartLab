import 'package:flutter/material.dart';

/// Reusable app button that follows the global theme.
class AppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool expanded;

  const AppButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    );

    final button = ElevatedButton(
      onPressed: onPressed,
      style: style ?? defaultStyle,
      child: child,
    );

    if (expanded) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}
