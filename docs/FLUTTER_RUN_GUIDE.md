# دليل تشغيل تطبيق Flutter وإنشاء طلب مدرسة

## الخطوة 1: تشغيل التطبيق

### على Windows (خارج WSL):

1. افتح Command Prompt أو PowerShell
2. انتقل لمجلد المشروع:
```bash
cd C:\Users\<your-username>\path\to\ketabi\mobile\book_distribution_system
```

3. تحقق من الأجهزة المتاحة:
```bash
flutter devices
```

4. إذا لم يكن لديك محاكي، شغّل Chrome:
```bash
flutter run -d chrome
```

5. أو شغّل على محاكي Android:
```bash
# أولاً شغّل المحاكي من Android Studio
# ثم:
flutter run -d emulator-5554
```

### ملاحظة مهمة: تعديل API URL

إذا كنت تشغّل على:
- **Chrome (Web)**: استخدم `http://localhost:8000`
- **Android Emulator**: استخدم `http://10.0.2.2:8000` (الإعداد الحالي)
- **جهاز حقيقي**: استخدم IP الكمبيوتر مثل `http://192.168.1.X:8000`

عدّل الملف: `lib/utils/constants.dart`

## الخطوة 2: تسجيل الدخول كمدرسة

### بيانات الدخول:
```
اسم المستخدم: school_test
كلمة المرور: school123
```

### خطوات تسجيل الدخول:
1. افتح التطبيق
2. أدخل اسم المستخدم: `school_test`
3. أدخل كلمة المرور: `school123`
4. اضغط "تسجيل الدخول"

## الخطوة 3: إنشاء طلب كتب

### الطريقة من الكود:

التطبيق يستخدم `OrderService` لإنشاء الطلبات. إليك مثال على كيفية إنشاء طلب:

```dart
import 'package:book_distribution_system/services/order_service.dart';
import 'package:book_distribution_system/models/school_request_model.dart';

// إنشاء طلب جديد
Future<void> createSchoolRequest() async {
  final orderService = OrderService();
  
  // بيانات الطلب
  final requestData = {
    'items': [
      {
        'book': 13, // معرف كتاب الرياضيات - السادس
        'quantity': 50,
      },
      {
        'book': 18, // معرف كتاب العلوم - الخامس
        'quantity': 30,
      }
    ],
    'notes': 'طلب كتب للفصل الدراسي الأول'
  };
  
  try {
    final response = await orderService.createSchoolRequest(requestData);
    print('تم إنشاء الطلب بنجاح: ${response['id']}');
  } catch (e) {
    print('خطأ في إنشاء الطلب: $e');
  }
}
```

### واجهة المستخدم المتوقعة:

يجب أن تحتوي الشاشة على:
1. **قائمة الكتب المتاحة** - يمكن للمدرسة اختيار الكتب
2. **حقول الكمية** - لكل كتاب
3. **حقل الملاحظات** (اختياري)
4. **زر "إرسال الطلب"**

## الخطوة 4: التحقق من الطلب

### في التطبيق:
- بعد إنشاء الطلب، يجب أن ترى رسالة نجاح
- يجب أن يظهر الطلب في قائمة الطلبات بحالة "قيد الانتظار"

### في Backend:
تحقق من قاعدة البيانات:

```bash
docker-compose exec db psql -U bookuser -d bookdb -c "SELECT id, status, created_at FROM school_requests_schoolrequest ORDER BY id DESC LIMIT 5;"
```

### في الويب:
1. افتح `http://localhost:3000`
2. سجل دخول كمسؤول محافظة
3. تحقق من الطلبات الواردة

## الخطوات التالية (E2E Workflow)

بعد إنشاء الطلب من التطبيق:

1. **المحافظة توافق على الطلب** (من الويب):
   - URL: `http://localhost:3000`
   - Login: `province_admin` / كلمة المرور
   - اذهب لصفحة طلبات المدارس
   - اضغط "موافقة" على الطلب

2. **المحافظة تنشئ طلب للوزارة** (تلقائي أو يدوي)

3. **الوزارة توافق** (من الويب)

4. **إنشاء شحنة للمحافظة** + تعيين مندوب

5. **المندوب يسلم للمحافظة**

6. **إنشاء شحنة للمدرسة** + تعيين مندوب

7. **المندوب يسلم للمدرسة**

8. **المدرسة تستقبل الشحنة** (من التطبيق)

## اختبار سريع بدون التطبيق

إذا كنت تريد اختبار فقط، يمكنك إنشاء الطلب عبر API مباشرة:

```bash
# تسجيل الدخول
TOKEN=$(curl -s -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"school_test","password":"school123"}' | jq -r '.access')

# إنشاء طلب
curl -X POST http://localhost:8000/api/school-requests/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "items": [
      {"book": 13, "quantity": 50},
      {"book": 18, "quantity": 30}
    ],
    "notes": "طلب من API"
  }'
```

## الكتب المتاحة للاختبار

معرفات الكتب في قاعدة البيانات:
- **ID: 13** - الرياضيات - الصف السادس - الفصل الأول
- **ID: 18** - العلوم - الصف الخامس - الفصل الأول

يمكنك التحقق من الكتب المتاحة:
```bash
curl http://localhost:8000/api/books/ | jq
```

## استكشاف الأخطاء

### مشكلة: التطبيق لا يتصل بـ Backend

**الحل:**
1. تأكد من أن Docker containers شغالة: `docker-compose ps`
2. تأكد من API URL صحيح في `constants.dart`
3. للويب استخدم `localhost:8000`
4. للمحاكي استخدم `10.0.2.2:8000`

### مشكلة: خطأ في تسجيل الدخول

**الحل:**
1. تأكد من المستخدم موجود في قاعدة البيانات
2. راجع كلمة المرور
3. تحقق من logs: `docker-compose logs backend`

### مشكلة: لا يمكن إنشاء الطلب

**الحل:**
1. تأكد من token صالح
2. تأكد من بيانات الطلب صحيحة
3. تحقق من أن الكتب موجودة في قاعدة البيانات

## الملفات المهمة في التطبيق

- `lib/services/api_client.dart` - عميل API مع JWT
- `lib/services/auth_service.dart` - خدمة المصادقة
- `lib/services/order_service.dart` - خدمة الطلبات
- `lib/models/school_request_model.dart` - نموذج طلب المدرسة
- `lib/utils/constants.dart` - الإعدادات (API URL)

## دعم

إذا واجهت أي مشاكل:
1. راجع الـ logs في Backend
2. استخدم Developer Tools في المتصفح
3. تحقق من network requests
4. راجع ملف `INTEGRATION_GUIDE.md` للتفاصيل الكاملة
