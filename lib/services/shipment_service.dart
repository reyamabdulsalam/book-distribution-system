import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/api_shipment_model.dart';
import '../utils/constants.dart';
import 'api_client.dart';

/// خدمة إدارة الشحنات للمناديب (Drivers)
class ShipmentService with ChangeNotifier {
  List<ApiShipment> _activeShipments = [];
  List<ApiShipment> _historyShipments = [];
  DriverPerformance? _performance;
  bool _isLoading = false;
  String? _error;

  List<ApiShipment> get activeShipments => _activeShipments;
  List<ApiShipment> get historyShipments => _historyShipments;
  DriverPerformance? get performance => _performance;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 1. جلب الشحنات النشطة للمندوب
  Future<bool> fetchActiveShipments({int? driverId, String status = 'pending'}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // بناء query parameters
      final queryParams = <String, String>{
        'status': status,
      };
      
      if (driverId != null) {
        queryParams['assigned_driver'] = driverId.toString();
      }

      final uri = Uri.parse('${AppConfig.apiBaseUrl}/api/warehouses/shipments/')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: ApiClient.defaultHeaders(),
      ).timeout(Duration(seconds: 15));

      if (kDebugMode) {
        print('Active Shipments Response: ${response.statusCode}');
        print('Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final shipmentResponse = ShipmentListResponse.fromJson(data);
        _activeShipments = shipmentResponse.results;
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (response.statusCode == 401) {
        _error = 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً';
      } else {
        _error = 'فشل في جلب الشحنات النشطة';
      }
    } on SocketException {
      _error = 'لا يوجد اتصال بالإنترنت';
    } on TimeoutException {
      _error = 'انتهى وقت الاتصال بالخادم';
    } catch (e) {
      _error = 'حدث خطأ: ${e.toString()}';
      if (kDebugMode) print('Error fetching active shipments: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// 2. جلب سجل الشحنات المكتملة
  Future<bool> fetchShipmentHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse(
          '${AppConfig.apiBaseUrl}/api/warehouses/mobile/driver/shipments/history/');

      final response = await http.get(
        uri,
        headers: ApiClient.defaultHeaders(),
      ).timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final shipmentResponse = ShipmentListResponse.fromJson(data);
        _historyShipments = shipmentResponse.results;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'فشل في جلب سجل الشحنات';
      }
    } catch (e) {
      _error = 'حدث خطأ: ${e.toString()}';
      if (kDebugMode) print('Error fetching history: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// 3. بدء التوصيل
  Future<bool> startDelivery(int shipmentId) async {
    try {
      final uri = Uri.parse(
          '${AppConfig.apiBaseUrl}/api/warehouses/shipments/$shipmentId/start_delivery/');

      final response = await http.post(
        uri,
        headers: ApiClient.defaultHeaders(),
        body: jsonEncode({}),
      ).timeout(Duration(seconds: 15));

      if (kDebugMode) {
        print('✅ Start Delivery Response: ${response.statusCode}');
        print('Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        // تحديث الشحنة محلياً
        await fetchActiveShipments();
        return true;
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error starting delivery: $e');
    }
    return false;
  }

  /// 4. تحديث الموقع الجغرافي
  Future<bool> updateLocation(int shipmentId, double latitude, double longitude) async {
    try {
      final uri = Uri.parse(
          '${AppConfig.apiBaseUrl}/api/warehouses/shipments/$shipmentId/update_location/');

      final response = await http.post(
        uri,
        headers: ApiClient.defaultHeaders(),
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
        }),
      ).timeout(Duration(seconds: 10));

      if (kDebugMode && response.statusCode == 200) {
        print('📍 Location updated successfully');
      }

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) print('❌ Error updating location: $e');
      return false;
    }
  }

  /// 5. رفع صورة الإثبات
  Future<bool> uploadProofPhoto(int shipmentId, String photoBase64) async {
    try {
      final uri = Uri.parse(
          '${AppConfig.apiBaseUrl}/api/warehouses/mobile/driver/shipments/$shipmentId/upload-photo/');

      final response = await http.post(
        uri,
        headers: ApiClient.defaultHeaders(),
        body: jsonEncode({
          'photo_base64': photoBase64,
        }),
      ).timeout(Duration(seconds: 30));

      if (kDebugMode) {
        print('Upload Photo Response: ${response.statusCode}');
      }

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) print('Error uploading photo: $e');
      return false;
    }
  }

  /// 6. رفع التوقيع الرقمي
  Future<bool> uploadSignature(int shipmentId, String signatureBase64) async {
    try {
      final uri = Uri.parse(
          '${AppConfig.apiBaseUrl}/api/warehouses/mobile/driver/shipments/$shipmentId/upload-signature/');

      final response = await http.post(
        uri,
        headers: ApiClient.defaultHeaders(),
        body: jsonEncode({
          'signature_base64': signatureBase64,
        }),
      ).timeout(Duration(seconds: 30));

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) print('Error uploading signature: $e');
      return false;
    }
  }

