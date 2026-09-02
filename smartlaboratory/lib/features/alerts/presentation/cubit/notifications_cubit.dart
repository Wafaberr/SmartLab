import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:smartlaboratory/features/alerts/data/models/notification_model.dart';
import 'package:smartlaboratory/features/alerts/data/repository/notifications_repository.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepository repository;

  NotificationsCubit(this.repository) : super(NotificationsInitial());

  Future<void> loadNotifications() async {
    emit(NotificationsLoading());
    try {
      final notifications = await repository.getNotifications();
      final unreadCount = notifications.where((n) => !n.isRead).length;
      emit(
        NotificationsLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ),
      );
    } catch (error) {
      emit(NotificationsError(error.toString()));
    }
  }

  Future<void> markAsRead(int id) async {
    emit(NotificationsSaving());
    try {
      await repository.markAsRead(id);
      await loadNotifications();
      emit(NotificationSuccess('Notification marquée comme lue'));
    } catch (error) {
      emit(NotificationsError(error.toString()));
    }
  }

  Future<void> markAsUnread(int id) async {
    emit(NotificationsSaving());
    try {
      await repository.markAsUnread(id);
      await loadNotifications();
      emit(NotificationSuccess('Notification marquée comme non lue'));
    } catch (error) {
      emit(NotificationsError(error.toString()));
    }
  }

  Future<void> deleteNotification(int id) async {
    emit(NotificationsSaving());
    try {
      await repository.deleteNotification(id);
      emit(NotificationDeleted(id));
      await loadNotifications();
    } catch (error) {
      emit(NotificationsError(error.toString()));
    }
  }

  Future<void> deleteAllNotifications() async {
    emit(NotificationsSaving());
    try {
      await repository.deleteAllNotifications();
      emit(NotificationsLoaded(notifications: [], unreadCount: 0));
      emit(NotificationSuccess('Toutes les notifications ont été supprimées'));
    } catch (error) {
      emit(NotificationsError(error.toString()));
    }
  }

  int getUnreadCount(List<NotificationModel> notifications) {
    return notifications.where((n) => !n.isRead).length;
  }
}
