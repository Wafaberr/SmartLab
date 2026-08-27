import 'package:flutter/material.dart';

/// Simple status badge used for roles/statuses etc.
class StatusBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? textColor;

  const StatusBadge({super.key, required this.text, this.color, this.textColor});

  @override
  Widget build(BuildContext context) {
    final bg = color ?? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12);
    final fg = textColor ?? Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}
