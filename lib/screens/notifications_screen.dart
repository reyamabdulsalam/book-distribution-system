import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notificationService = Provider.of<NotificationService>(context);
    final authService = Provider.of<AuthService>(context);

    final userNotifications = notificationService.getUserNotifications(authService.currentUser!.id.toString());
    
    // تحديد اللون بناءً على دور المستخدم
    final userRole = authService.currentUser?.role ?? '';
    final appBarColor = userRole == 'school' ? AppColors.schoolColor : AppColors.courierColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('الإشعارات', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: userNotifications.isEmpty
          ? Center(child: Text('لا توجد إشعارات'))
          : ListView.builder(
        itemCount: userNotifications.length,
        itemBuilder: (context, index) {
          final notification = userNotifications[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: notification.read ? 1 : 3,
            color: notification.read ? Colors.white : appBarColor.withOpacity(0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: notification.read ? Colors.grey.shade200 : appBarColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: ListTile(
              leading: Icon(Icons.notifications, color: notification.read ? Colors.grey : appBarColor),
              title: Text(notification.message),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (notification.type != null)
                    Text('النوع: ${notification.type}'),
                  SizedBox(height: 4),
                  Text(
                    '${notification.createdAt.day}/${notification.createdAt.month}/${notification.createdAt.year} ${notification.createdAt.hour}:${notification.createdAt.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              trailing: !notification.read
                  ? IconButton(
                icon: Icon(Icons.mark_email_read, color: appBarColor),
                onPressed: () {
                  notificationService.markAsRead(notification.id);
                },
              )
                  : null,
            ),
          );
        },
      ),
    );
  }
}