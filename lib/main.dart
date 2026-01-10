import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/school_home_screen.dart';
import 'screens/driver_dashboard_new.dart';
import 'services/auth_service.dart';
import 'services/order_service.dart';
import 'services/courier_service.dart';
import 'services/notification_service.dart';
import 'services/shipment_service.dart';
import 'services/school_delivery_service.dart';
import 'services/grade_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) {
          final service = OrderService();
          service.addSampleOrders(); // إضافة بيانات تجريبية
          // حاول جلب البيانات من الباك-إند (非-blocking)
          service.fetchOrders();
          return service;
        }),
        ChangeNotifierProvider(create: (_) => CourierService()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
        // الخدمات الجديدة المتوافقة مع API
        ChangeNotifierProvider(create: (_) => ShipmentService()),
        ChangeNotifierProvider(create: (_) => SchoolDeliveryService()),
        ChangeNotifierProvider(create: (_) => GradeService()),
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
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
          bodyMedium: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
          bodySmall: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w500),
          displayLarge: TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold),
          displaySmall: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
          titleSmall: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
          labelLarge: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
          labelMedium: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w500),
          labelSmall: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w500),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
          hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          floatingLabelStyle: TextStyle(color: Colors.blue.shade700, fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      home: Consumer<AuthService>(
        builder: (context, authService, child) {
          if (authService.currentUser != null) {
            final role = authService.currentUser!.role;
            
            // استخدام الشاشات الجديدة المتوافقة مع API
            if (role == 'school_staff' || role == 'school') {
              return SchoolHomeScreen(); // الواجهة الرئيسية: لوحة التحكم مع إحصائيات
            } else if (role == 'ministry_driver' || role == 'province_driver' || role == 'courier') {
              return DriverDashboardNew();
            } else {
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