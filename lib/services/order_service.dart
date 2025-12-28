import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/order_model.dart';
import '../models/school_request_model.dart';
import '../models/book_model.dart';
import '../utils/constants.dart';
import 'api_client.dart';
import 'dart:math';

/// خدمة إدارة طلبات المدارس - متوافقة مع Backend
class OrderService with ChangeNotifier {
  List<SchoolRequest> _requests = [];
  
  // للتوافقية مع الكود القديم
  List<Order> _orders = [];

  List<SchoolRequest> get requests => _requests;
  List<Order> get orders => _orders; // للتوافقية
  List<Order> get pendingOrders => _orders;

  /// جلب طلبات المدرسة من Backend
  Future<void> fetchSchoolRequests(int schoolId) async {
    try {
      if (kDebugMode) print('📥 Fetching school requests for school_id: $schoolId');
      
      final response = await ApiClient.get('/api/school-requests/?school=$schoolId');
      
      if (kDebugMode) {
        print('📥 Response status: ${response.statusCode}');
        print('📥 Response body: ${response.body}');
      }
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final resultsList = data is List ? data : (data['results'] ?? []);
        
        if (kDebugMode) print('📥 Found ${resultsList.length} requests');
        
        _requests = resultsList.map<SchoolRequest>((item) {
          final req = SchoolRequest.fromJson(item);
          if (kDebugMode) {
            print('📥 Request ${req.id}: ${req.items.length} items');
            for (var i = 0; i < req.items.length; i++) {
              print('   - Item $i: ${req.items[i].bookTitle} (${req.items[i].quantity})');
            }
          }
          return req;
        }).toList();
        
        // تحديث الطلبات القديمة للتوافقية
        _convertRequestsToOrders();
        notifyListeners();
        return;
      }
    } catch (e) {
      if (kDebugMode) print('❌ OrderService.fetchSchoolRequests error: $e');
    }
    
