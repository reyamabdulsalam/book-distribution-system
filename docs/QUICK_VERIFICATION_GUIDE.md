# 🔍 دليل التحقق السريع من التكامل
## Quick Integration Verification Guide

---

## ✅ خطوات التحقق السريعة

### 1. التحقق من عدم وجود أخطاء
```bash
flutter analyze
```
**المتوقع:** `No issues found!`

### 2. التحقق من Dependencies
```bash
flutter pub get
```
**المتوقع:** `Got dependencies!`

### 3. التحقق من التشغيل
```bash
flutter run
```
**المتوقع:** التطبيق يعمل بدون أخطاء

---

## 🧪 اختبار APIs

### اختبار 1: المندوب - الشحنات النشطة

```dart
// في DriverDashboard
final shipmentService = Provider.of<ShipmentService>(context);
await shipmentService.fetchActiveShipments();

// التحقق
if (shipmentService.activeShipments.isNotEmpty) {
  print('✅ تم جلب ${shipmentService.activeShipments.length} شحنة نشطة');
} else {
  print('⚠️ لا توجد شحنات نشطة');
}
```

**Endpoint:** `GET /api/warehouses/mobile/driver/shipments/active/`

---

### اختبار 2: المدرسة - الشحنات الواردة

```dart
// في SchoolDashboard
final schoolService = Provider.of<SchoolDeliveryService>(context);
await schoolService.fetchIncomingDeliveries();

// التحقق
print('✅ شحنات قادمة: ${schoolService.incomingDeliveries.length}');
print('✅ شحنات مستلمة: ${schoolService.receivedDeliveries.length}');
```

**Endpoint:** `GET /api/warehouses/school/shipments/incoming/`

---

### اختبار 3: مسح QR Code

```dart
// في QR Scanner
final token = 'extracted_token_from_qr';
final response = await schoolService.scanQrCodeUnified(
  token: token,
  recipientName: 'Test User',
  latitude: 30.0444,
  longitude: 31.2357,
);

// التحقق
if (response.success) {
  print('✅ QR Code صالح - تم التسليم');
} else {
  print('❌ خطأ: ${response.error}');
  print('السبب: ${response.reason}');
}
```

**Endpoint:** `POST /api/warehouses/mobile/unified-scan/`

---

### اختبار 4: الإشعارات

```dart
// في NotificationsScreen
final notificationService = Provider.of<NotificationService>(context);
await notificationService.fetchNotifications();

// التحقق
print('✅ إجمالي الإشعارات: ${notificationService.notifications.length}');
print('✅ غير المقروءة: ${notificationService.unreadCount}');
```

**Endpoint:** `GET /api/notifications/`

---

## 🔍 التحقق من Models

### ApiShipment
```dart
final shipment = ApiShipment.fromJson(response);

// التحقق من الحقول الجديدة
assert(shipment.qrToken != null, 'QR Token موجود');
assert(shipment.qrStatus != null, 'QR Status موجود');
assert(shipment.statusDisplay != null, 'Status Display موجود');
assert(shipment.assignedCourierId != null, 'Courier ID موجود');

print('✅ جميع حقول ApiShipment صحيحة');
```

### AppNotification
```dart
final notification = AppNotification.fromJson(response);

// التحقق
assert(notification.id > 0, 'ID صحيح');
assert(notification.message.isNotEmpty, 'Message موجود');
assert(notification.createdAt != null, 'Created At موجود');

print('✅ نموذج AppNotification صحيح');
```

---

## 🌐 التحقق من Endpoints

### قائمة جميع الـ Endpoints:

#### المندوبين (9):
- [ ] `GET /api/warehouses/mobile/driver/shipments/active/`
- [ ] `GET /api/warehouses/mobile/driver/shipments/history/`
- [ ] `POST /api/warehouses/mobile/driver/shipments/{id}/start/`
- [ ] `POST /api/warehouses/mobile/driver/shipments/{id}/location/`
- [ ] `POST /api/warehouses/mobile/driver/shipments/{id}/upload-photo/`
- [ ] `POST /api/warehouses/mobile/driver/shipments/{id}/upload-signature/`
- [ ] `POST /api/warehouses/mobile/unified-scan/`
- [ ] `POST /api/warehouses/mobile/driver/shipments/{id}/complete/`
- [ ] `GET /api/warehouses/mobile/driver/performance/`

