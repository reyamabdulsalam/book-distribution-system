# 📱 نظام توزيع الكتب - دليل تسجيل الدخول من قاعدة البيانات

> **تم تحديثه بنجاح**: الآن يمكن تسجيل الدخول باستخدام بيانات المستخدمين من قاعدة البيانات! 🎉

---

## 🎯 ملخص الإنجاز

تم بنجاح تفعيل تسجيل الدخول من قاعدة البيانات للنظام:

✅ **تطبيق Flutter** يدعم عدة نقاط اتصال للمصادقة  
✅ **خادم Django** مع JWT authentication  
✅ **قاعدة بيانات MySQL** لتخزين بيانات المستخدمين  
✅ **حسابات اختبارية** جاهزة للاستخدام الفوري  
✅ **توثيق شامل** مع أمثلة عملية  

---

## 🚀 البدء السريع (3 خطوات فقط)

### 1️⃣ تثبيت المتطلبات
```bash
cd book_distribution_system
pip install -r requirements.txt
```

### 2️⃣ إعداد قاعدة البيانات
```bash
python manage.py migrate
python manage.py create_test_users
```

### 3️⃣ تشغيل الخادم
```bash
python manage.py runserver 0.0.0.0:8000
```

**تم! الآن يمكنك تسجيل الدخول** ✨

---

## 🧪 اختبار التسجيل

### طريقة 1: اختبار سريع بـ Python
```bash
python test_database_login.py
```

### طريقة 2: اختبار بـ curl
```bash
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username": "sf1", "password": "sf1password"}'
```

### طريقة 3: اختبار التطبيق المحمول
شغّل تطبيق Flutter وحاول تسجيل الدخول بأي من البيانات التالية

---

## 👥 حسابات الاختبار الجاهزة

### 🚗 مندوبو التوزيع (Drivers)

| المستخدم | كلمة المرور | الموقع |
|----------|-----------|--------|
| `driver1` | `driver123` | الرياض |
| `driver2` | `driver456` | جدة |

### 🏫 موظفو المدارس (School Staff)

| المستخدم | كلمة المرور | المدرسة |
|----------|-----------|--------|
| `sf1` | `sf1password` | مدرسة النهضة |
| `sf2` | `sf2password` | مدرسة التوحيد |

---

## 🏗️ البنية التقنية

### 🔄 تدفق تسجيل الدخول

```
المستخدم (Flutter App)
    ↓
    صيغة JSON: {"username": "sf1", "password": "sf1password"}
    ↓
    خادم Django: POST /api/auth/login/
    ↓
    التحقق من قاعدة البيانات
    ↓
    إنشاء JWT Token
    ↓
    إرجاع Access Token + بيانات المستخدم
    ↓
    تطبيق Flutter يحفظ التوكن
    ↓
    طلبات لاحقة تستخدم التوكن في الـ Header
```

### 🔐 نقاط الاتصال (API Endpoints)

| الطريقة | المسار | الوصف |
|--------|--------|-------|
| `POST` | `/api/auth/login/` | تسجيل دخول |
| `POST` | `/api/users/login/` | تسجيل دخول بديل |
| `POST` | `/api/auth/token/` | الحصول على توكن |
| `POST` | `/api/auth/refresh/` | تجديد التوكن |
| `GET` | `/api/users/me/` | بيانات المستخدم الحالي |

---

## 📊 استجابة API الناجحة

```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "username": "sf1",
    "name": "موظف المدرسة 1",
    "role": "school",
    "school_id": 1,
    "school_name": "مدرسة النهضة"
  }
}
```

---

## 📁 الملفات المهمة

### ⚙️ الإعدادات
- **`book_system/settings.py`** - إعدادات Django
- **`book_system/urls.py`** - مسارات الـ URL الرئيسية
- **`requirements.txt`** - المكتبات المطلوبة

### 🔐 المصادقة
- **`distribution/urls.py`** - مسارات API
- **`distribution/views.py`** - دوال تسجيل الدخول
- **`distribution/serializers.py`** - تنسيق البيانات

### 💾 قاعدة البيانات
- **`distribution/models.py`** - نماذج البيانات
- **`distribution/migrations/`** - تحديثات قاعدة البيانات
- **`distribution/management/commands/create_test_users.py`** - إنشاء بيانات الاختبار

### 📱 التطبيق المحمول
- **`lib/services/auth_service.dart`** - خدمة المصادقة
- **`lib/models/user_model.dart`** - نموذج المستخدم
- **`lib/screens/login_screen.dart`** - شاشة تسجيل الدخول

---

## 🛠️ استكشاف الأخطاء الشائعة

### ❌ خطأ: "No module named 'mysqlclient'"
```bash
pip install mysqlclient
# أو في Windows
pip install --no-binary :all: mysqlclient
```

### ❌ خطأ: "Connection refused"
```bash
# تأكد من تشغيل MySQL:
# Windows: ابحث عن MySQL في الخدمات وشغّله
# Linux: sudo service mysql start
# Mac: brew services start mysql-server
```

### ❌ خطأ: "Table doesn't exist"
```bash
python manage.py migrate
```

### ❌ خطأ: "Invalid credentials"
```bash
python manage.py create_test_users
```

### ❌ خطأ: "Cannot connect to Backend from Flutter"
```
تأكد من:
1. عنوان IP الخادم صحيح في lib/services/auth_service.dart
2. خادم Django يعمل على المنفذ 8000
3. الجدار الناري لا يحجب الوصول
```

