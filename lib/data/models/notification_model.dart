class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String date;
  bool isSelected;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    this.isSelected = false,
    this.isRead = false,
  });
}
