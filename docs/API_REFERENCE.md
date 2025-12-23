# دليل API Endpoints - مرجع التطبيق

## Base URL
```
http://45.77.65.134/api/
```

## 🔐 Authentication

### Login
```
POST /users/login/
Body: {
  "username": "string",
  "password": "string"
}
Response: {
  "success": true,
  "access": "token",
  "refresh": "token",
  "user": {
    "id": 1,
    "username": "string",
    "full_name": "string",
    "role": "ministry_driver | province_driver | school_staff"
  }
}
```

## 🚚 Driver/Courier APIs

### 1. Get Active Shipments
```
GET /warehouses/mobile/driver/shipments/active/
Headers: Authorization: Bearer {token}
```

### 2. Get Shipment History
```
GET /warehouses/mobile/driver/shipments/history/
Headers: Authorization: Bearer {token}
```

### 3. Start Delivery
```
POST /warehouses/mobile/driver/shipments/{id}/start/
Body: {
  "latitude": 15.5932,
  "longitude": 32.5599
}
```

### 4. Update Location
```
POST /warehouses/mobile/driver/shipments/{id}/location/
Body: {
  "latitude": 15.5932,
  "longitude": 32.5599
}
```

### 5. Upload Proof Photo
```
POST /warehouses/mobile/driver/shipments/{id}/upload-photo/
Body: {
  "photo_base64": "data:image/jpeg;base64,..."
}
```

### 6. Upload Signature
```
POST /warehouses/mobile/driver/shipments/{id}/upload-signature/
Body: {
  "signature_base64": "data:image/png;base64,..."
}
```

### 7. Complete Delivery
```
POST /warehouses/mobile/driver/shipments/{id}/complete/
Body: {
  "recipient_name": "string",
  "delivery_notes": "string",
  "latitude": 15.5932,
  "longitude": 32.5599
}
```

### 8. Get Performance Stats
```
GET /warehouses/mobile/driver/performance/
Headers: Authorization: Bearer {token}
```

## 🏫 School Staff APIs

### 1. Get Incoming Deliveries
```
GET /warehouses/mobile/school/deliveries/incoming/
Query: ?status=out_for_delivery
Headers: Authorization: Bearer {token}
```

### 2. Receive Shipment (Manual)
```
POST /warehouses/mobile/school/deliveries/{id}/receive/
Body: {
  "receiver_name": "string",
  "receiver_notes": "string",
  "delivery_condition": "good | damaged | partial"
}
```

### 3. Receive Shipment with QR ⭐
```
POST /warehouses/mobile/school/deliveries/{id}/scan-qr/
Body: {
  "qr_token": "string",
  "receiver_name": "string",
  "receiver_notes": "string",
  "latitude": 15.5932,
  "longitude": 32.5599
}
```

## 🔄 Unified QR APIs

### 1. Scan QR Code (Universal)
```
POST /warehouses/qr/scan/
Body: {
  "token": "string",
  "recipient_name": "string",
  "notes": "string",
  "latitude": 15.5932,
  "longitude": 32.5599
}
```

### 2. Verify QR Code
```
GET /warehouses/qr/verify/?token={token}
Headers: Authorization: Bearer {token}
```

## 📊 Shipment Status Values

- `pending`: قيد الانتظار
- `assigned`: تم الإسناد
- `out_for_delivery`: خارج للتوصيل
- `delivered`: تم التسليم
- `confirmed`: مؤكد
- `canceled`: ملغي

## 🎯 Flutter Implementation Files

### Models
- `lib/models/api_shipment_model.dart` - جميع نماذج الشحنات والاستجابات
- `lib/models/user_model.dart` - نموذج المستخدم المحدث

### Services
- `lib/services/shipment_service.dart` - خدمة المناديب
- `lib/services/school_delivery_service.dart` - خدمة المدارس
- `lib/services/auth_service.dart` - المصادقة المحدثة

### Screens
- `lib/screens/driver_dashboard_new.dart` - لوحة المندوب
- `lib/screens/school_dashboard_new.dart` - لوحة المدرسة
- `lib/screens/shipment_detail_screen.dart` - تفاصيل الشحنة
- `lib/screens/qr_scanner_screen.dart` - مسح QR محدث

## 🔧 Required Permissions (AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

## 📦 Required Dependencies (pubspec.yaml)

```yaml
dependencies:
  http: ^1.5.0
  provider: ^6.1.5+1
  qr_flutter: ^4.1.0
  image_picker: ^1.0.7
  geolocator: ^10.1.0
  permission_handler: ^11.2.0
```

## ⚠️ Important Notes

1. **QR Code Expiry**: كل QR Code صالح لمدة 72 ساعة
2. **Single Use**: لا يمكن استخدام نفس QR Code مرتين
3. **Location**: الموقع الجغرافي مطلوب للتتبع الأمثل
4. **Authentication**: جميع endpoints تتطلب JWT Token

## 🧪 Test Credentials

### Driver
```
Username: driver
Password: driver123
```

### School Staff
```
Username: school
Password: school123
```

---
**Last Updated**: December 23, 2024
**API Version**: 1.0