---

## 📊 نتائج الفحص

استخدم الأمر التالي للتحقق من جاهزية النظام:

```bash
python check_system.py
```

هذا الأمر يتحقق من:
- ✅ إصدار Python
- ✅ المكتبات المثبتة
- ✅ الملفات الأساسية
- ✅ إعدادات قاعدة البيانات
- ✅ نقاط الاتصال API
- ✅ حالة الهجرات

---

## 🔒 الأمان والممارسات الأفضل

### في التطوير (Development)
- استخدم كلمات مرور بسيطة للاختبار
- فعّل `DEBUG = True` لرؤية الأخطاء التفصيلية
- لا تقلق بشأن HTTPS

### قبل الإنتاج (Production)
```python
# في settings.py
DEBUG = False
ALLOWED_HOSTS = ['yourdomain.com', '1.2.3.4']
SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SECRET_KEY = 'your-new-very-secret-key'  # غيّر هذا!
```

---

## 📚 المستندات الإضافية

- [**FINAL_SETUP_GUIDE.md**](docs/FINAL_SETUP_GUIDE.md) - دليل الإعداد الكامل
- [**DATABASE_LOGIN_GUIDE.md**](docs/DATABASE_LOGIN_GUIDE.md) - دليل تفصيلي للمصادقة
- [**QUICK_START_AR.md**](QUICK_START_AR.md) - دليل سريع بالعربية
- [**API_REFERENCE.md**](docs/API_REFERENCE.md) - مرجع API الكامل

---

## 🎓 مثال عملي كامل

### 1. تسجيل الدخول

```bash
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username": "sf1", "password": "sf1password"}'

# الاستجابة:
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "user": {
    "id": 1,
    "username": "sf1",
    "name": "موظف المدرسة 1",
    "role": "school",
    "school_id": 1,
    "school_name": "مدرسة النهضة"
  }
}
```

### 2. الحصول على البيانات الشخصية

```bash
curl http://localhost:8000/api/users/me/ \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc..."

# الاستجابة:
{
  "id": 1,
  "username": "sf1",
  "email": "sf1@school.edu",
  "first_name": "موظف",
  "last_name": "المدرسة 1"
}
```

### 3. تجديد التوكن

```bash
curl -X POST http://localhost:8000/api/auth/refresh/ \
  -H "Content-Type: application/json" \
  -d '{"refresh": "eyJ0eXAiOiJKV1QiLCJhbGc..."}'

# الاستجابة:
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

---

## 🤝 دعم تقني

### في حالة المشاكل:

1. **الخطأ في المحطة الطرفية؟**
   - اقرأ الرسالة بعناية
   - ابحث عن الخطأ في `output.txt`

2. **خطأ في الاتصال بقاعدة البيانات؟**
   - تحقق من `DATABASES` في `settings.py`
   - جرّب `python manage.py dbshell`

3. **خطأ في الاتصال من التطبيق؟**
   - تحقق من `ipAddress` في `auth_service.dart`
   - استخدم `check_system.py` للتحقق من الخادم

4. **لا تزال هناك مشاكل؟**
   - اقرأ `check_system.py` output
   - جرّب `python test_database_login.py`
   - تحقق من `docs/` للتوثيق الكامل

---

## 📈 خطوات لاحقة

### المرحلة 1: الاختبار ✅ (الحالية)
- ✅ إعداد قاعدة البيانات
- ✅ إنشاء حسابات اختبارية
- ⏳ اختبار API
- ⏳ اختبار التطبيق

### المرحلة 2: التحسينات
- [ ] إضافة المزيد من الحسابات الحقيقية
- [ ] تخصيص رسائل الأخطاء
- [ ] إضافة تسجيل العمليات (logging)
- [ ] إنشاء لوحة تحكم للإدارة

### المرحلة 3: النشر (Production)
- [ ] شهادة SSL
- [ ] نسخ احتياطية يومية
- [ ] مراقبة الأداء
- [ ] تحديثات الأمان

---

## ✨ الميزات المتقدمة

### تغيير كلمة المرور
```python
# في Django shell
from django.contrib.auth.models import User
user = User.objects.get(username='sf1')
user.set_password('new_password123')
user.save()
```

### إنشاء مستخدم جديد برمجياً
```python
from django.contrib.auth.models import User
from distribution.models import SchoolUser, School

user = User.objects.create_user(
    username='new_user',
    password='password123',
    email='user@school.edu',
    first_name='محمد',
    last_name='الأحمد'
)

school = School.objects.get(name='مدرسة النهضة')
SchoolUser.objects.create(
    user=user,
    school=school,
    position='معلم'
)
```

### تعطيل حساب
```python
user = User.objects.get(username='sf1')
user.is_active = False
user.save()
```

---

## 📞 معلومات المتصل

- **البريد الإلكتروني**: support@example.com
- **الدعم الفني**: 24/7 متاح
- **التوثيق**: راجع مجلد `docs/`

---

## 📝 الترخيص

هذا المشروع مرخص تحت المتطلبات المدرسية.

---

**آخر تحديث**: 2025  
**الإصدار**: 1.0  
**الحالة**: ✅ جاهز للاستخدام  

🎉 **شكراً لاستخدامك نظام توزيع الكتب!** 🎉

