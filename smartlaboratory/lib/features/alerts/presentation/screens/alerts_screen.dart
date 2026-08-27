import 'package:flutter/material.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alertes',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          _buildAlertCard(
            title: 'Stock faible',
            message: 'Produit A: Stock minimum atteint',
            type: AlertType.warning,
          ),
          const SizedBox(height: 12),
          _buildAlertCard(
            title: 'Expiration',
            message: 'Produit B expire dans 5 jours',
            type: AlertType.error,
          ),
          const SizedBox(height: 12),
          _buildAlertCard(
            title: 'Information',
            message: 'Nouveau fournisseur ajouté',
            type: AlertType.info,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard({
    required String title,
    required String message,
    required AlertType type,
  }) {
    final color = _getAlertColor(type);
    final icon = _getAlertIcon(type);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    message,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAlertColor(AlertType type) {
    switch (type) {
      case AlertType.warning:
        return Colors.orange;
      case AlertType.error:
        return Colors.red;
      case AlertType.info:
        return Colors.blue;
    }
  }

  IconData _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.warning:
        return Icons.warning_amber_rounded;
      case AlertType.error:
        return Icons.error_outline;
      case AlertType.info:
        return Icons.info_outline;
    }
  }
}

enum AlertType { warning, error, info }
