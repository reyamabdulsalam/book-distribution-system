import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/school_delivery_service.dart';
import '../services/order_service.dart';
import '../services/auth_service.dart';
import '../widgets/custom_drawer.dart';
import '../utils/constants.dart';
import '../models/school_request_model.dart';
import 'school_order_screen.dart';
import 'school_dashboard_new.dart';

/// الواجهة الرئيسية للمدرسة - تعرض الإحصائيات
class SchoolHomeScreen extends StatefulWidget {
  @override
  _SchoolHomeScreenState createState() => _SchoolHomeScreenState();
}

class _SchoolHomeScreenState extends State<SchoolHomeScreen> {
  // تعريف اللون
  final Color appBarColor = AppColors.schoolColor;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final deliveryService = Provider.of<SchoolDeliveryService>(context, listen: false);
    final orderService = Provider.of<OrderService>(context, listen: false);
    final schoolId = int.tryParse(authService.currentUser?.schoolId ?? '');
    
    await Future.wait([
      deliveryService.fetchIncomingDeliveries(),
      if (schoolId != null) orderService.fetchSchoolRequests(schoolId),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final schoolName = authService.currentUser?.schoolName ?? 'المدرسة';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          schoolName,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: appBarColor),
      ),
      drawer: CustomDrawer(currentScreen: 'home'),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان الرئيسي
              _buildHeader(),
              SizedBox(height: 24),
              
              // بطاقات الإحصائيات
              _buildStatisticsCards(),
              SizedBox(height: 24),
              
              // الشحنات الأخيرة
              _buildRecentShipments(),
              SizedBox(height: 24),
              
              // الطلبات الأخيرة
              _buildRecentOrders(),
              SizedBox(height: 80), // مساحة للـ FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SchoolOrderScreen()),
          );
        },
        icon: Icon(Icons.add),
        label: Text('إنشاء طلب جديد'),
        backgroundColor: appBarColor,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [appBarColor, appBarColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: appBarColor.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.school, color: Colors.white, size: 40),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً بك',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'لوحة التحكم',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Consumer2<SchoolDeliveryService, OrderService>(
      builder: (context, deliveryService, orderService, child) {
        final incomingCount = deliveryService.incomingDeliveries.length;
        final receivedCount = deliveryService.receivedDeliveries.length;
        final pendingOrders = orderService.orders.where((o) => o.status == 'pending').length;
        final approvedOrders = orderService.orders.where((o) => o.status == 'approved').length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الإحصائيات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'شحنات قادمة',
                    value: incomingCount.toString(),
                    icon: Icons.local_shipping,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SchoolDashboardNew(),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'شحنات مستلمة',
                    value: receivedCount.toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SchoolDashboardNew(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'طلبات قيد المراجعة',
                    value: pendingOrders.toString(),
                    icon: Icons.hourglass_empty,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'طلبات معتمدة',
                    value: approvedOrders.toString(),
                    icon: Icons.verified,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                if (onTap != null) ...[
                  Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                ],
              ],
            ),
            SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentShipments() {
    return Consumer<SchoolDeliveryService>(
      builder: (context, service, child) {
        final recentShipments = service.incomingDeliveries.take(3).toList();
        
        if (recentShipments.isEmpty) {
          return SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الشحنات القادمة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SchoolDashboardNew(),
                      ),
                    );
                  },
                  child: Text('عرض الكل'),
                ),
              ],
            ),
            SizedBox(height: 8),
            ...recentShipments.map((shipment) => _buildShipmentCard(shipment)).toList(),
          ],
        );
      },
    );
  }

  Widget _buildShipmentCard(dynamic shipment) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.local_shipping, color: Colors.orange),
        ),
        title: Text(
          shipment.trackingCode ?? 'بدون رقم',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'المندوب: ${shipment.assignedCourierName ?? "غير محدد"}',
          style: TextStyle(fontSize: 13),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(shipment.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _getStatusText(shipment.status),
            style: TextStyle(
              color: _getStatusColor(shipment.status),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentOrders() {
    return Consumer<OrderService>(
      builder: (context, service, child) {
        // استخدام SchoolRequest بدلاً من Order للحصول على معلومات الفصل الدراسي
        final recentRequests = service.requests.take(3).toList();
        
        if (recentRequests.isEmpty) {
          return SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الطلبات الأخيرة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // يمكن إضافة شاشة لعرض جميع الطلبات
                  },
                  child: Text('عرض الكل'),
                ),
              ],
            ),
            SizedBox(height: 8),
            ...recentRequests.map((request) => _buildRequestCard(request)).toList(),
          ],
        );
      },
    );
  }

  Widget _buildRequestCard(SchoolRequest request) {
    // جمع الفصول الدراسية من العناصر
    final semesters = request.items.map((item) => item.termInArabic).toSet().join(', ');
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getOrderStatusColor(request.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.receipt_long, color: _getOrderStatusColor(request.status)),
        ),
        title: Text(
          'طلب #${request.id}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${request.items.length} كتاب - $semesters',
          style: TextStyle(fontSize: 13),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getOrderStatusColor(request.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _getOrderStatusText(request.status),
            style: TextStyle(
              color: _getOrderStatusColor(request.status),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'assigned':
        return Colors.blue;
      case 'out_for_delivery':
        return Colors.orange;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'assigned':
        return 'مُسندة';
      case 'out_for_delivery':
        return 'خارجة للتوصيل';
      case 'delivered':
        return 'تم التسليم';
      case 'confirmed':
        return 'مؤكدة';
      default:
        return status;
    }
  }

  Color _getOrderStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'shipped':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getOrderStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد المراجعة';
      case 'approved':
        return 'معتمد';
      case 'rejected':
        return 'مرفوض';
      case 'shipped':
        return 'تم الشحن';
      default:
        return status;
    }
  }
}
