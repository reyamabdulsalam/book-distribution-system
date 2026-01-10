import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'api_client.dart';

class AuthService with ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  /// استخراج user_id من JWT token
  Map<String, dynamic>? _decodeJWT(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      final payload = parts[1];
      // إضافة padding إذا لزم الأمر
      var normalized = base64.normalize(payload);
      final decoded = utf8.decode(base64.decode(normalized));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) print('Failed to decode JWT: $e');
      return null;
    }
  }

  /// تسجيل الدخول عبر Backend - متوافق مع API الجديد
  Future<bool> login(String username, String password) async {
    // تجربة الـ endpoint الجديد أولاً
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/users/login/');
    try {
      if (kDebugMode) {
        print('Attempting login to: $uri');
      }
      
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ).timeout(Duration(seconds: 15));

      if (kDebugMode) {
        print('Login response status: ${resp.statusCode}');
        print('Login response body: ${resp.body}');
      }

      if (resp.statusCode == 200) {
        final data = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
        
        // حفظ التوكنات
        final accessToken = data['access'] ?? data['token'];
        final refreshToken = data['refresh'];
        
        if (accessToken != null && accessToken.toString().isNotEmpty) {
          ApiClient.setTokens(
            access: accessToken.toString(), 
            refresh: refreshToken?.toString()
          );
        }

        // استخراج بيانات المستخدم من الاستجابة
        if (data.containsKey('user') && data['user'] != null) {
          final userJson = data['user'] as Map<String, dynamic>;
          _currentUser = User.fromJson(userJson);
          
          if (kDebugMode) {
            print('Login successful.');
            print('User ID: ${_currentUser?.id}');
            print('Username: ${_currentUser?.username}');
            print('Full Name: ${_currentUser?.fullName}');
            print('Role: ${_currentUser?.role}');
            print('School ID: ${_currentUser?.schoolId}');
          }
          
          notifyListeners();
          return true;
        } else {
          // استخراج بيانات المستخدم من JWT token كـ fallback
          int? userId;
          String? role;
          String? fullName;
          int? schoolId;
          
          if (accessToken != null) {
            final jwtData = _decodeJWT(accessToken.toString());
            if (jwtData != null) {
              userId = jwtData['user_id'] is int 
                  ? jwtData['user_id'] 
                  : int.tryParse(jwtData['user_id'].toString());
              role = jwtData['role']?.toString();
              fullName = jwtData['full_name']?.toString() ?? jwtData['name']?.toString();
              schoolId = jwtData['school_id'] is int
                  ? jwtData['school_id']
                  : int.tryParse(jwtData['school_id']?.toString() ?? '');
              
              if (kDebugMode) {
                print('Extracted from JWT:');
                print('  user_id: $userId');
                print('  role: $role');
                print('  full_name: $fullName');
                print('  school_id: $schoolId');
              }
            }
          }

          // إنشاء user object من بيانات JWT
          _currentUser = User(
            id: userId ?? 0,
            username: username,
            fullName: fullName ?? username,
            role: role ?? 'school_staff',
            schoolId: schoolId?.toString(),
          );
          
          if (kDebugMode) {
            print('Login successful with JWT data');
            print('User Role: ${_currentUser?.role}');
          }
          
          notifyListeners();
          return true;
        }
      } else {
        if (kDebugMode) {
          print('Login failed: ${resp.statusCode} - ${resp.body}');
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('AuthService login error: $e');
        print('Stack trace: $stackTrace');
      }
    }

    // Fallback للاختبار المحلي
    if (kDebugMode && _tryLocalLogin(username, password)) {
      return true;
    }

    return false;
  }

  /// تسجيل دخول محلي للاختبار فقط (يُحذف في الإنتاج)
  bool _tryLocalLogin(String username, String password) {
    // مناديب
    if (username == 'driver' && password == 'driver123') {
      _currentUser = User(
        id: 1,
        username: 'driver1',
        fullName: 'محمد أحمد',
        role: 'ministry_driver',
      );
      notifyListeners();
      return true;
    }

    // موظفي المدارس
    if (username == 'school' && password == 'school123') {
      _currentUser = User(
        id: 2,
        username: 'school1',
        fullName: 'مدرسة النهضة',
        role: 'school_staff',
        schoolId: '1',
        schoolName: 'مدرسة النهضة',
      );
      notifyListeners();
      return true;
    }

    return false;
  }

  /// التحقق من صلاحية الجلسة
  Future<bool> checkSession() async {
    if (ApiClient.accessToken == null) {
      return false;
    }

    try {
      final response = await ApiClient.get('/api/users/me/');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = User.fromJson(data);
        notifyListeners();
        return true;
      }
    } catch (e) {
      if (kDebugMode) print('Session check error: $e');
    }

    return false;
  }

  /// تسجيل الخروج
  void logout() {
    _currentUser = null;
    ApiClient.clearTokens();
    notifyListeners();
    if (kDebugMode) print('✅ User logged out successfully');
  }
}
