import 'package:get/get.dart';
import 'package:rudhirakshapp/data/models/notification_model.dart';
import 'package:rudhirakshapp/data/storage/notification_storage.dart';

class NotificationController extends GetxController {
  // Observable list of notifications
  var notifications = <NotificationItem>[].obs;
  var isSelectionMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  // Add this method to clear selection when controller is closed
  @override
  void onClose() {
    // Clear selection when the controller is closed
    clearSelection();
    super.onClose();
  }

  @override
  void onReady() {
    super.onReady();
    // Ensure notifications are loaded when controller is ready
    loadNotifications();
  }

  // Load notifications from storage
  void loadNotifications() {
    final stored = NotificationStorage.getNotifications();
    if (stored.isNotEmpty) {
      notifications.assignAll(stored);
    }
  }

  // Save current notifications to storage
  void saveNotifications() {
    NotificationStorage.saveNotifications(notifications);
  }

  // Mark a notification as read by ID
  void markAsRead(String id) {
    final index = notifications.indexWhere((item) => item.id == id);
    if (index != -1) {
      notifications[index].isRead = true;
      notifications.refresh();
      saveNotifications();
    }
  }

  // Mark all notifications as read
  void markAllAsRead() {
    for (var item in notifications) {
      item.isRead = true;
    }
    notifications.refresh();
    saveNotifications();
  }

  // Toggle selection mode and select/deselect a notification
  void toggleNotificationSelection(int index) {
    notifications[index].isSelected = !notifications[index].isSelected;

    // Check if any item is still selected
    bool anySelected = notifications.any((item) => item.isSelected);

    // If no items are selected, exit selection mode
    if (!anySelected) {
      isSelectionMode.value = false;
    }

    notifications.refresh();
    saveNotifications();
  }

  // Toggle select all
  void toggleSelectAll(bool selectAll) {
    for (var item in notifications) {
      item.isSelected = selectAll;
    }

    // If deselecting all, exit selection mode
    if (!selectAll) {
      isSelectionMode.value = false;
    }

    notifications.refresh();
    saveNotifications();
  }

  // Delete selected notifications
  void deleteSelected() {
    notifications.removeWhere((item) => item.isSelected);
    isSelectionMode.value = false;
    saveNotifications();
  }

  /// Clear all selections and exit selection mode
  void clearSelection() {
    for (var n in notifications) {
      n.isSelected = false;
    }
    isSelectionMode.value = false;
    notifications.refresh();
  }

  // Clear all notifications
  void clearAllNotifications() {
    notifications.clear();
    saveNotifications();
  }

  // Add a new notification
  void addNotification(NotificationItem notification) {
    notifications.insert(0, notification);
    saveNotifications();
  }
}
