import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';
import '../utils/constants.dart';
import 'api_client.dart';

/// خدمة إدارة الإشعارات - متكاملة مع Backend API
class NotificationService with ChangeNotifier {
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 1. جلب الإشعارات من Backend
  Future<bool> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/notifications/');

      final response = await http.get(
        uri,
        headers: ApiClient.defaultHeaders(),
      ).timeout(Duration(seconds: 15));

      if (kDebugMode) {
        print('Notifications Response: ${response.statusCode}');
        print('Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final notificationResponse = NotificationListResponse.fromJson(data);
        _notifications = notificationResponse.notifications;
        _unreadCount = notificationResponse.unreadCount;
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (response.statusCode == 401) {
        _error = 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً';
      } else {
        _error = 'فشل في جلب الإشعارات';
      }
    } on SocketException {
      _error = 'لا يوجد اتصال بالإنترنت';
    } on TimeoutException {
      _error = 'انتهى وقت الاتصال بالخادم';
    } catch (e) {
      _error = 'حدث خطأ: ${e.toString()}';
      if (kDebugMode) print('Error fetching notifications: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// 2. تسجيل Device Token للـ Push Notifications
  Future<bool> registerDeviceToken({
    required String deviceToken,
    required String deviceType,
    String? deviceName,
  }) async {
    try {
      final uri =
          Uri.parse('${AppConfig.apiBaseUrl}/api/notifications/register-device/');

      final response = await http.post(
        uri,
        headers: ApiClient.defaultHeaders(),
        body: jsonEncode({
          'device_token': deviceToken,
          'device_type': deviceType, // android, ios
          'device_name': deviceName ?? '',
        }),
      ).timeout(Duration(seconds: 15));

      if (kDebugMode) {
        print('Register Device Response: ${response.statusCode}');
        print('Body: ${response.body}');
      }

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) print('Error registering device: $e');
      return false;
    }
  }

  /// 3. تعليم الإشعار كمقروء
  Future<bool> markAsRead(int notificationId) async {
    try {
      final uri = Uri.parse(
          '${AppConfig.apiBaseUrl}/api/notifications/$notificationId/mark-read/');

      final response = await http.post(
        uri,
        headers: ApiClient.defaultHeaders(),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        // تحديث الإشعار محلياً
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = AppNotification(
            id: _notifications[index].id,
            message: _notifications[index].message,
            read: true,
            type: _notifications[index].type,
            data: _notifications[index].data,
            createdAt: _notifications[index].createdAt,
          );
          _unreadCount = _notifications.where((n) => !n.read).length;
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      if (kDebugMode) print('Error marking notification as read: $e');
    }
    return false;
  }

  /// 4. تعليم جميع الإشعارات كمقروءة
  Future<bool> markAllAsRead() async {
    try {
      final uri = Uri.parse(
          '${AppConfig.apiBaseUrl}/api/notifications/mark-all-read/');

      final response = await http.post(
        uri,
        headers: ApiClient.defaultHeaders(),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        // تحديث جميع الإشعارات محلياً
        _notifications = _notifications.map((n) {
          return AppNotification(
            id: n.id,
            message: n.message,
            read: true,
            type: n.type,
            data: n.data,
            createdAt: n.createdAt,
          );
        }).toList();
        _unreadCount = 0;
        notifyListeners();
        return true;
      }
    } catch (e) {
      if (kDebugMode) print('Error marking all as read: $e');
    }
    return false;
  }

  /// إعادة تعيين الأخطاء
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// تنظيف البيانات
  void clear() {
    _notifications = [];
    _unreadCount = 0;
    _error = null;
    notifyListeners();
  }

  /// Legacy methods - for backwards compatibility with old notification model
  void sendNotification({
    required String title,
    required String message,
    required String type,
    required String recipientId,
    String? relatedId,
  }) {
    // This is now a no-op as we use backend notifications
    // Can be used for local testing
    if (kDebugMode) {
      print('Legacy sendNotification called: $title - $message');
    }
  }

  List<AppNotification> getUserNotifications(String userId) {
    return _notifications;
  }

  int getUnreadCount(String userId) {
    return _unreadCount;
  }
}
