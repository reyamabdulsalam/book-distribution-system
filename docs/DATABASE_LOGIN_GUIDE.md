# 🔐 Database Login Integration Guide

**التاريخ:** 13 يناير 2026  
**الحالة:** ✅ متكامل

---

## 📋 ملخص

تم تكامل نظام تسجيل الدخول من قاعدة البيانات بالكامل:
- ✅ Backend API endpoints جاهزة
- ✅ Flutter App يتصل بـ Database
- ✅ مستخدمي اختبار متاحون
- ✅ JWT Tokens مفعلة

---

## 🔧 إعدادات Backend

### 1. تثبيت المكتبات المطلوبة

```bash
pip install djangorestframework django-rest-framework-simplejwt
```

### 2. تحديثات Settings.py

تمت إضافة:
```python
INSTALLED_APPS = [
    ...
    'rest_framework',
    'rest_framework_simplejwt',
    'distribution',
]

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
}

SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(days=30),
    ...
}
```

### 3. تحديثات URLs

**book_system/urls.py:**
```python
urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('distribution.urls')),
    path('', include('distribution.urls')),
]
```

**distribution/urls.py:**
```python
urlpatterns = [
    path('api/auth/login/', views.login_view),
    path('api/users/login/', views.login_view),
    path('api/auth/refresh/', views.refresh_token_view),
    path('api/users/me/', views.user_profile_view),
]
```

---

## 👥 إنشاء مستخدمي الاختبار

### الأمر:
```bash
python manage.py create_test_users
```

### المستخدمون المُنشأة:

#### 🚗 المناديب (Drivers):
```
Username: driver1
Password: driver123
Role: مندوب الوزارة
Name: محمد أحمد

Username: driver2
Password: driver456
Role: مندوب المحافظة
Name: سالم عبدالله
```

#### 🏫 موظفو المدارس (School Staff):
```
Username: sf1
Password: sf1password
School: مدرسة النهضة
Name: علي محمد

Username: sf2
Password: sf2password
School: مدرسة التوحيد
Name: فاطمة علي
```

---

## 🔗 Login API Endpoint

### المسارات المدعومة:
- `POST /api/auth/login/`
- `POST /api/users/login/`
- `POST /api/token/`

### Request Body:
```json
{
    "username": "sf1",
    "password": "sf1password"
}
```

### Response (Success):
```json
{
    "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "user": {
        "id": 1,
        "username": "sf1",
        "full_name": "علي محمد",
        "role": "school",
        "school_id": 1,
        "school_name": "مدرسة النهضة"
    }
}
```

### Response (Error):
```json
{
    "error": "اسم المستخدم أو كلمة المرور غير صحيحة"
}
```

---

## 📱 Flutter App Integration

### AuthService تحديثات:

```dart
Future<bool> login(String username, String password) async {
    final endpoints = <String>[
        '/api/users/login/',
        '/api/auth/login/',
        '/api/token/',
        '/api/warehouses/login/',
        '/api/warehouses/mobile/login/',
    ];

    for (final path in endpoints) {
        final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
        final resp = await http.post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
                'username': username,
                'password': password
            }),
        );

        if (resp.statusCode == 200 || resp.statusCode == 201) {
            final data = jsonDecode(utf8.decode(resp.bodyBytes));
            
            // Extract token
            final accessToken = data['access'];
            ApiClient.setTokens(access: accessToken);
            
            // Extract user info
            final userJson = data['user'];
            _currentUser = User.fromJson(userJson);
            
            notifyListeners();
            return true;
        }
    }
    return false;
}
```

---

## 🧪 اختبار الدخول

### 1. من Postman:
```
POST http://localhost:8000/api/auth/login/
Content-Type: application/json

{
    "username": "sf1",
    "password": "sf1password"
}
```

### 2. من التطبيق الجوال:
```dart
final authService = Provider.of<AuthService>(context, listen: false);
bool success = await authService.login('sf1', 'sf1password');

if (success) {
    print('✅ Login successful!');
    print('User: ${authService.currentUser?.fullName}');
    print('School: ${authService.currentUser?.schoolName}');
} else {
    print('❌ Login failed');
}
```

