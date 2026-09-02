part of 'notifications_cubit.dart';

@immutable
abstract class NotificationsState {}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  NotificationsLoaded({required this.notifications, this.unreadCount = 0});
}

class NotificationsSaving extends NotificationsState {}

class NotificationSuccess extends NotificationsState {
  final String message;

  NotificationSuccess(this.message);
}

class NotificationsError extends NotificationsState {
  final String message;

  NotificationsError(this.message);
}

class NotificationDeleted extends NotificationsState {
  final int notificationId;

  NotificationDeleted(this.notificationId);
}
