# دليل تكامل تطبيق Flutter مع Backend

## ✅ التعديلات المنفذة

### 1. تحديث API Client
- ✅ إضافة دعم `access` و `refresh` tokens
- ✅ إضافة وظيفة تحديث التوكن تلقائياً عند انتهاء الصلاحية
- ✅ إضافة دوال مساعدة: `get`, `post`, `put`, `patch`, `delete`
- ✅ معالجة أخطاء 401 تلقائياً

### 2. تحديث Auth Service
- ✅ التكامل مع `/api/auth/login/` و `/api/auth/refresh/`
- ✅ حفظ التوكنات في الذاكرة
- ✅ إضافة وظيفة `checkSession()` للتحقق من الجلسة
- ✅ دعم Fallback محلي للاختبار

### 3. إنشاء نماذج بيانات جديدة
- ✅ `SchoolRequest` و `SchoolRequestItem` - متوافق مع `/api/school-requests/`
- ✅ `Shipment` و `ShipmentBook` - متوافق مع `/api/warehouses/shipments/`

### 4. تحديث Order Service
- ✅ دعم `/api/school-requests/` بدلاً من `/api/orders/`
- ✅ دوال `fetchSchoolRequests()`, `createSchoolRequest()`, `updateRequestStatus()`
- ✅ الحفاظ على التوافقية مع الكود القديم

### 5. إصلاح URL
- ✅ تغيير من `localhost` إلى `10.0.2.2` للـ Android Emulator
- ✅ إضافة تعليقات لاستخدام IP حقيقي على الأجهزة

---

## 🔧 خطوات الإعداد

### 1. تشغيل Backend
```bash
cd /home/reyam/ketabi
docker-compose up -d
```

### 2. التحقق من Backend
```bash
curl http://localhost:8000/api/auth/login/ \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"username":"ministry_admin","password":"ministrypass"}'
```

### 3. تشغيل Flutter App

#### على Android Emulator:
```bash
cd /home/reyam/ketabi/mobile/book_distribution_system
flutter run
```

#### على جهاز حقيقي:
1. اعرف IP جهازك:
```bash
hostname -I | awk '{print $1}'
```

2. عدّل `lib/utils/constants.dart`:
```dart
static const String apiBaseUrl = 'http://192.168.1.X:8000'; // استخدم IP جهازك
```

3. شغّل التطبيق:
```bash
flutter run
```

---

## 📱 اختبار التكامل

### 1. تسجيل الدخول

**للمدارس:**
- Username: (سيتم إنشاؤه من Backend)
- Password: (حسب ما تم إنشاؤه)

**للمندوبين:**
- Username: (سيتم إنشاؤه من Backend - دور `ministry_courier`)
- Password: (حسب ما تم إنشاؤه)

**للاختبار المحلي (بدون Backend):**
- School: `school` / `school123`
- Courier: `courier` / `courier123`

### 2. إنشاء طلب كتب (من المدرسة)

```dart
// مثال على الاستخدام في الكود
final request = SchoolRequest(
  schoolId: 1, // ID المدرسة
  items: [
    SchoolRequestItem(
      bookId: 13, // ID الكتاب
      quantity: 50,
      term: 'first',
    ),
  ],
  requestDate: DateTime.now(),
  notes: 'طلب كتب للفصل الأول',
);

final orderService = Provider.of<OrderService>(context, listen: false);
final result = await orderService.createSchoolRequest(request);
```

### 3. عرض الطلبات

```dart
// جلب طلبات المدرسة
await orderService.fetchSchoolRequests(schoolId);

// عرض الطلبات
final requests = orderService.requests;
```

---

## 🔗 Backend Endpoints المستخدمة

### Auth
- `POST /api/auth/login/` - تسجيل دخول
- `POST /api/auth/refresh/` - تحديث التوكن

### School Requests
- `GET /api/school-requests/?school={id}` - جلب طلبات مدرسة
- `POST /api/school-requests/` - إنشاء طلب جديد
- `PATCH /api/school-requests/{id}/` - تحديث حالة الطلب

### Books
- `GET /api/books/` - قائمة الكتب

### Shipments (للمندوبين)
- `GET /api/warehouses/shipments/` - قائمة الشحنات
- `PATCH /api/warehouses/shipments/{id}/` - تحديث حالة الشحنة

### Notifications
- `GET /api/notifications/` - قائمة الإشعارات
- `PATCH /api/notifications/{id}/` - تحديث حالة الإشعار

---

## 🚀 الخطوات القادمة

### 1. إنشاء مستخدمين للاختبار

```bash
# دخول إلى Django shell
docker-compose exec backend python manage.py shell

# إنشاء مدرسة
from schools.models import School
from users.models import User

school = School.objects.create(
    name="مدرسة الاختبار",
    province_id=1,  # تأكد من وجود المحافظة
    address="عنوان المدرسة"
)

user = User.objects.create_user(
    username="school_test",
    password="test123",
    role="school_admin",
    full_name="مدير مدرسة الاختبار",
    school=school
)

# إنشاء مندوب
courier = User.objects.create_user(
    username="courier_test",
    password="test123",
    role="ministry_courier",
    full_name="مندوب الاختبار",
    phone="+967712345678"
)
```

