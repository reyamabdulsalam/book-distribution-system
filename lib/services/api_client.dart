import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiClient {
  static String? _accessToken;
  static String? _refreshToken;

  static void setTokens({String? access, String? refresh}) {
    _accessToken = access;
    _refreshToken = refresh;
  }

  static String? get accessToken => _accessToken;
  static String? get refreshToken => _refreshToken;

  static void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
  }

  static Map<String, String> defaultHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  /// محاولة تحديث التوكن عند انتهاء الصلاحية
  static Future<bool> refreshAccessToken() async {
    if (_refreshToken == null || _refreshToken!.isEmpty) {
      return false;
    }

    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/auth/refresh/');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': _refreshToken}),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access'];
        return true;
      }
    } catch (e) {
      print('Failed to refresh token: $e');
    }
    return false;
  }

  /// دالة مساعدة لإرسال GET مع معالجة 401
  static Future<http.Response> get(String endpoint) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
    
    if (kDebugMode) {
      print('🔵 GET Request to: $uri');
      print('🔵 Headers: ${defaultHeaders()}');
    }
    
    var response = await http.get(uri, headers: defaultHeaders());

    if (kDebugMode) {
      print('🔵 GET Response Status: ${response.statusCode}');
      if (response.statusCode >= 400) {
        print('❌ Error Response Body: ${response.body}');
      }
    }

    // إذا كان 401، حاول تحديث التوكن وإعادة المحاولة
    if (response.statusCode == 401) {
      if (kDebugMode) print('⚠️ 401 Unauthorized - Refreshing token...');
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        if (kDebugMode) print('✅ Token refreshed, retrying GET...');
        response = await http.get(uri, headers: defaultHeaders());
        if (kDebugMode) {
          print('🔵 Retry GET Status: ${response.statusCode}');
          if (response.statusCode >= 400) {
            print('❌ Retry Error Body: ${response.body}');
          }
        }
      }
    }
    
    return response;
  }

  /// دالة مساعدة لإرسال POST مع معالجة 401
  static Future<http.Response> post(String endpoint, dynamic body) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
    
    if (kDebugMode) {
      print('🔵 POST Request to: $uri');
      print('🔵 Headers: ${defaultHeaders()}');
      print('🔵 Body: ${jsonEncode(body)}');
    }
    
    var response = await http.post(
      uri,
      headers: defaultHeaders(),
      body: jsonEncode(body),
    );

    if (kDebugMode) {
      print('🔵 Response Status: ${response.statusCode}');
      print('🔵 Response Body: ${response.body}');
    }

    if (response.statusCode == 401) {
      if (kDebugMode) print('⚠️ 401 Unauthorized - Refreshing token...');
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        if (kDebugMode) print('✅ Token refreshed, retrying request...');
        response = await http.post(
          uri,
          headers: defaultHeaders(),
          body: jsonEncode(body),
        );
        if (kDebugMode) {
          print('🔵 Retry Response Status: ${response.statusCode}');
          print('🔵 Retry Response Body: ${response.body}');
        }
      }
    }
    return response;
  }

  /// دالة مساعدة لإرسال PUT
  static Future<http.Response> put(String endpoint, dynamic body) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
    var response = await http.put(
      uri,
      headers: defaultHeaders(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        response = await http.put(
          uri,
          headers: defaultHeaders(),
          body: jsonEncode(body),
        );
      }
    }
    return response;
  }

  /// دالة مساعدة لإرسال PATCH
  static Future<http.Response> patch(String endpoint, dynamic body) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
    var response = await http.patch(
      uri,
      headers: defaultHeaders(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        response = await http.patch(
          uri,
          headers: defaultHeaders(),
          body: jsonEncode(body),
        );
      }
    }
    return response;
  }

  /// دالة مساعدة لإرسال DELETE
  static Future<http.Response> delete(String endpoint) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
    var response = await http.delete(uri, headers: defaultHeaders());

    if (response.statusCode == 401) {
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        response = await http.delete(uri, headers: defaultHeaders());
      }
    }
    return response;
  }
}

