import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/api_shipment_model.dart';
import '../services/auth_service.dart';
import '../services/shipment_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_drawer.dart';
import 'shipment_detail_screen.dart';
import 'qr_scanner_screen.dart';

/// لوحة تحكم المندوب المحدثة - متوافقة مع API
class DriverDashboardNew extends StatefulWidget {
  @override
  _DriverDashboardNewState createState() => _DriverDashboardNewState();
}

class _DriverDashboardNewState extends State<DriverDashboardNew> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final shipmentService = Provider.of<ShipmentService>(context, listen: false);
    await Future.wait([
      shipmentService.fetchActiveShipments(),
      shipmentService.fetchShipmentHistory(),
      shipmentService.fetchPerformance(),
    ]);
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final shipmentService = Provider.of<ShipmentService>(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('مندوب التوصيل - ${authService.currentUser?.fullName ?? ""}',
              style: TextStyle(color: Colors.black, fontSize: 18)),
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.black),
          actions: [
            IconButton(
              icon: Icon(Icons.qr_code_scanner),
              onPressed: () => _navigateToQrScanner(context),
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _refreshData,
            ),
          ],
          bottom: TabBar(
            indicatorColor: AppColors.courierColor,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorWeight: 3,
            tabs: [
              Tab(
                text: 'نشطة (${shipmentService.activeShipments.length})',
                icon: Icon(Icons.local_shipping),
              ),
              Tab(
                text: 'السجل (${shipmentService.historyShipments.length})',
                icon: Icon(Icons.history),
              ),
              Tab(
                text: 'الإحصائيات',
                icon: Icon(Icons.bar_chart),
              ),
            ],
          ),
        ),
        drawer: CustomDrawer(currentScreen: 'home'),
        body: shipmentService.isLoading
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildActiveShipmentsTab(shipmentService.activeShipments),
                  _buildHistoryTab(shipmentService.historyShipments),
                  _buildPerformanceTab(shipmentService.performance),
                ],
              ),
      ),
    );
  }

  Widget _buildActiveShipmentsTab(List<ApiShipment> shipments) {
    if (shipments.isEmpty) {
      return _buildEmptyState('لا توجد شحنات نشطة', Icons.local_shipping_outlined);
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: shipments.length,
        itemBuilder: (context, index) {
          final shipment = shipments[index];
          return _buildShipmentCard(shipment);
        },
      ),
    );
  }

  Widget _buildHistoryTab(List<ApiShipment> shipments) {
    if (shipments.isEmpty) {
      return _buildEmptyState('لا يوجد سجل', Icons.history);
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: shipments.length,
        itemBuilder: (context, index) {
          final shipment = shipments[index];
          return _buildShipmentCard(shipment, isHistory: true);
        },
      ),
    );
  }

  Widget _buildPerformanceTab(DriverPerformance? performance) {
    if (performance == null) {
      return Center(child: Text('لا توجد إحصائيات متاحة'));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('أدائي',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),

          // بطاقات الإحصائيات
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'إجمالي التوصيلات',
                  performance.totalDeliveries.toString(),
                  Icons.local_shipping,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'اليوم',
                  performance.completedToday.toString(),
                  Icons.today,
                  Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'هذا الشهر',
                  performance.thisMonth.toString(),
                  Icons.calendar_month,
                  Colors.orange,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'معدل النجاح',
                  '${performance.successRate.toStringAsFixed(1)}%',
                  Icons.check_circle,
                  Colors.purple,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          Card(
            child: ListTile(
              leading: Icon(Icons.timer, color: Colors.blue),
              title: Text('متوسط وقت التوصيل'),
              trailing: Text(performance.averageDeliveryTime,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),

          SizedBox(height: 24),
          Text('آخر التوصيلات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),

          ...performance.recentShipments
              .map((s) => _buildShipmentCard(s, isCompact: true)),
        ],
      ),
    );
  }

  Widget _buildShipmentCard(ApiShipment shipment,
      {bool isHistory = false, bool isCompact = false}) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShipmentDetailScreen(shipment: shipment),
          ),
        ).then((_) => _refreshData()),
        child: Padding(
          padding: EdgeInsets.all(isCompact ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان والحالة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      shipment.toSchoolName ?? 'مدرسة غير محددة',
                      style: TextStyle(
                        fontSize: isCompact ? 14 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(shipment.status, shipment.statusInArabic),
                ],
              ),
              SizedBox(height: 8),

              // معلومات الشحنة
              Row(
                children: [
                  Icon(Icons.qr_code, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      shipment.trackingCode,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),

              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${shipment.fromMinistryName ?? "؟"} ← ${shipment.toProvinceName ?? "؟"}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),

              Row(
                children: [
                  Icon(Icons.menu_book, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    '${shipment.totalBooks} كتاب',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Spacer(),
                  Icon(Icons.access_time, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    _formatDate(shipment.createdAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),

              // أزرار الإجراءات
              if (!isHistory && !isCompact) ...[
                SizedBox(height: 12),
                Row(
                  children: [
                    if (shipment.canStartDelivery)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ShipmentDetailScreen(shipment: shipment),
                            ),
                          ),
                          icon: Icon(Icons.play_arrow, size: 18),
                          label: Text('بدء'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    if (shipment.isOutForDelivery) ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ShipmentDetailScreen(shipment: shipment),
                            ),
                          ),
                          icon: Icon(Icons.check_circle, size: 18),
                          label: Text('إكمال'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.successColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _navigateToQrScanner(context),
                        icon: Icon(Icons.qr_code_scanner, size: 18),
                        label: Text('QR'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title,
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, String label) {
    Color color;
    switch (status) {
      case 'assigned':
        color = Colors.blue;
        break;
      case 'out_for_delivery':
        color = Colors.orange;
        break;
      case 'delivered':
      case 'confirmed':
        color = Colors.green;
        break;
      case 'canceled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[300]),
          SizedBox(height: 16),
          Text(message,
              style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: Icon(Icons.refresh),
            label: Text('تحديث'),
          ),
        ],
      ),
    );
  }

  void _navigateToQrScanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QrScannerScreen()),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }
}