### 2. إضافة ميزات إضافية

#### أ. خدمة الشحنات للمندوبين

إنشاء ملف: `lib/services/shipment_service.dart`

```dart
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/shipment_model.dart';
import 'api_client.dart';

class ShipmentService with ChangeNotifier {
  List<Shipment> _shipments = [];

  List<Shipment> get shipments => _shipments;

  Future<void> fetchCourierShipments() async {
    try {
      final response = await ApiClient.get('/api/warehouses/shipments/');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final resultsList = data is List ? data : (data['results'] ?? []);
        
        _shipments = resultsList.map<Shipment>((item) {
          return Shipment.fromJson(item);
        }).toList();
        
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('ShipmentService.fetchCourierShipments error: $e');
    }
  }

  Future<bool> updateShipmentStatus(int shipmentId, String status) async {
    try {
      final response = await ApiClient.patch(
        '/api/warehouses/shipments/$shipmentId/',
        {'status': status},
      );
      
      if (response.statusCode == 200) {
        await fetchCourierShipments();
        return true;
      }
    } catch (e) {
      if (kDebugMode) print('ShipmentService.updateShipmentStatus error: $e');
    }
    return false;
  }
}
```

#### ب. خدمة الإشعارات

تحديث `lib/services/notification_service.dart`:

```dart
Future<void> fetchNotifications() async {
  try {
    final response = await ApiClient.get('/api/notifications/');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final resultsList = data is List ? data : (data['results'] ?? []);
      
      _notifications = resultsList.map<Notification>((item) {
        return Notification.fromJson(item);
      }).toList();
      
      notifyListeners();
    }
  } catch (e) {
    if (kDebugMode) print('NotificationService.fetchNotifications error: $e');
  }
}
```

### 3. تحديث واجهات المدرسة

تحديث `lib/screens/school_dashboard.dart` لاستخدام API الحقيقي:

```dart
@override
void initState() {
  super.initState();
  final authService = Provider.of<AuthService>(context, listen: false);
  final orderService = Provider.of<OrderService>(context, listen: false);
  
  // جلب طلبات المدرسة
  if (authService.currentUser?.schoolId != null) {
    final schoolId = int.tryParse(authService.currentUser!.schoolId!);
    if (schoolId != null) {
      orderService.fetchSchoolRequests(schoolId);
    }
  }
}
```

---

## ⚠️ ملاحظات مهمة

### 1. الأمان
- ❌ لا تحفظ التوكنات في الكود المصدري
- ✅ استخدم `flutter_secure_storage` لحفظ التوكنات بشكل آمن
- ✅ استخدم HTTPS في الإنتاج

### 2. معالجة الأخطاء
- ✅ جميع الدوال تعالج الأخطاء وتعيد `null` أو `false` في حالة الفشل
- ✅ يمكن إضافة رسائل خطأ للمستخدم باستخدام `SnackBar`

### 3. التوافقية
- ✅ تم الحفاظ على `Order` model للتوافقية مع الكود القديم
- ✅ يمكن الانتقال تدريجياً إلى `SchoolRequest`

### 4. الأداء
- ✅ استخدم `pagination` عند جلب قوائم كبيرة
- ✅ أضف `pull-to-refresh` في الواجهات
- ✅ استخدم `cached_network_image` للصور

---

## 🐛 استكشاف الأخطاء

### 1. خطأ في الاتصال
```
SocketException: Failed to connect
```
**الحل:**
- تأكد من تشغيل Backend: `docker-compose ps`
- تأكد من IP صحيح في `constants.dart`
- للـ emulator استخدم `10.0.2.2`
- للجهاز الحقيقي استخدم IP الكمبيوتر

### 2. خطأ 401 Unauthorized
```
Status code: 401
```
**الحل:**
- تحقق من صحة Username/Password
- تحقق من انتهاء صلاحية التوكن (يجب أن يتم التحديث تلقائياً)
- سجل دخول من جديد

### 3. خطأ 404 Not Found
```
Status code: 404
```
**الحل:**
- تحقق من صحة الـ endpoint في الطلب
- تحقق من صحة الـ URL الأساسي في `constants.dart`

### 4. بيانات فارغة
**الحل:**
- تحقق من وجود بيانات في Backend
- تحقق من صحة الـ filtering (مثلاً `?school=1`)
- راجع logs الـ Backend: `docker-compose logs backend`

---

## 📞 الدعم الفني

إذا واجهت مشاكل:
1. راجع logs Flutter: `flutter logs`
2. راجع logs Backend: `docker-compose logs -f backend`
3. استخدم debug mode: `flutter run --debug`

---

## ✨ تم بنجاح!

التطبيق الآن جاهز للتكامل مع Backend. جرب تسجيل الدخول وإنشاء طلب كتب!
