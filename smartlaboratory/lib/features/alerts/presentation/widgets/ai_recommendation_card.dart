import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/ai_recommendation_model.dart';

class AIRecommendationCard extends StatelessWidget {
  final AIRecommendation recommendation;
  final VoidCallback? onMarkResolved;
  final VoidCallback? onDismiss;

  const AIRecommendationCard({
    super.key,
    required this.recommendation,
    this.onMarkResolved,
    this.onDismiss,
  });

  String _getAnalysisTypeLabel() {
    switch (recommendation.analysisType) {
      case 'low_stock':
        return '📉 Stock Bas';
      case 'expiring':
        return '⏰ Expiration Proche';
      case 'expired':
        return '🔴 Expiré';
      case 'overstock':
        return '📦 Surstock';
      case 'trend':
        return '📊 Tendance';
      default:
        return recommendation.analysisType;
    }
  }

  Color _getPriorityColor() {
    switch (recommendation.priority) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.amber;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityLabel() {
    switch (recommendation.priority) {
      case 'critical':
        return 'Critique';
      case 'high':
        return 'Haute';
      case 'medium':
        return 'Moyenne';
      case 'low':
        return 'Basse';
      default:
        return recommendation.priority;
    }
  }

  String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) {
      return 'À l\'instant';
    } else if (diff.inMinutes < 60) {
      return 'Il y a ${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return 'Il y a ${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return 'Il y a ${diff.inDays}j';
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priorityColor = _getPriorityColor();

    return Dismissible(
      key: ValueKey(recommendation.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmer'),
            content: const Text('Marquer cette alerte comme résolue ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Oui'),
              ),
            ],
          ),
        );
        if (confirm == true) {
          onMarkResolved?.call();
        }
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.green,
        child: const Icon(Icons.check, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        elevation: 2,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border(left: BorderSide(color: priorityColor, width: 4)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec type et priorité
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getAnalysisTypeLabel(),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            recommendation.productName,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getPriorityLabel(),
                        style: TextStyle(
                          color: priorityColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Informations sur le stock
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _InfoBadge(
                        label: 'Actuel',
                        value: recommendation.currentStock.toString(),
                      ),
                      _InfoBadge(
                        label: 'Minimum',
                        value: recommendation.minimumStock.toString(),
                      ),
                      if (recommendation.dailyConsumption > 0)
                        _InfoBadge(
                          label: 'Conso/jour',
                          value: recommendation.dailyConsumption
                              .toStringAsFixed(2),
                        ),
                      if (recommendation.estimatedDaysRemaining != null)
                        _InfoBadge(
                          label: 'Jours restants',
                          value: '${recommendation.estimatedDaysRemaining}',
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Recommandation
                Text(
                  recommendation.recommendation,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                if (recommendation.recommendedQuantity != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info, size: 18, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Acheter: ${recommendation.recommendedQuantity?.toStringAsFixed(0)} unités',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                // Pied de page avec date et action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getRelativeTime(recommendation.createdAt),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                    ),
                    if (!recommendation.isResolved)
                      TextButton.icon(
                        onPressed: onMarkResolved,
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Résolu'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                        ),
                      ),
                    if (recommendation.isResolved)
                      Chip(
                        label: const Text('Résolu'),
                        backgroundColor: Colors.green.withValues(alpha: 0.2),
                        labelStyle: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final String label;
  final String value;

  const _InfoBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
