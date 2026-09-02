import 'package:smartlaboratory/core/network/dio_client.dart';
import 'package:smartlaboratory/features/alerts/data/models/notification_model.dart';

class NotificationsRepository {
  final DioClient _client = DioClient.instance;

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _client.get('notifications/');
      if (response.data is List) {
        return (response.data as List<dynamic>)
            .map(
              (item) =>
                  NotificationModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<NotificationModel> getNotification(int id) async {
    try {
      final response = await _client.get('notifications/$id/');
      return NotificationModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _client.dio.patch('notifications/$id/', data: {'is_read': true});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsUnread(int id) async {
    try {
      await _client.dio.patch('notifications/$id/', data: {'is_read': false});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      await _client.delete('notifications/$id/');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAllNotifications() async {
    try {
      final notifications = await getNotifications();
      for (final notification in notifications) {
        await deleteNotification(notification.id);
      }
    } catch (e) {
      rethrow;
    }
  }
}
