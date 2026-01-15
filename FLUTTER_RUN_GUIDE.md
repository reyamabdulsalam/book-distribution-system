# 📱 تشغيل تطبيق Flutter - دليل كامل

## 🎯 المتطلبات

### ✅ قبل البدء

1. **Flutter SDK** مثبت (v3.0+)
2. **Dart SDK** (يأتي مع Flutter)
3. **Android Studio** أو **Xcode** (حسب نوع الجهاز)
4. **Backend Server** يعمل على `http://0.0.0.0:8000`

---

## 🔧 إعداد البيئة

### تحقق من تثبيت Flutter

```bash
flutter --version
dart --version
flutter doctor
```

### تثبيت المكتبات

```bash
cd book_distribution_system
flutter pub get
```

---

## 🎨 تكوين الاتصال بالـ Backend

### 1. تحديث عنوان الـ Backend

في ملف `lib/utils/constants.dart`:

```dart
class AppConfig {
  // للتطوير المحلي على نفس الجهاز:
  static const String ipAddress = 'http://10.0.2.2:8000';
  
  // للتطوير على جهاز فعلي:
  // static const String ipAddress = 'http://192.168.1.100:8000';
  
  // للإنتاج:
  // static const String ipAddress = 'https://yourdomain.com';
}
```

### 2. شرح العناوين

| البيئة | العنوان | الملاحظات |
|--------|--------|---------|
| **محاكي Android** | `http://10.0.2.2:8000` | IP خاص بالمحاكي |
| **جهاز حقيقي Android** | `http://192.168.1.X:8000` | استخدم IP شبكتك |
| **محاكي iOS** | `http://localhost:8000` | يعمل مباشرة |
| **جهاز حقيقي iOS** | `http://192.168.1.X:8000` | استخدم IP شبكتك |
| **الإنتاج** | `https://yourdomain.com` | مع HTTPS |

---

## 🚀 تشغيل التطبيق

### على محاكي Android

```bash
flutter emulator --launch Pixel_4_API_31
flutter run -d emulator-5554
```

### على جهاز Android حقيقي

```bash
# تفعيل USB Debugging على الجهاز
flutter run
```

### على محاكي iOS

```bash
open -a Simulator
flutter run -d iOS
```

### على جهاز iOS حقيقي

```bash
# قم بتوقيع التطبيق أولاً (يتطلب Apple Developer Account)
flutter run -d <device-id>
```

### بدون تحديد الجهاز (يختار تلقائياً)

```bash
flutter run
```

---

## 🧪 اختبار تسجيل الدخول

### حسابات الاختبار

```
مندوب:
  Username: driver1
  Password: driver123

موظف مدرسة:
  Username: sf1
  Password: sf1password
```

### خطوات الاختبار

1. **شغّل التطبيق**
2. **أدخل بيانات دخول صحيحة**
3. **اضغط "تسجيل الدخول"**
4. **تحقق من ظهور الشاشة الرئيسية**

### في حالة الخطأ

- تحقق من سجل كونسول: `flutter logs`
- تحقق من أن Backend يعمل: `curl http://localhost:8000/`
- تحقق من عنوان IP الصحيح في `constants.dart`

---

## 🐛 استكشاف الأخطاء

### ❌ خطأ: "Connection refused"

**السبب**: Backend لا يعمل  
**الحل**:
```bash
# في نافذة منفصلة
cd book_distribution_system
python manage.py runserver 0.0.0.0:8000
```

### ❌ خطأ: "Invalid URL"

**السبب**: عنوان IP خاطئ  
**الحل**:
```bash
# اكتشف IP الخادم
ipconfig  # على Windows
ifconfig  # على Mac/Linux

# حدّث الثابت في constants.dart
static const String ipAddress = 'http://YOUR_IP:8000';
```

### ❌ خطأ: "Socket exception"

**السبب**: المحاكي لا يستطيع الوصول للخادم  
**الحل**:
- استخدم `10.0.2.2` بدل `localhost` في محاكي Android
- استخدم `localhost` مباشرة في محاكي iOS

### ❌ خطأ: "Invalid credentials"

