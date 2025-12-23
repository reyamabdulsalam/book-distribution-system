import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/api_shipment_model.dart';
import '../services/auth_service.dart';
import '../services/school_delivery_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_drawer.dart';
import 'qr_scanner_screen.dart';

/// لوحة تحكم المدرسة المحدثة - متوافقة مع API
class SchoolDashboardNew extends StatefulWidget {
  @override
  _SchoolDashboardNewState createState() => _SchoolDashboardNewState();
}

class _SchoolDashboardNewState extends State<SchoolDashboardNew> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final deliveryService =
        Provider.of<SchoolDeliveryService>(context, listen: false);
    await deliveryService.fetchIncomingDeliveries();
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final deliveryService = Provider.of<SchoolDeliveryService>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            authService.currentUser?.schoolName ??
                authService.currentUser?.fullName ??
                'المدرسة',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.black),
          actions: [
            // عدد الشحنات المعلقة
            if (deliveryService.pendingCount > 0)
              Center(
                child: Container(
                  margin: EdgeInsets.only(right: 8),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${deliveryService.pendingCount} جديد',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
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
            indicatorColor: AppColors.schoolColor,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorWeight: 3,
            tabs: [
              Tab(
                text: 'الواردة (${deliveryService.incomingDeliveries.length})',
                icon: Icon(Icons.inbox),
              ),
              Tab(
                text: 'المستلمة (${deliveryService.receivedDeliveries.length})',
                icon: Icon(Icons.check_circle),
              ),
            ],
          ),
        ),
        drawer: CustomDrawer(currentScreen: 'home'),
        body: deliveryService.isLoading
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildIncomingTab(deliveryService.incomingDeliveries),
                  _buildReceivedTab(deliveryService.receivedDeliveries),
                ],
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _navigateToQrScanner(context),
          icon: Icon(Icons.qr_code_scanner),
          label: Text('استلام شحنة'),
          backgroundColor: AppColors.schoolColor,
        ),
      ),
    );
  }

  Widget _buildIncomingTab(List<ApiShipment> shipments) {
    if (shipments.isEmpty) {
      return _buildEmptyState('لا توجد شحنات واردة', Icons.inbox);
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

  Widget _buildReceivedTab(List<ApiShipment> shipments) {
    if (shipments.isEmpty) {
      return _buildEmptyState('لا توجد شحنات مستلمة', Icons.check_circle_outline);
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: shipments.length,
        itemBuilder: (context, index) {
          final shipment = shipments[index];
          return _buildShipmentCard(shipment, isReceived: true);
        },
      ),
    );
  }

  Widget _buildShipmentCard(ApiShipment shipment, {bool isReceived = false}) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showShipmentDetails(shipment),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // العنوان والحالة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          isReceived ? Icons.check_circle : Icons.local_shipping,
                          color: isReceived ? Colors.green : Colors.orange,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            shipment.fromMinistryName ?? 'شحنة جديدة',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(shipment.status, shipment.statusInArabic),
                ],
              ),
              SizedBox(height: 12),

              // معلومات الشحنة
              _buildInfoRow(Icons.qr_code, shipment.trackingCode),
              SizedBox(height: 6),
              _buildInfoRow(
                  Icons.menu_book, '${shipment.totalBooks} كتاب'),
              SizedBox(height: 6),
              _buildInfoRow(Icons.access_time, _formatDate(shipment.createdAt)),
              if (shipment.assignedCourierName != null) ...[
                SizedBox(height: 6),
                _buildInfoRow(Icons.person, shipment.assignedCourierName!),
              ],
              if (shipment.deliveredAt != null) ...[
                SizedBox(height: 6),
                _buildInfoRow(
                  Icons.check,
                  'تم الاستلام: ${_formatDate(shipment.deliveredAt!)}',
                  color: Colors.green,
                ),
              ],

              // الكتب
              if (shipment.books.isNotEmpty) ...[
                SizedBox(height: 12),
                Divider(),
                Text('الكتب:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    )),
                SizedBox(height: 6),
                ...shipment.books.take(3).map((book) => Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(Icons.book, size: 16, color: Colors.grey),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              book.bookName ?? 'كتاب #${book.bookId}',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          Text(
                            '×${book.quantity}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    )),
                if (shipment.books.length > 3)
                  Text(
                    '+ ${shipment.books.length - 3} كتب أخرى',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],

              // أزرار الإجراءات
              if (!isReceived &&
                  (shipment.status == 'out_for_delivery' ||
                      shipment.status == 'assigned')) ...[
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _receiveWithQr(shipment),
                        icon: Icon(Icons.qr_code_scanner, size: 18),
                        label: Text('استلام بـ QR'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.successColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _receiveManually(shipment),
                      icon: Icon(Icons.check, size: 18),
                      label: Text('يدوي'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: color ?? Colors.grey[700],
            ),
          ),
        ),
      ],
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
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
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

  void _showShipmentDetails(ApiShipment shipment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('تفاصيل الشحنة',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              _buildDetailRow('رقم التتبع', shipment.trackingCode),
              _buildDetailRow('الحالة', shipment.statusInArabic),
              _buildDetailRow('من', shipment.fromMinistryName ?? '-'),
              _buildDetailRow('المحافظة', shipment.toProvinceName ?? '-'),
              _buildDetailRow('عدد الكتب', '${shipment.totalBooks} كتاب'),
              _buildDetailRow('المندوب', shipment.assignedCourierName ?? '-'),
              _buildDetailRow(
                  'تاريخ الإنشاء', _formatDate(shipment.createdAt)),
              if (shipment.deliveredAt != null)
                _buildDetailRow(
                    'تاريخ الاستلام', _formatDate(shipment.deliveredAt!)),
              SizedBox(height: 16),
              Text('الكتب:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ...shipment.books.map((book) => ListTile(
                    leading: Icon(Icons.book, color: AppColors.primaryColor),
                    title: Text(book.bookName ?? 'كتاب #${book.bookId}'),
                    trailing: Text('×${book.quantity}',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(book.termInArabic),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _receiveWithQr(ApiShipment shipment) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QrScannerScreen()),
    ).then((_) => _refreshData());
  }

  void _receiveManually(ApiShipment shipment) {
    final _nameController = TextEditingController();
    final _notesController = TextEditingController();
    String _condition = 'good';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('استلام يدوي'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'اسم المستلم',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _condition,
                decoration: InputDecoration(
                  labelText: 'حالة الشحنة',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'good', child: Text('جيدة')),
                  DropdownMenuItem(value: 'damaged', child: Text('تالفة')),
                  DropdownMenuItem(value: 'partial', child: Text('جزئية')),
                ],
                onChanged: (value) => _condition = value!,
              ),
              SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'ملاحظات',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('الرجاء إدخال اسم المستلم')),
                );
                return;
              }

              Navigator.pop(context);

              final deliveryService =
                  Provider.of<SchoolDeliveryService>(context, listen: false);

              final result = await deliveryService.receiveShipmentManually(
                shipmentId: shipment.id,
                receiverName: _nameController.text,
                receiverNotes: _notesController.text,
                deliveryCondition: _condition,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['message']),
                  backgroundColor:
                      result['success'] ? Colors.green : Colors.red,
                ),
              );

              if (result['success']) {
                _refreshData();
              }
            },
            child: Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _navigateToQrScanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QrScannerScreen()),
    ).then((_) => _refreshData());
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
