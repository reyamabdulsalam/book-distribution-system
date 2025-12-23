import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';
import '../screens/notifications_screen.dart';

class CustomDrawer extends StatelessWidget {
  final String currentScreen;

  const CustomDrawer({Key? key, required this.currentScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final notificationService = Provider.of<NotificationService>(context);
    final user = authService.currentUser;
    final unreadCount = notificationService.getUnreadCount(user?.id.toString() ?? '0');

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.fullName ?? user?.username ?? 'مستخدم'),
            accountEmail: Text(_getRoleName(user?.role ?? '')),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                _getRoleIcon(user?.role ?? ''),
                color: _getRoleColor(user?.role ?? ''),
                size: 40,
              ),
            ),
            decoration: BoxDecoration(
              color: _getRoleColor(user?.role ?? ''),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.home,
                  title: 'الرئيسية',
                  isSelected: currentScreen == 'home',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.notifications,
                  title: 'الإشعارات',
                  badge: unreadCount > 0 ? unreadCount.toString() : null,
                  isSelected: currentScreen == 'notifications',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => NotificationsScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.person,
                  title: 'الملف الشخصي',
                  isSelected: currentScreen == 'profile',
                  onTap: () {
                    Navigator.pop(context);
                    if (user != null) _showProfileDialog(context, user);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings,
                  title: 'الإعدادات',
                  isSelected: currentScreen == 'settings',
                  onTap: () {
                    Navigator.pop(context);
                    _showSettingsDialog(context);
                  },
                ),
                Divider(),
                _buildDrawerItem(
                  context,
                  icon: Icons.logout,
                  title: 'تسجيل الخروج',
                  onTap: () {
                    Navigator.pop(context);
                    _showLogoutDialog(context, authService);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        String? badge,
        bool isSelected = false,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? _getRoleColor(Provider.of<AuthService>(context, listen: false).currentUser?.role ?? '') : Colors.grey[700]),
      title: Text(title, style: TextStyle(
        color: isSelected ? _getRoleColor(Provider.of<AuthService>(context, listen: false).currentUser?.role ?? '') : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      )),
      trailing: badge != null
          ? CircleAvatar(
        radius: 12,
        backgroundColor: Colors.red,
        child: Text(
          badge,
          style: TextStyle(fontSize: 12, color: Colors.white),
        ),
      )
          : null,
      selected: isSelected,
      onTap: onTap,
    );
  }

  String _getRoleName(String role) {
    switch (role) {
      case 'school':
      case 'school_staff':
        return 'موظف مدرسة';
      case 'courier':
      case 'courier_staff':
        return 'مندوب توصيل';
      case 'ministry_driver':
        return 'مندوب الوزارة';
      case 'province_driver':
        return 'مندوب المحافظة';
      case 'governorate':
        return 'موظف محافظة';
      case 'ministry':
        return 'موظف وزارة';
      default:
        return 'مستخدم';
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'school':
      case 'school_staff':
        return Icons.school;
      case 'courier':
      case 'courier_staff':
      case 'ministry_driver':
      case 'province_driver':
        return Icons.local_shipping;
      case 'governorate':
        return Icons.location_city;
      case 'ministry':
        return Icons.business;
      default:
        return Icons.person;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'school':
      case 'school_staff':
        return AppColors.schoolColor;
      case 'courier':
      case 'courier_staff':
      case 'ministry_driver':
      case 'province_driver':
        return AppColors.courierColor;
      case 'governorate':
        return AppColors.governorateColor;
      case 'ministry':
        return AppColors.ministryColor;
      default:
        return Colors.blue;
    }
  }

  void _showProfileDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getRoleIcon(user.role), color: _getRoleColor(user.role)),
            SizedBox(width: 8),
            Text('الملف الشخصي'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.person),
              title: Text('الاسم الكامل'),
              subtitle: Text(user.fullName),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('اسم المستخدم'),
              subtitle: Text(user.username),
            ),
            ListTile(
              leading: Icon(Icons.work),
              title: Text('الدور'),
              subtitle: Text(_getRoleName(user.role)),
            ),
            if (user.schoolId != null)
              ListTile(
                leading: Icon(Icons.school),
                title: Text('المدرسة'),
                subtitle: Text(user.schoolName ?? user.schoolId!),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.settings, color: AppColors.primaryColor),
            SizedBox(width: 8),
            Text('الإعدادات'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text('الإشعارات'),
              subtitle: Text('تفعيل الإشعارات الفورية'),
              value: true,
              onChanged: (value) {},
            ),
            Divider(),
            SwitchListTile(
              title: Text('التحديثات التلقائية'),
              subtitle: Text('تحديث البيانات تلقائياً'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text('تسجيل الخروج'),
          ],
        ),
        content: Text('هل أنت متأكد من أنك تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              authService.logout();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
