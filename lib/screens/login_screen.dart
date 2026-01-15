import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // محاكاة تأخير الشبكة
    await Future.delayed(Duration(milliseconds: 800));

    final authService = Provider.of<AuthService>(context, listen: false);
    bool success = false;
    try {
      success = await authService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );
    } catch (e) {
      if (kDebugMode) print('Login error: $e');
      success = false;
    }

    setState(() => _isLoading = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('اسم المستخدم أو كلمة المرور غير صحيحة', style: TextStyle(fontFamily: 'Cairo')),
            ],
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      // بعد تسجيل الدخول الناجح، حاول جلب الإشعارات فوراً
      try {
        final notificationService = Provider.of<NotificationService>(context, listen: false);
        notificationService.fetchNotifications();
      } catch (e) {
        if (kDebugMode) print('Failed to fetch notifications after login: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // الشعار
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.menu_book, size: 80, color: Colors.blue.shade700),
                  ),
                  SizedBox(height: 24),
                  
                  // العنوان
                  Text(
                    'نظام توزيع الكتب المدرسية',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'سجّل دخولك للمتابعة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 40),

                  // حقل اسم المستخدم
                  TextFormField(
                    controller: _usernameController,
                    textDirection: TextDirection.ltr,
                    style: TextStyle(fontFamily: 'Cairo', color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      labelText: 'اسم المستخدم',
                      labelStyle: TextStyle(fontFamily: 'Cairo', color: Colors.black, fontSize: 14),
                      hintText: 'school / courier',
                      hintStyle: TextStyle(fontFamily: 'Cairo', color: Colors.grey.shade600, fontSize: 14),
                      prefixIcon: Icon(Icons.person, color: Colors.black87, size: 24),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.black54, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال اسم المستخدم';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(height: 16),

                  // حقل كلمة المرور
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(fontFamily: 'Cairo', color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      labelStyle: TextStyle(fontFamily: 'Cairo', color: Colors.black, fontSize: 14),
                      hintText: '••••••••',
                      hintStyle: TextStyle(fontFamily: 'Cairo', color: Colors.grey.shade600, fontSize: 14),
                      prefixIcon: Icon(Icons.lock, color: Colors.black87, size: 24),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.black87,
                          size: 24,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.black54, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال كلمة المرور';
                      }
                      if (value.length < 6) {
                        return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  SizedBox(height: 24),

                  // زر تسجيل الدخول
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'تسجيل الدخول',
                              style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  SizedBox(height: 32),

                  // معلومات تجريبية
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade700, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info, size: 24, color: Colors.blue.shade900),
                            SizedBox(width: 8),
                            Text(
                              'حسابات تجريبية',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        _buildAccountInfo(Icons.school, 'مدرسة', 'school', 'school123'),
                        SizedBox(height: 8),
                        _buildAccountInfo(Icons.local_shipping, 'مندوب', 'courier', 'courier123'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountInfo(IconData icon, String role, String username, String password) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue.shade900),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            '$role: $username / $password',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14, 
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}