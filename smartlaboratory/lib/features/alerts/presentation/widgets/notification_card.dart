import 'package:flutter/material.dart';
import 'package:smartlaboratory/features/alerts/data/models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDeletePressed;
  final VoidCallback? onMarkAsReadPressed;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onDeletePressed,
    this.onMarkAsReadPressed,
  });

  Color _getKindColor() {
    switch (notification.kind) {
      case 'error':
        return const Color(0xFFEF4444);
      case 'warning':
        return const Color(0xFFF59E0B);
      case 'success':
        return const Color(0xFF059669);
      case 'info':
      default:
        return const Color(0xFF3B82F6);
    }
  }

  IconData _getKindIcon() {
    switch (notification.kind) {
      case 'error':
        return Icons.error_outline;
      case 'warning':
        return Icons.warning_outlined;
      case 'success':
        return Icons.check_circle_outline;
      case 'info':
      default:
        return Icons.info_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final kindColor = _getKindColor();
    final kindIcon = _getKindIcon();

    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        onDeletePressed?.call();
      },
      background: Container(
        color: Colors.red.shade400,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              border: !notification.isRead
                  ? Border(left: BorderSide(color: kindColor, width: 4))
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kindColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(kindIcon, color: kindColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _formatDate(notification.createdAt),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'delete') {
                            onDeletePressed?.call();
                          } else if (value == 'toggle_read') {
                            onMarkAsReadPressed?.call();
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'toggle_read',
                            child: Text(
                              notification.isRead
                                  ? 'Marquer comme non lu'
                                  : 'Marquer comme lu',
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Supprimer'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    notification.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!notification.isRead) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 32,
                      child: ElevatedButton.icon(
                        onPressed: onMarkAsReadPressed,
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Marquer comme lu'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kindColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          minimumSize: const Size(0, 32),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