    // في حالة الفشل: استخدام البيانات المحلية
    if (_requests.isEmpty) {
      addSampleOrders();
    }
  }

  /// إنشاء طلب جديد باستخدام Flutter Endpoint
  Future<SchoolRequest?> createSchoolRequest(SchoolRequest request) async {
    try {
      // تحويل البيانات إلى الصيغة الجديدة
      final requestData = {
        'school_id': request.schoolId,
        'items': request.items.map((item) => {
          'subject_name': item.bookTitle ?? item.subject ?? '',
          'grade_name': item.grade ?? '',
          'term_number': item.term == 'first' ? 1 : 2,
          'quantity': item.quantity,
        }).toList(),
      };
      
      if (kDebugMode) {
        print('==================== Creating School Request ====================');
        print('API Endpoint: ${AppConfig.apiBaseUrl}/api/school-requests/create_from_flutter/');
        print('Request data: ${jsonEncode(requestData)}');
        print('Access Token exists: ${ApiClient.accessToken != null}');
      }
      
      final response = await ApiClient.post('/api/school-requests/create_from_flutter/', requestData);
      
      if (kDebugMode) {
        print('==================== Response ====================');
        print('Response status: ${response.statusCode}');
        print('Response headers: ${response.headers}');
        print('Response body: ${response.body}');
        print('========================================================');
      }
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newRequest = SchoolRequest.fromJson(data);
        _requests.add(newRequest);
        _convertRequestsToOrders();
        notifyListeners();
        if (kDebugMode) print('✅ School request created successfully with ID: ${newRequest.id}');
        return newRequest;
      } else {
        if (kDebugMode) {
          print('❌ Failed to create request: ${response.statusCode}');
          print('Error body: ${response.body}');
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ OrderService.createSchoolRequest error: $e');
        print('Stack trace: $stackTrace');
      }
    }
    return null;
  }

  /// تحديث حالة الطلب
  Future<bool> updateRequestStatus(int requestId, String status) async {
    try {
      final response = await ApiClient.patch(
        '/api/school-requests/$requestId/',
        {'status': status},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updatedRequest = SchoolRequest.fromJson(data);
        
        final index = _requests.indexWhere((r) => r.id == requestId);
        if (index != -1) {
          _requests[index] = updatedRequest;
          _convertRequestsToOrders();
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      if (kDebugMode) print('OrderService.updateRequestStatus error: $e');
    }
    return false;
  }

  /// إرسال الطلب (Submit)
  Future<bool> submitRequest(int requestId) async {
    try {
      final response = await ApiClient.post(
        '/api/school-requests/$requestId/submit/',
        {},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updatedRequest = SchoolRequest.fromJson(data);
        
        final index = _requests.indexWhere((r) => r.id == requestId);
        if (index != -1) {
          _requests[index] = updatedRequest;
          _convertRequestsToOrders();
          notifyListeners();
        }
        if (kDebugMode) print('✅ Request submitted successfully');
        return true;
      }
    } catch (e) {
      if (kDebugMode) print('❌ OrderService.submitRequest error: $e');
    }
    return false;
  }

  /// إلغاء الطلب (Cancel)
  Future<bool> cancelRequest(int requestId) async {
    try {
      final response = await ApiClient.post(
        '/api/school-requests/$requestId/cancel/',
        {},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updatedRequest = SchoolRequest.fromJson(data);
        
        final index = _requests.indexWhere((r) => r.id == requestId);
        if (index != -1) {
          _requests[index] = updatedRequest;
          _convertRequestsToOrders();
          notifyListeners();
        }
        if (kDebugMode) print('✅ Request cancelled successfully');
        return true;
      }
    } catch (e) {
      if (kDebugMode) print('❌ OrderService.cancelRequest error: $e');
    }
    return false;
  }

  /// جلب إحصائيات الطلبات
  Future<Map<String, dynamic>?> fetchRequestStats() async {
    try {
      final response = await ApiClient.get('/api/school-requests/stats/');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (kDebugMode) print('📊 Request stats: $data');
        return data;
      }
    } catch (e) {
      if (kDebugMode) print('❌ OrderService.fetchRequestStats error: $e');
    }
    return null;
  }

  /// تحويل SchoolRequest إلى Order للتوافقية مع الكود القديم
  void _convertRequestsToOrders() {
    _orders = _requests.map((req) {
      final books = req.items.map((item) => Book(
        id: item.bookId?.toString() ?? '0',
        title: item.bookTitle ?? item.subject ?? 'كتاب غير معروف',
        grade: item.grade ?? '',
        quantity: item.quantity,
      )).toList();
      
      if (kDebugMode) {
        print('Converting request ${req.id}: ${req.items.length} items -> ${books.length} books');
      }
      
      return Order(
        id: req.id?.toString() ?? UniqueKey().toString(),
        schoolId: req.schoolId.toString(),
        schoolName: req.schoolName ?? '',
        governorateId: 'gov_1',
        books: books,
        status: req.status,
        requestDate: req.requestDate,
        approvalDate: req.approvalDate,
        approvedPercentage: req.status == 'approved' ? 100.0 : 0.0,
        rejectionReason: req.rejectionReason,
        receiptCode: req.receiptCode,
      );
    }).toList();
    
    if (kDebugMode) {
      print('📋 Converted ${_requests.length} requests to ${_orders.length} orders');
    }
  }

  // استلام طلب جديد من المدرسة (للتوافقية)
  void receiveOrder(Order order) {
    _orders.add(order);
    notifyListeners();
  }

  /// جلب الطلبات من الباك-إند (للتوافقية مع الكود القديم)
  Future<void> fetchOrders() async {
    // لا نفعل شيئاً هنا - يُستدعى fetchSchoolRequests بدلاً منه
  }

  // الموافقة على الطلب (محلياً فقط - عادة تُنفذ من الموقع)
  void approveOrder(String orderId, double approvedPercentage) {
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      final receiptCode = _generateReceiptCode();
      _orders[orderIndex] = _orders[orderIndex].copyWith(
        status: 'approved',
        approvalDate: DateTime.now(),
        approvedPercentage: approvedPercentage,
        receiptCode: receiptCode,
      );
      notifyListeners();
    }
  }

  // رفض الطلب
  void rejectOrder(String orderId, String reason) {
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      _orders[orderIndex] = _orders[orderIndex].copyWith(
        status: 'rejected',
        rejectionReason: reason,
      );
      notifyListeners();
    }
  }

  // تحديث حالة الطلب إلى "تم التسليم"
  void markAsDelivered(String orderId) {
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      _orders[orderIndex].status = 'delivered';
      notifyListeners();
    }
  }

  // الحصول على طلبات مدرسة محددة
  List<Order> getSchoolOrders(String schoolId) {
    return _orders.where((order) => order.schoolId == schoolId).toList();
  }

  // توليد كود استلام عشوائي
  String _generateReceiptCode() {
    final random = Random();
    final code = random.nextInt(900000) + 100000;
    return 'RC-$code';
  }

  // إضافة بيانات تجريبية للاختبار
  void addSampleOrders() {
    final sampleBooks1 = [
      Book(id: 'b1', title: 'اللغة العربية', grade: 'خامس أساسي', quantity: 120),
      Book(id: 'b2', title: 'الرياضيات', grade: 'خامس أساسي', quantity: 120),
      Book(id: 'b3', title: 'العلوم', grade: 'خامس أساسي', quantity: 115),
    ];

    final sampleBooks2 = [
      Book(id: 'b4', title: 'اللغة الإنجليزية', grade: 'سابع أساسي', quantity: 95),
      Book(id: 'b5', title: 'الإجتماعيات', grade: 'سابع أساسي', quantity: 95),
    ];

    final sampleBooks3 = [
      Book(id: 'b6', title: 'القرآن الكريم', grade: 'ثالث ابتدائي', quantity: 140),
      Book(id: 'b7', title: 'التربية الإسلامية', grade: 'ثالث ابتدائي', quantity: 140),
    ];

    _orders.add(Order(
      id: 'ORD-1732884521000',
      schoolId: 'school_001',
      schoolName: 'مدرسة النور الابتدائية',
      governorateId: 'gov_1',
      books: sampleBooks1,
      status: 'approved',
      requestDate: DateTime.now().subtract(Duration(days: 5)),
      approvalDate: DateTime.now().subtract(Duration(days: 3)),
      approvedPercentage: 100.0,
      receiptCode: 'RC-847629',
    ));

    _orders.add(Order(
      id: 'ORD-1732884621000',
      schoolId: 'school_001',
      schoolName: 'مدرسة النور الابتدائية',
      governorateId: 'gov_1',
      books: sampleBooks2,
      status: 'pending',
      requestDate: DateTime.now().subtract(Duration(days: 2)),
      approvedPercentage: 0.0,
    ));

    _orders.add(Order(
      id: 'ORD-1732884721000',
      schoolId: 'school_001',
      schoolName: 'مدرسة النور الابتدائية',
      governorateId: 'gov_1',
      books: sampleBooks3,
      status: 'rejected',
      requestDate: DateTime.now().subtract(Duration(days: 7)),
      approvedPercentage: 0.0,
      rejectionReason: 'الكمية المطلوبة تتجاوز المخزون المتاح حالياً',
    ));

    notifyListeners();
  }
}
