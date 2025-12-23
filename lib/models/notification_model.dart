class Notification {
  final String id;
  final String title;
  final String message;
  final DateTime date;
  final String type;
  final String recipientId;
  final String? relatedId;
  bool isRead;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.type,
    required this.recipientId,
    this.relatedId,
    this.isRead = false,
  });
}