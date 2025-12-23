import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/api_shipment_model.dart';
import '../utils/constants.dart';
import 'api_client.dart';

/// خدمة إدارة التوصيل للمدارس (School Staff)
class SchoolDeliveryService with ChangeNotifier {
  List<ApiShipment> _incomingDeliveries = [];
  List<ApiShipment> _receivedDeliveries = [];
  bool _isLoading = false;
  String? _error;

  List<ApiShipment> get incomingDeliveries => _incomingDeliveries;
  List<ApiShipment> get receivedDeliveries => _receivedDeliveries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 1. جلب الشحنات الواردة للمدرسة
  Future<bool> fetchIncomingDeliveries({String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      var uri = Uri.parse(
          '${AppConfig.apiBaseUrl}/api/warehouses/mobile/school/deliveries/incoming/');

      if (status != null) {
        uri = uri.replace(queryParameters: {'status': status});
      }

      final response = await http.get(
        uri,
        headers: ApiClient.defaultHeaders(),
      ).timeout(Duration(seconds: 15));

      if (kDebugMode) {
        print('Incoming Deliveries Response: ${response.statusCode}');
        print('Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final shipmentResponse = ShipmentListResponse.fromJson(data);
        
        // تصنيف الشحنات
        _incomingDeliveries = shipmentResponse.results
            .where((s) => !s.isDelivered)
            .toList();
        _receivedDeliveries = shipmentResponse.results
            .where((s) => s.isDelivered)
            .toList();
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (response.statusCode == 401) {
        _error = 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً';
      } else {
        _error = 'فشل في جلب الشحنات الواردة';
      }
    } on SocketException {
      _error = 'لا يوجد اتصال بالإنترنت';
    } on TimeoutException {
      _error = 'انتهى وقت الاتصال بالخادم';
    } catch (e) {
      _error = 'حدث خطأ: ${e.toString()}';
      if (kDebugMode) print('Error fetching incoming deliveries: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// 2. استلام الشحنة بدون QR (استلام يدوي)
  Future<Map<String, dynamic>> receiveShipmentManually({
    required int shipmentId,
    required String receiverName,
    String? receiverNotes,
    String deliveryCondition = 'good', // good, damaged, partial
  }) async {
    try {
      final uri = Uri.parse(
          '${AppConfig.apiBaseUrl}/api/warehouses/mobile/school/deliveries/$shipmentId/receive/');

      final response = await http.post(
        uri,
        headers: ApiClient.defaultHeaders(),
        body: jsonEncode({
          'receiver_name': receiverName,
          'receiver_notes': receiverNotes ?? '',
          'delivery_condition': deliveryCondition,
        }),
      ).timeout(Duration(seconds: 15));

      if (kDebugMode) {
        print('Receive Shipment Response: ${response.statusCode}');
        print('Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        
        // تحديث القوائم
        await fetchIncomingDeliveries();
        
        return {
          'success': true,
          'message': data['message'] ?? 'تم تأكيد الاستلام بنجاح',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['error'] ?? 'فشل في تأكيد الاستلام',
        };
      }
    } catch (e) {
      if (kDebugMode) print('Error receiving shipment: $e');
      return {
        'success': false,
        'message': 'حدث خطأ: ${e.toString()}',
      };
    }
  }

  /// 3. استلام الشحنة بمسح QR Code (الطريقة المفضلة) ⭐
  Future<Map<String, dynamic>> receiveShipmentWithQr({
    required int shipmentId,
    required String qrToken,
    required String receiverName,
    String? receiverNotes,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final uri = Uri.parse(
          '${AppConfig.apiBaseUrl}/api/warehouses/mobile/school/deliveries/$shipmentId/scan-qr/');

      final body = {
        'qr_token': qrToken,
        'receiver_name': receiverName,
        'receiver_notes': receiverNotes ?? '',
      };

      if (latitude != null && longitude != null) {
        body['latitude'] = latitude.toString();
        body['longitude'] = longitude.toString();
      }

      final response = await http.post(
        uri,
        headers: ApiClient.defaultHeaders(),
        body: jsonEncode(body),
      ).timeout(Duration(seconds: 15));

      if (kDebugMode) {
        print('Scan QR Response: ${response.statusCode}');
        print('Body: ${response.body}');
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        // تحديث القوائم
        await fetchIncomingDeliveries();
        
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'تم تأكيد الاستلام بنجاح',
          'shipment': data['shipment'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'فشل في تأكيد الاستلام',
          'reason': data['reason'],
        };
      }
    } catch (e) {
      if (kDebugMode) print('Error scanning QR: $e');
      return {
        'success': false,
        'message': 'حدث خطأ: ${e.toString()}',
      };
    }
  }

  /// 4. API الموحد لمسح QR Code (للجميع)
  Future<QrScanResponse> scanQrCodeUnified({
    required String token,
    String? recipientName,
    String? notes,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final uri = Uri.parse(
          '${AppConfig.apiBaseUrl}/api/warehouses/qr/scan/');

      final body = {
        'token': token,
      };

      if (recipientName != null) body['recipient_name'] = recipientName;
      if (notes != null) body['notes'] = notes;
      if (latitude != null && longitude != null) {
        body['latitude'] = latitude.toString();
        body['longitude'] = longitude.toString();
      }

      final response = await http.post(
        uri,
        headers: ApiClient.defaultHeaders(),
        body: jsonEncode(body),
      ).timeout(Duration(seconds: 15));

      if (kDebugMode) {
        print('Unified QR Scan Response: ${response.statusCode}');
        print('Body: ${response.body}');
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final qrResponse = QrScanResponse.fromJson(data);

      if (qrResponse.success) {
        // تحديث القوائم
        await fetchIncomingDeliveries();
      }

      return qrResponse;
    } catch (e) {
      if (kDebugMode) print('Error unified QR scan: $e');
      return QrScanResponse(
        success: false,
        error: 'حدث خطأ: ${e.toString()}',
      );
    }
  }

  /// 5. التحقق من QR Code (بدون تأكيد)
  Future<QrVerifyResponse> verifyQrCode(String token) async {
    try {
      final uri = Uri.parse(
          '${AppConfig.apiBaseUrl}/api/warehouses/qr/verify/?token=$token');

      final response = await http.get(
        uri,
        headers: ApiClient.defaultHeaders(),
      ).timeout(Duration(seconds: 10));

      if (kDebugMode) {
        print('Verify QR Response: ${response.statusCode}');
        print('Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return QrVerifyResponse.fromJson(data);
      } else {
        return QrVerifyResponse(valid: false);
      }
    } catch (e) {
      if (kDebugMode) print('Error verifying QR: $e');
      return QrVerifyResponse(valid: false);
    }
  }

  /// الحصول على شحنة محددة
  ApiShipment? getShipmentById(int id) {
    try {
      return _incomingDeliveries.firstWhere((s) => s.id == id);
    } catch (e) {
      try {
        return _receivedDeliveries.firstWhere((s) => s.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  /// فلترة الشحنات حسب الحالة
  List<ApiShipment> getShipmentsByStatus(String status) {
    return [..._incomingDeliveries, ..._receivedDeliveries]
        .where((s) => s.status == status)
        .toList();
  }

  /// الحصول على عدد الشحنات المعلقة
  int get pendingCount {
    return _incomingDeliveries
        .where((s) => s.status == 'out_for_delivery' || s.status == 'assigned')
        .length;
  }

  /// إعادة تعيين الأخطاء
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
