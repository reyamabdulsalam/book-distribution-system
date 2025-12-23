import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';

class NotificationService with ChangeNotifier {
  List<Notification> _notifications = [];

  List<Notification> get notifications => _notifications;

  void sendNotification({
    required String title,
    required String message,
    required String type,
    required String recipientId,
    String? relatedId,
  }) {
    final newNotification = Notification(
      id: 'NOTIF-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      date: DateTime.now(),
      type: type,
      recipientId: recipientId,
      relatedId: relatedId,
    );

    _notifications.add(newNotification);
    notifyListeners();
  }

  List<Notification> getUserNotifications(String userId) {
    return _notifications.where((notif) => notif.recipientId == userId).toList();
  }

  void markAsRead(String notificationId) {
    final notifIndex = _notifications.indexWhere((n) => n.id == notificationId);
    if (notifIndex != -1) {
      _notifications[notifIndex].isRead = true;
      notifyListeners();
    }
  }

  int getUnreadCount(String userId) {
    return _notifications.where((notif) =>
    notif.recipientId == userId && !notif.isRead
    ).length;
  }

  void addSampleNotifications() {
    _notifications.addAll([
      Notification(
        id: '1',
        title: 'مرحباً بك',
        message: 'تم تسجيل الدخول بنجاح',
        date: DateTime.now(),
        type: 'welcome',
        recipientId: 'all',
      ),
      Notification(
        id: '2',
        title: 'طلب جديد',
        message: 'هناك طلب كتب جديد يحتاج المراجعة',
        date: DateTime.now().subtract(Duration(hours: 2)),
        type: 'new_order',
        recipientId: 'gov_001',
      ),
    ]);
  }
}