### 3. من سطر الأوامر (curl):
```bash
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"sf1","password":"sf1password"}'
```

---

## 🔐 Security Features

### ✅ المميزات الأمنية:

1. **JWT Tokens**
   - Access Token: صلاحية 30 يوم
   - Refresh Token: صلاحية 90 يوم

2. **Password Security**
   - تشفير كامل كلمات المرور
   - Django password validators

3. **User Validation**
   - التحقق من أن الحساب نشط
   - التحقق من دور المستخدم
   - معالجة محاولات دخول فاشلة

4. **Role-based Access**
   - مندوب (مستخدم Courier)
   - موظف مدرسة (مستخدم SchoolUser)
   - Admin

---

## 📊 Database Structure

### Tables:

```
auth_user (Django Default)
├─ id: int (PK)
├─ username: varchar (UNIQUE)
├─ password: varchar (hashed)
├─ email: varchar
├─ first_name: varchar
├─ last_name: varchar
├─ is_active: boolean
└─ is_staff: boolean

distribution_courier (For Drivers)
├─ id: int (PK)
├─ user_id: int (FK -> auth_user)
├─ name: varchar
├─ phone: varchar
├─ governorate_id: int (FK)
└─ is_active: boolean

distribution_schooluser (For School Staff)
├─ id: int (PK)
├─ user_id: int (FK -> auth_user)
├─ school_id: int (FK)
└─ is_active: boolean

distribution_school
├─ id: int (PK)
├─ name: varchar
├─ address: text
├─ phone: varchar
├─ governorate_id: int (FK)
└─ is_active: boolean

distribution_governorate
├─ id: int (PK)
├─ name: varchar
├─ code: varchar
└─ is_active: boolean
```

---

## 🚀 خطوات التشغيل

### 1. Database Setup:
```bash
python manage.py migrate
```

### 2. Create Test Users:
```bash
python manage.py create_test_users
```

### 3. Create Superuser (Optional):
```bash
python manage.py createsuperuser
```

### 4. Run Server:
```bash
python manage.py runserver 0.0.0.0:8000
```

### 5. Test Login:
```bash
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"sf1","password":"sf1password"}'
```

---

## 📝 Troubleshooting

### ❌ "اسم المستخدم أو كلمة المرور غير صحيحة"
- تحقق من أن المستخدم موجود في قاعدة البيانات
- تأكد من كلمة المرور صحيحة
- تحقق من أن الحساب نشط (is_active=True)

### ❌ "لا توجد قاعدة بيانات"
- تشغيل الـ migrations: `python manage.py migrate`
- تحقق من إعدادات قاعدة البيانات في settings.py

### ❌ "Module not found: rest_framework"
- تثبيت المكتبات: `pip install -r requirements.txt`

### ❌ Flutter: "All login endpoints failed"
- تحقق من أن Backend يعمل
- تحقق من API_BASE_URL في Flutter (constants.dart)
- استخدم Postman للاختبار أولاً

---

## 📚 ملفات ذات صلة

- [distribution/views.py](distribution/views.py) - Login views
- [distribution/urls.py](distribution/urls.py) - API routes
- [distribution/models.py](distribution/models.py) - Database models
- [book_system/settings.py](book_system/settings.py) - Configuration
- [lib/services/auth_service.dart](lib/services/auth_service.dart) - Flutter auth

---

## ✅ التحقق من التكامل

```python
# اختبار من Django shell
python manage.py shell

>>> from django.contrib.auth.models import User
>>> from distribution.models import SchoolUser, School

# التحقق من المستخدمين
>>> User.objects.all()
<QuerySet [<User: sf1>, <User: sf2>, <User: driver1>, <User: driver2>]>

# التحقق من المدارس
>>> School.objects.all()
<QuerySet [<School: مدرسة النهضة>, <School: مدرسة التوحيد>]>

# التحقق من ربط موظفي المدارس
>>> SchoolUser.objects.all()
<QuerySet [<SchoolUser: sf1 - مدرسة النهضة>, <SchoolUser: sf2 - مدرسة التوحيد>]>
```

---

**Status:** ✅ **READY FOR PRODUCTION**  
**Last Updated:** 2026-01-13  
**Version:** 1.0
