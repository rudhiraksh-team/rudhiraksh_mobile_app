// notification_storage.dart
import 'package:get_storage/get_storage.dart';
import 'package:rudhirakshapp/data/models/notification_model.dart';

class NotificationStorage {
  static final GetStorage _box = GetStorage();
  static const String _key = 'notifications';

  // Get notifications
  static List<NotificationItem> getNotifications() {
    final List? notifications = _box.read<List>(_key);
    if (notifications == null) return [];

    return notifications
        .map(
          (item) => NotificationItem(
            id: item['id'],
            title: item['title'],
            message: item['message'],
            date: item['date'],
            isRead: item['isRead'],
          ),
        )
        .toList();
  }

  // Save notifications
  static void saveNotifications(List<NotificationItem> notifications) {
    final List<Map<String, dynamic>> data =
        notifications
            .map(
              (item) => {
                'id': item.id,
                'title': item.title,
                'message': item.message,
                'date': item.date,
                'isRead': item.isRead,
              },
            )
            .toList();

    _box.write(_key, data);
  }

  // Clear all notifications
  static void clearAll() {
    _box.remove(_key);
  }
}
