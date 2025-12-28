# 📱 دليل تكامل Mobile App مع Backend APIs
## Book Distribution System - Mobile Integration Guide

**التاريخ:** 24 ديسمبر 2025  
**الإصدار:** 1.0.0  
**الحالة:** ✅ متكامل بالكامل

---

## 📋 جدول المحتويات

1. [نظرة عامة](#نظرة-عامة)
2. [APIs المندوبين](#apis-المندوبين)
3. [APIs المدارس](#apis-المدارس)
4. [APIs الإشعارات](#apis-الإشعارات)
5. [المصادقة والصلاحيات](#المصادقة-والصلاحيات)
6. [نماذج البيانات](#نماذج-البيانات)
7. [معالجة الأخطاء](#معالجة-الأخطاء)
8. [أمثلة Flutter](#أمثلة-flutter)

---

## 🎯 نظرة عامة

### الخدمات المتوفرة

```dart
// lib/services/
├── shipment_service.dart       // خدمة المندوبين - 9 APIs
├── school_delivery_service.dart // خدمة المدارس - 4 APIs
└── notification_service.dart    // خدمة الإشعارات - 3 APIs
```

### Base URL
```dart
const String baseUrl = 'http://45.77.65.134/api';
```

### Authentication Header
```dart
headers: {
  'Authorization': 'Bearer YOUR_TOKEN_HERE',
  'Content-Type': 'application/json; charset=utf-8',
}
```

---

## 🚚 APIs المندوبين

### Service: `ShipmentService`

#### 1️⃣ جلب الشحنات النشطة ⭐
```dart
Future<bool> fetchActiveShipments()
```

**Endpoint:** `GET /api/warehouses/mobile/driver/shipments/active/`

**Response Model:**
```dart
{
  "success": true,
  "count": 3,
  "shipments": [
    {
      "id": 123,
      "tracking_code": "SHP-ABC123",
      "status": "assigned",
      "qr_code": {
        "token": "550e8400-...",
        "image": "base64...",
        "expires_at": "2025-12-27T10:00:00Z",
        "status": "active",
        "used": false
      },
      "courier": {
        "id": 456,
        "name": "محمد أحمد",
        "phone": "01234567890"
      }
    }
  ]
}
```

**Usage:**
```dart
final shipmentService = Provider.of<ShipmentService>(context);
await shipmentService.fetchActiveShipments();
final shipments = shipmentService.activeShipments;
```

---

#### 2️⃣ جلب سجل الشحنات المكتملة
```dart
Future<bool> fetchShipmentHistory()
```

**Endpoint:** `GET /api/warehouses/mobile/driver/shipments/history/`

---

#### 3️⃣ بدء التوصيل
```dart
Future<bool> startDelivery(int shipmentId, double latitude, double longitude)
```

**Endpoint:** `POST /api/warehouses/mobile/driver/shipments/{id}/start/`

**Request:**
```json
{
  "latitude": 30.0444,
  "longitude": 31.2357
}
```

---

#### 4️⃣ تحديث الموقع الجغرافي
```dart
Future<bool> updateLocation(int shipmentId, double latitude, double longitude)
```

**Endpoint:** `POST /api/warehouses/mobile/driver/shipments/{id}/location/`

---

#### 5️⃣ رفع صورة الإثبات
```dart
Future<bool> uploadProofPhoto(int shipmentId, String photoBase64)
```

**Endpoint:** `POST /api/warehouses/mobile/driver/shipments/{id}/upload-photo/`

---

#### 6️⃣ رفع التوقيع الرقمي
```dart
Future<bool> uploadSignature(int shipmentId, String signatureBase64)
```

**Endpoint:** `POST /api/warehouses/mobile/driver/shipments/{id}/upload-signature/`

---

#### 7️⃣ مسح QR Code للتسليم ⭐⭐⭐
```dart
Future<QrScanResponse> scanQrCodeUnified({
  required String token,
  String? recipientName,
  String? notes,
  double? latitude,
  double? longitude,
})
```

**Endpoint:** `POST /api/warehouses/mobile/unified-scan/`

**Request:**
```json
{
  "qr_token": "550e8400-e29b-41d4-a716-446655440000",
  "recipient_name": "أحمد محمد",
  "latitude": 30.0444,
  "longitude": 31.2357,
  "notes": "تم التسليم بحالة جيدة"
}
```

**Response:**
```json
{
  "success": true,
  "message": "تم تأكيد التسليم بنجاح",
  "shipment": {
    "id": 123,
    "tracking_code": "SHP-ABC123",
    "status": "delivered"
  },
  "delivery_details": {
    "delivered_at": "2025-12-24T10:30:00Z",
    "recipient_name": "أحمد محمد",
    "location": {
      "latitude": 30.0444,
      "longitude": 31.2357
    },
    "qr_used": true
  }
}
```

**Error Handling:**
```dart
if (!response.success) {
  switch (response.reason) {
    case 'qr_expired':
      // رمز QR منتهي الصلاحية
      break;
    case 'qr_already_used':
      // رمز QR مستخدم مسبقاً
      break;
    case 'invalid_qr':
      // رمز QR غير صالح
      break;
    case 'shipment_not_assigned':
      // الشحنة غير مسندة لك
      break;
    case 'already_delivered':
      // الشحنة تم تسليمها مسبقاً
      break;
  }
}
```

---

#### 8️⃣ إكمال التوصيل يدوياً
```dart
Future<Map<String, dynamic>> completeDelivery({
  required int shipmentId,
  required String recipientName,
  String? deliveryNotes,
  required double latitude,
  required double longitude,
})
```

**Endpoint:** `POST /api/warehouses/mobile/driver/shipments/{id}/complete/`

---

#### 9️⃣ جلب إحصائيات الأداء
```dart
Future<bool> fetchPerformance()
```

**Endpoint:** `GET /api/warehouses/mobile/driver/performance/`

**Response:**
```json
{
  "total_deliveries": 50,
  "completed_deliveries": 45,
  "pending_deliveries": 5,
  "recent_deliveries_30_days": 15,
  "success_rate": 90.0
}
```

---

## 🏫 APIs المدارس

### Service: `SchoolDeliveryService`

#### 1️⃣ جلب الشحنات الواردة ⭐⭐⭐
```dart
Future<bool> fetchIncomingDeliveries({String? status})
```

**Endpoint:** `GET /api/warehouses/school/shipments/incoming/`

**Query Parameters:**
- `status` (optional): فلترة حسب الحالة
- `limit` (optional): عدد النتائج (default: 20)

**Response:**
```json
{
  "success": true,
  "school": {
    "id": 45,
    "name": "مدرسة النور الابتدائية",
    "province": "القاهرة",
    "directorate": "شرق القاهرة"
  },
  "count": 5,
  "shipments": [
    {
      "id": 123,
      "tracking_code": "SHP-ABC123",
      "status": "assigned",
      "status_display": "مُسندة لمندوب",
      "books": [
        {
          "book_title": "الرياضيات - الصف الرابع",
          "quantity": 100
        }
      ],
      "total_books": 2,
      "courier": {
        "id": 456,
        "name": "محمد أحمد",
        "username": "driver123",
        "phone": "01234567890"
      },
      "qr_code": {
        "token": "550e8400-...",
        "image": "base64_string...",
        "expires_at": "2025-12-27T10:00:00Z",
        "status": "active",
        "used": false
      },
      "delivery_info": {
        "recipient_name": "",
        "delivered_at": null,
        "notes": ""
      },
      "timestamps": {
        "created_at": "2025-12-24T10:00:00Z",
        "updated_at": "2025-12-24T10:00:00Z"
      }
    }
  ],
  "stats": {
    "total": 10,
    "pending": 1,
    "assigned": 3,
    "out_for_delivery": 2,
    "delivered": 3,
    "confirmed": 1
  }
}
```

**Usage:**
```dart
final schoolService = Provider.of<SchoolDeliveryService>(context);
await schoolService.fetchIncomingDeliveries();

// Shipments not delivered yet
final incoming = schoolService.incomingDeliveries;

// Already received shipments
final received = schoolService.receivedDeliveries;
```

---

#### 2️⃣ استلام الشحنة يدوياً
```dart
Future<Map<String, dynamic>> receiveShipmentManually({
  required int shipmentId,
  required String receiverName,
  String? receiverNotes,
  String deliveryCondition = 'good',
})
```

**Endpoint:** `POST /api/warehouses/mobile/school/deliveries/{id}/receive/`

**Request:**
```json
{
  "receiver_name": "أحمد محمد",
  "notes": "تم الاستلام بحالة جيدة",
  "condition": "good"
}
```

---

#### 3️⃣ استلام الشحنة بمسح QR
```dart
Future<Map<String, dynamic>> receiveShipmentWithQr({
  required int shipmentId,
  required String qrToken,
  required String receiverName,
  String? receiverNotes,
  double? latitude,
  double? longitude,
})
```

**Endpoint:** `POST /api/warehouses/mobile/school/deliveries/{id}/scan-qr/`

---

#### 4️⃣ عرض طلبات المدرسة
```dart
// Using OrderService
Future<List<SchoolRequest>> fetchSchoolRequests()
```

**Endpoint:** `GET /api/school-requests/?school_id={school_id}`

---

## 🔔 APIs الإشعارات

### Service: `NotificationService`

#### 1️⃣ جلب الإشعارات ⭐
```dart
Future<bool> fetchNotifications()
```

**Endpoint:** `GET /api/notifications/`

**Response:**
```json
{
  "count": 10,
  "unread_count": 3,
  "notifications": [
    {
      "id": 1,
      "message": "شحنة واردة جديدة - رقم التتبع: SHP-ABC123",
      "read": false,
      "type": "shipment_incoming",
      "data": {
        "shipment_id": 123,
        "tracking_code": "SHP-ABC123"
      },
      "created_at": "2025-12-24T10:00:00Z"
    }
  ]
}
```

**Usage:**
```dart
final notificationService = Provider.of<NotificationService>(context);
await notificationService.fetchNotifications();

final notifications = notificationService.notifications;
final unreadCount = notificationService.unreadCount;
```

---

#### 2️⃣ تسجيل Device Token
```dart
Future<bool> registerDeviceToken({
  required String deviceToken,
  required String deviceType,
  String? deviceName,
})
```

**Endpoint:** `POST /api/notifications/register-device/`

**Request:**
```json
{
  "device_token": "firebase_token_here",
  "device_type": "android",
  "device_name": "Samsung Galaxy S21"
}
```

**Usage:**
```dart
// في initState أو عند تسجيل الدخول
final fcmToken = await FirebaseMessaging.instance.getToken();
await notificationService.registerDeviceToken(
  deviceToken: fcmToken!,
  deviceType: Platform.isAndroid ? 'android' : 'ios',
  deviceName: await DeviceInfo.getDeviceName(),
);
```

---

#### 3️⃣ تعليم الإشعار كمقروء
```dart
Future<bool> markAsRead(int notificationId)
```

**Endpoint:** `POST /api/notifications/{id}/mark-read/`

---

## 🔐 المصادقة والصلاحيات

### تسجيل الدخول

**Service:** `AuthService`

```dart
Future<Map<String, dynamic>> login(String username, String password)
```

**Endpoint:** `POST /api/auth/login/`

**Request:**
```json
{
  "username": "user123",
  "password": "password"
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "username": "driver123",
    "role": "ministry_driver",
    "name": "محمد أحمد"
  }
}
```

### الصلاحيات

| Role | الوصف | APIs المتاحة |
|------|-------|-------------|
| `ministry_driver` | مندوب الوزارة | جميع APIs المندوبين |
| `province_driver` | مندوب المحافظة | جميع APIs المندوبين |
| `school_admin` | مدير المدرسة | جميع APIs المدارس |
| `school_staff` | موظف المدرسة | جميع APIs المدارس |

---

## 📊 نماذج البيانات

### ApiShipment

```dart
class ApiShipment {
  final int id;
  final String trackingCode;
  final String status;
  final String? statusDisplay;
  final List<ShipmentBook> books;
  
  // QR Code
  final String? qrCodeImage;     // base64
  final String? qrToken;         // token for scanning
  final DateTime? qrExpiresAt;
  final String? qrStatus;        // active, expired, used
  final bool? qrUsed;
  
  // Courier Info
  final String? assignedCourierName;
  final int? assignedCourierId;
  final String? courierPhone;
  
  // Delivery Info
  final String? recipientName;
  final DateTime? deliveredAt;
  final String? deliveryNotes;
  final double? latitude;
  final double? longitude;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime? updatedAt;
}
```

### QrScanResponse

```dart
class QrScanResponse {
  final bool success;
  final String? message;
  final String? error;
  final String? reason;  // qr_expired, qr_already_used, etc.
  final ApiShipment? shipment;
  final Map<String, dynamic>? deliveryDetails;
}
```

### AppNotification

```dart
class AppNotification {
  final int id;
  final String message;
  final bool read;
  final String? type;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
}
```

---

## ⚠️ معالجة الأخطاء

### أخطاء الشبكة

```dart
try {
  await service.fetchData();
} on SocketException {
  // لا يوجد اتصال بالإنترنت
  showError('لا يوجد اتصال بالإنترنت');
} on TimeoutException {
  // انتهى وقت الاتصال
  showError('انتهى وقت الاتصال بالخادم');
} catch (e) {
  // خطأ عام
  showError('حدث خطأ: ${e.toString()}');
}
```

### أخطاء QR Code

```dart
final response = await service.scanQrCodeUnified(token: token);

if (!response.success) {
  final errorMessages = {
    'qr_expired': 'رمز QR منتهي الصلاحية (72 ساعة)',
    'qr_already_used': 'رمز QR تم استخدامه مسبقاً',
    'invalid_qr': 'رمز QR غير صالح',
    'shipment_not_assigned': 'الشحنة غير مسندة لك',
    'already_delivered': 'الشحنة تم تسليمها مسبقاً',
  };
  
  final message = errorMessages[response.reason] ?? response.error;
  showError(message);
}
```

### أخطاء HTTP

| Status Code | المعنى | الإجراء |
|------------|--------|---------|
| 401 | Unauthorized | إعادة تسجيل الدخول |
| 403 | Forbidden | لا تملك الصلاحيات |
| 404 | Not Found | الشحنة غير موجودة |
| 500 | Server Error | خطأ في الخادم |

---

## 💻 أمثلة Flutter

### مثال 1: المندوب - مسح QR Code

```dart
import 'package:mobile_scanner/mobile_scanner.dart';

class DriverQrScanner extends StatefulWidget {
  @override
  _DriverQrScannerState createState() => _DriverQrScannerState();
}

class _DriverQrScannerState extends State<DriverQrScanner> {
  final MobileScannerController controller = MobileScannerController();
  
  Future<void> _handleQrCode(String qrData) async {
    // Extract token from QR: "SHIPMENT:<token>:<id>"
    final token = SchoolDeliveryService.extractQrToken(qrData);
    if (token == null) {
      _showError('رمز QR غير صالح');
      return;
    }
    
    // Get location
    final position = await Geolocator.getCurrentPosition();
    
    // Scan QR Code
    final service = Provider.of<SchoolDeliveryService>(context, listen: false);
    final response = await service.scanQrCodeUnified(
      token: token,
      recipientName: 'محمد أحمد',
      latitude: position.latitude,
      longitude: position.longitude,
      notes: 'تم التسليم بحالة جيدة',
    );
    
    if (response.success) {
      _showSuccess('تم تأكيد التسليم بنجاح! ✅');
      Navigator.pop(context);
    } else {
      _showError(response.error ?? 'فشل في مسح الرمز');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('مسح QR Code')),
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              _handleQrCode(barcode.rawValue!);
              break;
            }
          }
        },
      ),
    );
  }
}
```

---

### مثال 2: المدرسة - عرض الشحنات الواردة

```dart
class SchoolDashboard extends StatefulWidget {
  @override
  _SchoolDashboardState createState() => _SchoolDashboardState();
}

class _SchoolDashboardState extends State<SchoolDashboard> {
  @override
  void initState() {
    super.initState();
    _loadShipments();
  }
  
  Future<void> _loadShipments() async {
    final service = Provider.of<SchoolDeliveryService>(context, listen: false);
    await service.fetchIncomingDeliveries();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<SchoolDeliveryService>(
      builder: (context, service, child) {
        if (service.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text('الشحنات الواردة'),
              bottom: TabBar(
                tabs: [
                  Tab(text: 'قادمة (${service.incomingDeliveries.length})'),
                  Tab(text: 'مستلمة (${service.receivedDeliveries.length})'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildShipmentList(service.incomingDeliveries),
                _buildShipmentList(service.receivedDeliveries),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildShipmentList(List<ApiShipment> shipments) {
    return ListView.builder(
      itemCount: shipments.length,
      itemBuilder: (context, index) {
        final shipment = shipments[index];
        return Card(
          child: ListTile(
            leading: Icon(Icons.local_shipping),
            title: Text(shipment.trackingCode),
            subtitle: Text(
              'المندوب: ${shipment.assignedCourierName ?? "غير محدد"}\n'
              'الحالة: ${shipment.statusDisplay ?? shipment.status}'
            ),
            trailing: _buildQrCode(shipment),
            onTap: () => _showShipmentDetails(shipment),
          ),
        );
      },
    );
  }
  
  Widget _buildQrCode(ApiShipment shipment) {
    if (shipment.qrCodeImage == null) return SizedBox();
    
    return Container(
      width: 80,
      height: 80,
      child: Image.memory(
        base64Decode(shipment.qrCodeImage!),
        fit: BoxFit.contain,
      ),
    );
  }
}
```

---

### مثال 3: الإشعارات

```dart
class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }
  
  Future<void> _loadNotifications() async {
    final service = Provider.of<NotificationService>(context, listen: false);
    await service.fetchNotifications();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationService>(
      builder: (context, service, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('الإشعارات (${service.unreadCount})'),
            actions: [
              IconButton(
                icon: Icon(Icons.done_all),
                onPressed: () => service.markAllAsRead(),
                tooltip: 'تعليم الكل كمقروء',
              ),
            ],
          ),
          body: service.isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: service.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = service.notifications[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: notification.read
                            ? Colors.grey
                            : Colors.blue,
                        child: Icon(
                          Icons.notifications,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        notification.message,
                        style: TextStyle(
                          fontWeight: notification.read
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        _formatDate(notification.createdAt),
                      ),
                      onTap: () {
                        if (!notification.read) {
                          service.markAsRead(notification.id);
                        }
                      },
                    );
                  },
                ),
        );
      },
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays > 0) {
      return 'منذ ${diff.inDays} يوم';
    } else if (diff.inHours > 0) {
      return 'منذ ${diff.inHours} ساعة';
    } else if (diff.inMinutes > 0) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}
```

---

## ✅ قائمة التحقق

### للمندوبين

- [x] ✅ جلب الشحنات النشطة
- [x] ✅ جلب سجل الشحنات
- [x] ✅ بدء التوصيل
- [x] ✅ تحديث الموقع
- [x] ✅ رفع صورة الإثبات
- [x] ✅ رفع التوقيع
- [x] ✅ مسح QR Code
- [x] ✅ إكمال التوصيل
- [x] ✅ إحصائيات الأداء

### للمدارس

- [x] ✅ جلب الشحنات الواردة
- [x] ✅ استلام الشحنة يدوياً
- [x] ✅ استلام الشحنة بمسح QR
- [x] ✅ عرض طلبات المدرسة

### للإشعارات

- [x] ✅ جلب الإشعارات
- [x] ✅ تسجيل Device Token
- [x] ✅ تعليم كمقروء

---

## 📱 الخدمات المحدثة

### ملفات تم تحديثها:

1. **`lib/services/shipment_service.dart`**
   - ✅ جميع الـ 9 APIs متوافقة مع التوثيق
   - ✅ معالجة صحيحة للأخطاء
   - ✅ Endpoints صحيحة

2. **`lib/services/school_delivery_service.dart`**
   - ✅ تحديث endpoint إلى `/school/shipments/incoming/`
   - ✅ دعم كامل لـ QR Code
   - ✅ معالجة response الجديد

3. **`lib/models/api_shipment_model.dart`**
   - ✅ إضافة حقول `qr_code` object
   - ✅ إضافة حقول `courier` object
   - ✅ إضافة حقول `delivery_info` object
   - ✅ إضافة `timestamps` object

4. **`lib/services/notification_service.dart`**
   - ✅ تحديث كامل للتوافق مع Backend
   - ✅ دعم Push Notifications
   - ✅ تسجيل Device Token

5. **`lib/models/notification_model.dart`**
   - ✅ نموذج `AppNotification` الجديد
   - ✅ نموذج `NotificationListResponse`

---

## 🔗 روابط مفيدة

- [QR_DELIVERY_SYSTEM_GUIDE.md](QR_DELIVERY_SYSTEM_GUIDE.md) - دليل نظام QR Code
- [API_REFERENCE.md](API_REFERENCE.md) - مرجع APIs الكامل
- [FLUTTER_RUN_GUIDE.md](FLUTTER_RUN_GUIDE.md) - دليل تشغيل التطبيق

---

## 📞 الدعم الفني

في حال وجود أي مشاكل:
1. تحقق من الاتصال بالإنترنت
2. تحقق من صلاحية Token
3. راجع logs في Debug Console
4. تحقق من Backend API status

---

**الحالة النهائية:** ✅ **جميع الخدمات متكاملة ومتوافقة 100% مع Backend APIs**

**التاريخ:** 24 ديسمبر 2025  
**المطور:** Flutter Development Team
