import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartlaboratory/features/alerts/presentation/cubit/notifications_cubit.dart';
import 'package:smartlaboratory/features/alerts/presentation/widgets/notification_card.dart';
import 'package:smartlaboratory/features/alerts/presentation/screens/ai_assistant_screen.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<NotificationsCubit>().loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications & IA'),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Notifications'),
            Tab(text: 'Assistant IA'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildNotificationsTab(), const AIAssistantScreen()],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return BlocConsumer<NotificationsCubit, NotificationsState>(
      listener: (context, state) {
        if (state is NotificationsError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
        if (state is NotificationSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        if (state is NotificationsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is NotificationsLoaded) {
          final notifications = state.notifications;
          final unreadCount = state.unreadCount;

          if (notifications.isEmpty) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune notification',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Vous êtes à jour !',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                context.read<NotificationsCubit>().loadNotifications(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (unreadCount > 0)
                            Text(
                              '$unreadCount non lu${unreadCount > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                        ],
                      ),
                      if (notifications.isNotEmpty)
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'delete_all') {
                              _showDeleteAllDialog(context);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem<String>(
                              value: 'delete_all',
                              child: Text('Tout supprimer'),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return NotificationCard(
                        notification: notification,
                        onTap: () {
                          if (!notification.isRead) {
                            context.read<NotificationsCubit>().markAsRead(
                              notification.id,
                            );
                          }
                        },
                        onMarkAsReadPressed: () {
                          if (notification.isRead) {
                            context.read<NotificationsCubit>().markAsUnread(
                              notification.id,
                            );
                          } else {
                            context.read<NotificationsCubit>().markAsRead(
                              notification.id,
                            );
                          }
                        },
                        onDeletePressed: () {
                          context.read<NotificationsCubit>().deleteNotification(
                            notification.id,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }

        if (state is NotificationsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                const Text('Erreur au chargement des notifications'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<NotificationsCubit>().loadNotifications();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer toutes les notifications'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer toutes les notifications ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              context.read<NotificationsCubit>().deleteAllNotifications();
              Navigator.pop(dialogContext);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
