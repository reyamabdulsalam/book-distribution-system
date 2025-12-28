/// نموذج الإشعارات من Backend API
class AppNotification {
  final int id;
  final String message;
  final bool read;
  final String? type;
  final Map<String, dynamic>? data;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.message,
    required this.read,
    this.type,
    this.data,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      message: json['message'] ?? '',
      read: json['read'] ?? false,
      type: json['type'],
      data: json['data'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'read': read,
      'type': type,
      'data': data,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// استجابة قائمة الإشعارات
class NotificationListResponse {
  final int count;
  final int unreadCount;
  final List<AppNotification> notifications;

  NotificationListResponse({
    required this.count,
    required this.unreadCount,
    required this.notifications,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    return NotificationListResponse(
      count: json['count'] ?? 0,
      unreadCount: json['unread_count'] ?? 0,
      notifications: (json['notifications'] as List?)
              ?.map((n) => AppNotification.fromJson(n))
              .toList() ??
          [],
    );
  }
}

/// Legacy model - for backwards compatibility
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