  /// 6.5 التحقق من رمز QR
  Future<Map<String, dynamic>> verifyQR({
    required int shipmentId,
    required String qrCode,
  }) async {
    try {
      final uri = Uri.parse(
          '${AppConfig.apiBaseUrl}/api/warehouses/shipments/$shipmentId/verify_qr/');

      final response = await http.post(
        uri,
        headers: ApiClient.defaultHeaders(),
        body: jsonEncode({
          'qr_code': qrCode,
        }),
      ).timeout(Duration(seconds: 15));

      if (kDebugMode) {
        print('✅ Verify QR Response: ${response.statusCode}');
        print('Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return {
          'success': true,
          'message': data['message'] ?? 'تم التحقق من رمز QR بنجاح',
          'data': data,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['error'] ?? 'فشل التحقق من رمز QR',
        };
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error verifying QR: $e');
      return {
        'success': false,
        'message': 'حدث خطأ: ${e.toString()}',
      };
    }
  }

  /// 7. إكمال التوصيل
  Future<Map<String, dynamic>> completeDelivery({
    required int shipmentId,
    required String receivedBy,
    String? deliveryNotes,
  }) async {
    try {
      final uri = Uri.parse(
          '${AppConfig.apiBaseUrl}/api/warehouses/shipments/$shipmentId/complete_delivery/');

      final requestBody = {
        'received_by': receivedBy,
      };
      
      if (deliveryNotes != null && deliveryNotes.isNotEmpty) {
        requestBody['delivery_notes'] = deliveryNotes;
      }

      final response = await http.post(
        uri,
        headers: ApiClient.defaultHeaders(),
        body: jsonEncode(requestBody),
      ).timeout(Duration(seconds: 15));

      if (kDebugMode) {
        print('✅ Complete Delivery Response: ${response.statusCode}');
        print('Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        
        // تحديث القوائم
        await fetchActiveShipments();
        await fetchShipmentHistory();
        
        return {
          'success': true,
          'message': data['message'] ?? 'تم إكمال التوصيل بنجاح',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['error'] ?? 'فشل في إكمال التوصيل',
        };
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error completing delivery: $e');
      return {
        'success': false,
        'message': 'حدث خطأ: ${e.toString()}',
      };
    }
  }

  /// 8. جلب إحصائيات أداء المندوب
  Future<bool> fetchPerformance() async {
    try {
      final uri = Uri.parse(
          '${AppConfig.apiBaseUrl}/api/warehouses/mobile/driver/performance/');

      final response = await http.get(
        uri,
        headers: ApiClient.defaultHeaders(),
      ).timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        _performance = DriverPerformance.fromJson(data);
        notifyListeners();
        return true;
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching performance: $e');
    }
    return false;
  }

  /// 9. مسح QR Code (للتحقق فقط)
  Future<QrScanResponse> scanQrCode(int shipmentId, String qrCode) async {
    try {
      final uri = Uri.parse(
          '${AppConfig.apiBaseUrl}/api/warehouses/mobile/driver/shipments/$shipmentId/scan-qr/');

      final response = await http.post(
        uri,
        headers: ApiClient.defaultHeaders(),
        body: jsonEncode({
          'qr_code': qrCode,
        }),
      ).timeout(Duration(seconds: 15));

      if (kDebugMode) {
        print('Scan QR Response: ${response.statusCode}');
        print('Body: ${response.body}');
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return QrScanResponse.fromJson(data);
    } catch (e) {
      if (kDebugMode) print('Error scanning QR: $e');
      return QrScanResponse(
        success: false,
        error: 'حدث خطأ: ${e.toString()}',
      );
    }
  }

  /// الحصول على شحنة محددة
  ApiShipment? getShipmentById(int id) {
    try {
      return _activeShipments.firstWhere((s) => s.id == id);
    } catch (e) {
      try {
        return _historyShipments.firstWhere((s) => s.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  /// إعادة تعيين الأخطاء
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