#### المدارس (4):
- [ ] `GET /api/warehouses/school/shipments/incoming/`
- [ ] `POST /api/warehouses/mobile/school/deliveries/{id}/receive/`
- [ ] `POST /api/warehouses/mobile/school/deliveries/{id}/scan-qr/`
- [ ] `GET /api/school-requests/`

#### الإشعارات (3):
- [ ] `GET /api/notifications/`
- [ ] `POST /api/notifications/register-device/`
- [ ] `POST /api/notifications/{id}/mark-read/`

---

## 🐛 معالجة الأخطاء الشائعة

### خطأ 401 - Unauthorized
```dart
if (response.statusCode == 401) {
  // إعادة تسجيل الدخول
  Navigator.pushReplacementNamed(context, '/login');
}
```

### خطأ الاتصال
```dart
try {
  await service.fetchData();
} on SocketException {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('خطأ في الاتصال'),
      content: Text('تحقق من اتصال الإنترنت'),
    ),
  );
}
```

### خطأ QR Code منتهي
```dart
if (response.reason == 'qr_expired') {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('رمز QR منتهي'),
      content: Text('صلاحية رمز QR انتهت (72 ساعة)'),
    ),
  );
}
```

---

## 📊 معايير النجاح

### ✅ التطبيق يعمل بشكل صحيح إذا:

1. **لا توجد أخطاء compile** ✅
2. **يمكن تسجيل الدخول** ✅
3. **المندوب يرى الشحنات النشطة** ✅
4. **المدرسة ترى الشحنات الواردة** ✅
5. **QR Scanner يعمل** ✅
6. **الإشعارات تظهر** ✅
7. **التنقل بين الشاشات يعمل** ✅

---

## 🚀 الخطوات التالية

### بعد التحقق من التكامل:

1. **اختبار End-to-End:**
   - تسجيل دخول المندوب
   - جلب الشحنات
   - مسح QR Code
   - تأكيد التسليم

2. **اختبار المدرسة:**
   - تسجيل الدخول
   - عرض الشحنات الواردة
   - عرض QR Codes
   - عرض الإشعارات

3. **اختبار الأخطاء:**
   - محاولة مسح QR منتهي
   - محاولة مسح QR مستخدم
   - محاولة الوصول بدون صلاحيات

---

## 📞 في حال وجود مشاكل

### مشكلة: لا يتم جلب البيانات
```dart
// تحقق من:
1. Base URL صحيح: http://45.77.65.134/api
2. Token موجود وصالح
3. الصلاحيات صحيحة (role)
4. Backend Server يعمل
```

### مشكلة: أخطاء في Models
```dart
// تحقق من:
1. Response من Backend يطابق Model
2. جميع الحقول المطلوبة موجودة
3. الأنواع (types) صحيحة
```

### مشكلة: QR Code لا يعمل
```dart
// تحقق من:
1. صيغة QR: SHIPMENT:<token>:<id>
2. Token extraction يعمل
3. صلاحية QR لم تنته (72 ساعة)
4. QR لم يُستخدم مسبقاً
```

---

## ✅ قائمة التحقق النهائية

- [ ] ✅ `flutter analyze` بدون أخطاء
- [ ] ✅ `flutter pub get` يعمل
- [ ] ✅ `flutter run` يعمل
- [ ] ✅ تسجيل الدخول يعمل
- [ ] ✅ جلب الشحنات يعمل
- [ ] ✅ QR Scanner يعمل
- [ ] ✅ الإشعارات تظهر
- [ ] ✅ التنقل بين الشاشات يعمل
- [ ] ✅ معالجة الأخطاء تعمل

---

## 🎉 نجاح التكامل

إذا أكملت جميع الخطوات أعلاه بنجاح:

**🎊 مبروك! التطبيق متكامل بالكامل مع Backend APIs**

---

**التاريخ:** 24 ديسمبر 2025  
**الإصدار:** 2.0.0  
**الحالة:** ✅ جاهز للاستخدام
