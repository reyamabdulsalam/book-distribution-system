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

  /// تسجيل الدخول عبر Backend - يحاول أكثر من endpoint لتوافق الـ Backend
  Future<bool> login(String username, String password) async {
    // ترتيب المحاولة يشمل المسارات المحتملة للباك-إند الجديد
    final endpoints = <String>[
      '/api/users/login/',
      '/api/auth/login/',
      '/api/token/',
      '/api/warehouses/login/',
      '/api/warehouses/mobile/login/',
    ];

    for (final path in endpoints) {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
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

        if (resp.statusCode == 200 || resp.statusCode == 201) {
            final data = jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;

            // دعم مفاتيح توكن متعددة حسب الباك-إند أو داخل حقول data/result
            final normalized = _unwrapData(data);
            final accessToken = normalized['access'] ?? normalized['token'] ??
                normalized['access_token'] ?? normalized['auth_token'] ?? normalized['key'];
            final refreshToken = normalized['refresh'] ?? normalized['refresh_token'];

          if (accessToken != null && accessToken.toString().isNotEmpty) {
            ApiClient.setTokens(
              access: accessToken.toString(),
              refresh: refreshToken?.toString(),
            );
          }

          // إذا أعاد الـ Backend كائن user مباشرة
          // أحياناً تكون بيانات المستخدم داخل data أو result
          final userJson = (data['user'] ?? normalized['user']);
          if (userJson is Map<String, dynamic>) {
            _currentUser = User.fromJson(userJson);
            _logUser();
            notifyListeners();
            return true;
          }

          // محاولة استخراج بيانات من الـ JWT عند عدم وجود user
          if (accessToken != null) {
            final jwtData = _decodeJWT(accessToken.toString());
            if (jwtData != null) {
              _currentUser = User(
                id: _toInt(jwtData['user_id']) ?? 0,
                username: username,
                fullName: (jwtData['full_name'] ?? jwtData['name'] ?? username).toString(),
                role: (jwtData['role'] ?? 'school_staff').toString(),
                schoolId: _toInt(jwtData['school_id'])?.toString(),
              );
              _logUser(fromJwt: true);
              notifyListeners();
              return true;
            }
          }
        }
      } catch (e, stackTrace) {
        if (kDebugMode) {
          print('AuthService login error on $path: $e');
          print('Stack trace: $stackTrace');
        }
      }
    }

    // Fallback للاختبار المحلي
    if (kDebugMode && _tryLocalLogin(username, password)) {
      return true;
    }

    if (kDebugMode) {
      print('All login endpoints failed for user: $username');
    }
    return false;
  }

  /// يفك التغليف إذا كان الرد على شكل {data: {...}} أو {result: {...}}
  Map<String, dynamic> _unwrapData(Map<String, dynamic> data) {
    if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
      return {...data, ... (data['data'] as Map<String, dynamic>)};
    }
    if (data.containsKey('result') && data['result'] is Map<String, dynamic>) {
      return {...data, ... (data['result'] as Map<String, dynamic>)};
    }
    return data;
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  void _logUser({bool fromJwt = false}) {
    if (!kDebugMode) return;
    print(fromJwt ? 'Login successful (from JWT data)' : 'Login successful.');
    print('User ID: ${_currentUser?.id}');
    print('Username: ${_currentUser?.username}');
    print('Full Name: ${_currentUser?.fullName}');
    print('Role: ${_currentUser?.role}');
    print('School ID: ${_currentUser?.schoolId}');
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
