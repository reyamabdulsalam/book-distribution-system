# أمثلة سريعة - Quick Examples

## 🔐 تسجيل الدخول من التطبيق

### 1. Login Widget
```dart
// في صفحة تسجيل الدخول
final authService = Provider.of<AuthService>(context, listen: false);

bool success = await authService.login(username, password);

if (success) {
  // انتقل للصفحة الرئيسية حسب الدور
  if (authService.currentUser?.role == 'school') {
    Navigator.pushReplacement(context, 
      MaterialPageRoute(builder: (_) => SchoolDashboard()));
  } else if (authService.currentUser?.role == 'courier') {
    Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (_) => CourierDashboard()));
  }
} else {
  // اعرض رسالة خطأ
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('فشل تسجيل الدخول')),
  );
}
```

---

## 📚 إنشاء طلب كتب

### 2. Create School Request
```dart
import 'package:provider/provider.dart';
import '../services/order_service.dart';
import '../models/school_request_model.dart';

// في صفحة إنشاء الطلب
Future<void> createBookRequest() async {
  final orderService = Provider.of<OrderService>(context, listen: false);
  
  final request = SchoolRequest(
    schoolId: 1, // ID المدرسة من المستخدم الحالي
    items: [
      SchoolRequestItem(
        bookId: 13, // Math grade 6
        quantity: 50,
        term: 'first',
      ),
      SchoolRequestItem(
        bookId: 18, // Science grade 5
        quantity: 30,
        term: 'first',
      ),
    ],
    requestDate: DateTime.now(),
    notes: 'طلب كتب الفصل الأول',
  );

  final result = await orderService.createSchoolRequest(request);
  
  if (result != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم إنشاء الطلب بنجاح - رقم: ${result.id}')),
    );
    // انتقل لصفحة الطلبات
    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('فشل إنشاء الطلب')),
    );
  }
}
```

---

## 📋 عرض طلبات المدرسة

### 3. Display School Requests
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/order_service.dart';
import '../services/auth_service.dart';

class SchoolRequestsPage extends StatefulWidget {
  @override
  _SchoolRequestsPageState createState() => _SchoolRequestsPageState();
}