**السبب**: بيانات الدخول خاطئة أو المستخدم لم ينشأ  
**الحل**:
```bash
# تأكد من إنشاء المستخدمين
python manage.py create_test_users

# تحقق من المستخدمين
python manage.py shell
>>> from django.contrib.auth.models import User
>>> User.objects.all().values('username', 'is_active')
```

---

## 📊 نسخ Logs للتشخيص

```bash
# حفظ السجلات في ملف
flutter logs > flutter_logs.txt

# عرض سجلات محددة
flutter logs -d emulator-5554

# سجلات مفصلة
flutter run -v > verbose_logs.txt 2>&1
```

---

## ⚙️ البناء والنشر

### بناء APK (Android)

```bash
flutter build apk --release
# النتيجة: build/app/outputs/flutter-app.apk
```

### بناء AAB (Android)

```bash
flutter build appbundle --release
# للنشر على Google Play
```

### بناء IPA (iOS)

```bash
flutter build ios --release
# تثبيت على جهاز حقيقي عبر Xcode
```

---

## 🔒 تكوين الأمان

### في التطوير

```dart
// SSL/TLS disable للاختبار المحلي
import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

// في main.dart
void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}
```

### قبل الإنتاج

```dart
// أزل SSL override
// HttpOverrides.global = MyHttpOverrides();

// استخدم HTTPS فقط
static const String apiBaseUrl = 'https://yourdomain.com';
```

---

## 📱 الاختبار على أجهزة متعددة

### Android

```bash
# قائمة الأجهزة المتصلة
flutter devices

# تشغيل على جهاز محدد
flutter run -d <device-id>
```

### iOS

```bash
# قائمة الأجهزة المتاحة
flutter devices

# تشغيل على جهاز محدد
flutter run -d <device-id>
```

---

## 🔄 التطوير والاختبار السريع

### Hot Reload

```bash
# أثناء تشغيل flutter run
# اضغط R (في الكونسول)
# أو الأمر:
flutter hot reload

# Restart شامل
flutter restart
```

### تفعيل Debug Mode

```bash
flutter run --debug
flutter run --profile  # أسرع من debug
flutter run --release # الأسرع (النسخة النهائية)
```

---

## 📦 إدارة المكتبات

### تحديث المكتبات

```bash
flutter pub upgrade
```

### إضافة مكتبة جديدة

```bash
flutter pub add package_name
```

### حذف مكتبة

```bash
flutter pub remove package_name
```

---

## 🎯 نصائح مفيدة

### 1. استخدام الاختصارات

```bash
# اختصار للبناء والتشغيل
flutter run --debug

# اختصار لتشغيل بسيط
flutter run

# اختصار مع cleaning
flutter clean && flutter run
```

### 2. مسح الـ Cache

```bash
# في حالة المشاكل الغريبة
flutter clean
flutter pub get
flutter run
```

### 3. التحقق من الصحة

```bash
flutter doctor -v
```

### 4. تشغيل الاختبارات

```bash
flutter test
flutter test test/widget_test.dart
```

---

## 📊 قوائمة التحقق قبل الإطلاق

- [ ] Backend يعمل على `http://0.0.0.0:8000`
- [ ] عنوان IP صحيح في `constants.dart`
- [ ] محاكي/جهاز متصل
- [ ] حسابات اختبارية موجودة في قاعدة البيانات
- [ ] لا توجد أخطاء في `flutter analyze`
- [ ] `flutter doctor` بدون أخطاء حرجة
- [ ] اختبار تسجيل الدخول ناجح
- [ ] لا توجد رسائل الأمان الحساسة في logs

---

## 🚨 أوقات الاختبار

| المكان | الوقت المتوقع |
|--------|--------------|
| بناء APK | 2-5 دقائق |
| بناء AAB | 2-5 دقائق |
| بناء IPA | 5-10 دقائق |
| تشغيل Debug | 1-2 دقيقة |
| Hot Reload | < 1 ثانية |

---

## 📞 للمساعدة

اقرأ التوثيق الكاملة في:
- `DATABASE_LOGIN_IMPLEMENTATION.md`
- `FINAL_SETUP_GUIDE.md`
- `docs/` المجلد

---

**آخر تحديث**: 2025  
**الإصدار**: 1.0  

🎉 استمتع بالتطوير!