class _SchoolRequestsPageState extends State<SchoolRequestsPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final orderService = Provider.of<OrderService>(context, listen: false);
    
    final schoolId = int.tryParse(authService.currentUser?.schoolId ?? '');
    if (schoolId != null) {
      await orderService.fetchSchoolRequests(schoolId);
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('طلبات الكتب')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Consumer<OrderService>(
              builder: (context, orderService, child) {
                final requests = orderService.requests;
                
                if (requests.isEmpty) {
                  return Center(child: Text('لا توجد طلبات'));
                }
                
                return RefreshIndicator(
                  onRefresh: _loadRequests,
                  child: ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      return Card(
                        margin: EdgeInsets.all(8),
                        child: ListTile(
                          title: Text('طلب رقم: ${request.id}'),
                          subtitle: Text(
                            '${request.totalBooks} كتاب - ${request.statusInArabic}',
                          ),
                          trailing: _buildStatusChip(request.status),
                          onTap: () {
                            // عرض تفاصيل الطلب
                            _showRequestDetails(request);
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // انتقل لصفحة إنشاء طلب جديد
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateRequestPage()),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'approved':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      case 'delivered':
        color = Colors.blue;
        break;
      default:
        color = Colors.orange;
    }
    
    return Chip(
      label: Text(
        status == 'pending' ? 'قيد المراجعة' : 
        status == 'approved' ? 'معتمد' :
        status == 'rejected' ? 'مرفوض' : 'تم التسليم',
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }

  void _showRequestDetails(SchoolRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل الطلب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('رقم الطلب: ${request.id}'),
            Text('التاريخ: ${request.requestDate.toString().split(' ')[0]}'),
            Text('الحالة: ${request.statusInArabic}'),
            SizedBox(height: 16),
            Text('الكتب المطلوبة:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...request.items.map((item) => Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text('- ${item.bookTitle ?? 'كتاب'}: ${item.quantity}'),
            )),
            if (request.receiptCode != null) ...[
              SizedBox(height: 16),
              Text('كود الاستلام: ${request.receiptCode}',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ],
            if (request.rejectionReason != null) ...[
              SizedBox(height: 16),
              Text('سبب الرفض:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(request.rejectionReason!, style: TextStyle(color: Colors.red)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
```

---

## 🚚 واجهة المندوب - عرض الشحنات

### 4. Courier Shipments
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/shipment_service.dart'; // سننشئه

class CourierShipmentsPage extends StatefulWidget {
  @override
  _CourierShipmentsPageState createState() => _CourierShipmentsPageState();
}

class _CourierShipmentsPageState extends State<CourierShipmentsPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShipments();
  }

  Future<void> _loadShipments() async {
    final shipmentService = Provider.of<ShipmentService>(context, listen: false);
    await shipmentService.fetchCourierShipments();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('الشحنات')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Consumer<ShipmentService>(
              builder: (context, shipmentService, child) {
                final shipments = shipmentService.shipments;
                
                if (shipments.isEmpty) {
                  return Center(child: Text('لا توجد شحنات'));
                }
                
                return RefreshIndicator(
                  onRefresh: _loadShipments,
                  child: ListView.builder(
                    itemCount: shipments.length,
                    itemBuilder: (context, index) {
                      final shipment = shipments[index];
                      return Card(
                        margin: EdgeInsets.all(8),
                        child: ListTile(
                          leading: Icon(
                            Icons.local_shipping,
                            color: _getStatusColor(shipment.status),
                          ),
                          title: Text('شحنة رقم: ${shipment.id}'),
                          subtitle: Text(
                            'من: ${shipment.fromMinistryName ?? "الوزارة"}\n'
                            'إلى: ${shipment.toProvinceName ?? "المحافظة"}\n'
                            '${shipment.totalBooks} كتاب - ${shipment.statusInArabic}',
                          ),
                          isThreeLine: true,
                          trailing: _buildActionButton(shipment),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'assigned':
        return Colors.orange;
      case 'in_transit':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget? _buildActionButton(Shipment shipment) {
    if (shipment.status == 'assigned') {
      return ElevatedButton(
        child: Text('ابدأ'),
        onPressed: () => _updateStatus(shipment.id!, 'in_transit'),
      );
    } else if (shipment.status == 'in_transit') {
      return ElevatedButton(
        child: Text('تسليم'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        onPressed: () => _updateStatus(shipment.id!, 'delivered'),
      );
    }
    return null;
  }

  Future<void> _updateStatus(int shipmentId, String newStatus) async {
    final shipmentService = Provider.of<ShipmentService>(context, listen: false);
    
    final success = await shipmentService.updateShipmentStatus(shipmentId, newStatus);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تحديث حالة الشحنة')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تحديث الحالة')),
      );
    }
  }
}
```

---

## 🔔 عرض الإشعارات

### 5. Notifications
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    notificationService.fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('الإشعارات')),
      body: Consumer<NotificationService>(
        builder: (context, notificationService, child) {
          final notifications = notificationService.notifications;
          
          if (notifications.isEmpty) {
            return Center(child: Text('لا توجد إشعارات'));
          }
          
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Card(
                color: notification.isRead ? Colors.white : Colors.blue.shade50,
                child: ListTile(
                  leading: Icon(
                    _getNotificationIcon(notification.type),
                    color: Colors.blue,
                  ),
                  title: Text(notification.title),
                  subtitle: Text(
                    '${notification.message}\n${_formatDate(notification.createdAt)}',
                  ),
                  isThreeLine: true,
                  onTap: () {
                    // تحديد الإشعار كمقروء
                    notificationService.markAsRead(notification.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'shipment_created':
        return Icons.local_shipping;
      case 'request_approved':
        return Icons.check_circle;
      case 'request_rejected':
        return Icons.cancel;
      default:
        return Icons.notifications;
    }
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

## 📦 تحديث main.dart

### 6. Complete Provider Setup
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/school_dashboard.dart';
import 'screens/courier_dashboard.dart';
import 'services/auth_service.dart';
import 'services/order_service.dart';
import 'services/courier_service.dart';
import 'services/shipment_service.dart'; // NEW
import 'services/notification_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => OrderService()),
        ChangeNotifierProvider(create: (_) => CourierService()),
        ChangeNotifierProvider(create: (_) => ShipmentService()), // NEW
        ChangeNotifierProvider(create: (_) => NotificationService()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نظام توزيع الكتب',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Cairo',
      ),
      home: Consumer<AuthService>(
        builder: (context, authService, child) {
          if (authService.currentUser != null) {
            switch (authService.currentUser!.role) {
              case 'school':
              case 'school_admin':
                return SchoolDashboard();
              case 'courier':
              case 'ministry_courier':
                return CourierDashboard();
              default:
                return LoginScreen();
            }
          }
          return LoginScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
```

---

## 🧪 اختبار سريع

### 7. Test Script
```bash
#!/bin/bash
# test_flutter_integration.sh

echo "🔍 اختبار التكامل بين Flutter و Backend"
echo "=========================================="

# 1. تحقق من Backend
echo "1. فحص Backend..."
curl -s http://localhost:8000/api/auth/login/ > /dev/null
if [ $? -eq 0 ]; then
  echo "   ✅ Backend يعمل"
else
  echo "   ❌ Backend لا يعمل - شغّله أولاً"
  exit 1
fi

# 2. تحقق من Flutter
echo "2. فحص Flutter..."
cd /home/reyam/ketabi/mobile/book_distribution_system
flutter doctor -v | grep -q "No issues found"
if [ $? -eq 0 ]; then
  echo "   ✅ Flutter جاهز"
else
  echo "   ⚠️  تحقق من إعدادات Flutter"
fi

# 3. تشغيل التطبيق
echo "3. تشغيل التطبيق..."
flutter run --verbose

echo "تم!"
```

---

هذه الأمثلة توضح الاستخدام الأساسي لجميع المكونات. يمكنك نسخها واستخدامها مباشرة! 🚀
