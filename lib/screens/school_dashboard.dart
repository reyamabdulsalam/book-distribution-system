import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/order_service.dart';
import '../models/order_model.dart';
import '../models/book_model.dart';
import '../utils/constants.dart';
import '../widgets/custom_drawer.dart';
import 'school_order_screen.dart';

class SchoolDashboard extends StatefulWidget {
  @override
  _SchoolDashboardState createState() => _SchoolDashboardState();
}

class _SchoolDashboardState extends State<SchoolDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final orderService = Provider.of<OrderService>(context, listen: false);
    
    if (authService.currentUser?.schoolId != null) {
      final schoolId = int.tryParse(authService.currentUser!.schoolId!);
      if (schoolId != null) {
        await orderService.fetchSchoolRequests(schoolId);
      }
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final orderService = Provider.of<OrderService>(context);

    // التحقق من وجود المستخدم
    if (authService.currentUser == null) {
      return Scaffold(
        body: Center(child: Text('خطأ: لم يتم تسجيل الدخول')),
      );
    }

    // عرض مؤشر تحميل
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('لوحة المدرسة'),
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('جاري تحميل الطلبات...'),
            ],
          ),
        ),
      );
    }

    // استخدام ID المستخدم بدلاً من schoolId
    final userId = authService.currentUser!.id;
    final schoolId = authService.currentUser!.schoolId ?? userId;

    final myOrders = orderService.pendingOrders.where(
            (order) => order.schoolId == schoolId || order.schoolId == userId
    ).toList();

    // تصنيف الطلبات
    final allOrders = myOrders;
    final pendingOrders = myOrders.where((o) => o.status == 'pending' || o.status == 'submitted').toList();
    final approvedOrders = myOrders.where((o) => o.status == 'approved').toList();
    final deliveredOrders = myOrders.where((o) => o.status == 'delivered' || o.status == 'fulfilled').toList();

    final stats = _calculateStats(myOrders);

    return Scaffold(
      appBar: AppBar(
        title: Text('لوحة المدرسة',
            style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.schoolColor,
          indicatorWeight: 3,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(icon: Icon(Icons.list_alt), text: 'الكل (${allOrders.length})'),
            Tab(icon: Icon(Icons.access_time), text: 'معلق (${pendingOrders.length})'),
            Tab(icon: Icon(Icons.check_circle_outline), text: 'مقبول (${approvedOrders.length})'),
            Tab(icon: Icon(Icons.done_all), text: 'مسلّم (${deliveredOrders.length})'),
          ],
        ),
      ),
      drawer: CustomDrawer(currentScreen: 'home'),
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // بطاقة الإحصائيات
          _buildEnhancedStatsCard(stats, authService.currentUser!.fullName),
          
          // قائمة الطلبات حسب التبويب
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersListView(allOrders, 'لا توجد طلبات بعد'),
                _buildOrdersListView(pendingOrders, 'لا توجد طلبات معلقة'),
                _buildOrdersListView(approvedOrders, 'لا توجد طلبات مقبولة'),
                _buildOrdersListView(deliveredOrders, 'لا توجد طلبات مسلّمة'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SchoolOrderScreen()),
          );
        },
        icon: Icon(Icons.add, size: 24),
        label: Text('طلب جديد', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.schoolColor,
        elevation: 4,
      ),
    );
  }

  Widget _buildEnhancedStatsCard(Map<String, int> stats, String schoolName) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.schoolColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school, color: AppColors.schoolColor, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schoolName,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'إحصائيات الطلبات',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('الكل', stats['total']!, Icons.list_alt, AppColors.schoolColor),
              _buildStatItem('مقبول', stats['approved']!, Icons.check_circle, Colors.green.shade600),
              _buildStatItem('معلق', stats['pending']!, Icons.access_time, Colors.orange.shade700),
              _buildStatItem('مرفوض', stats['rejected']!, Icons.cancel, Colors.red.shade700),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, int count, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildOrdersListView(List<Order> orders, String emptyMessage) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade300),
            SizedBox(height: 16),
            Text(emptyMessage, style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(Duration(milliseconds: 500));
        setState(() {});
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildEnhancedOrderCard(order, context);
        },
      ),
    );
  }

  Widget _buildEnhancedOrderCard(Order order, BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showEnhancedOrderDetails(order, context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.schoolColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.receipt_long, color: AppColors.schoolColor, size: 20),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'طلب #${order.id.toString()}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _formatDate(order.requestDate),
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  _buildEnhancedStatusChip(order.status),
                ],
              ),
              Divider(height: 24),
              Row(
                children: [
                  _buildInfoItem(Icons.menu_book, '${order.totalBooks} كتاب'),
                  SizedBox(width: 24),
                  if (order.receiptCode != null)
                    _buildInfoItem(Icons.qr_code_2, order.receiptCode!),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
      ],
    );
  }

  Widget _buildEnhancedStatusChip(String status) {
    final statusInfo = _getStatusInfo(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusInfo['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusInfo['color'].withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusInfo['color'],
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6),
          Text(
            statusInfo['text'],
            style: TextStyle(
              color: statusInfo['color'],
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showEnhancedOrderDetails(Order order, BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 16),
            
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.schoolColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.receipt_long, color: AppColors.schoolColor, size: 28),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تفاصيل الطلب',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'طلب #${order.id.toString()}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  _buildEnhancedStatusChip(order.status),
                ],
              ),
            ),
            Divider(height: 32),
            
            // Details
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection('معلومات الطلب', [
                      _buildDetailRow(Icons.calendar_today, 'تاريخ الطلب', _formatDate(order.requestDate)),
                      _buildDetailRow(Icons.menu_book, 'عدد الكتب', '${order.totalBooks} كتاب'),
                    ]),
                    if (order.receiptCode != null) ...[
                      SizedBox(height: 24),
                      _buildDetailSection('معلومات التسليم', [
                        _buildDetailRow(Icons.qr_code_2, 'كود الاستلام', order.receiptCode!),
                      ]),
                    ],
                    if (order.rejectionReason != null) ...[
                      SizedBox(height: 24),
                      _buildDetailSection('سبب الرفض', [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            order.rejectionReason!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ]),
                    ],
                    SizedBox(height: 24),
                    _buildDetailSection('الكتب المطلوبة', 
                      order.books.map((book) => 
                        _buildBookItem(book)
                      ).toList()
                    ),
                  ],
                ),
              ),
            ),
            
            // Footer
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.schoolColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('إغلاق', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.schoolColor),
        ),
        SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookItem(Book book) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.schoolColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.book, size: 20, color: AppColors.schoolColor),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.title, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(book.grade, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.schoolColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${book.quantity}',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _calculateStats(List<Order> orders) {
    return {
      'total': orders.length,
      'approved': orders.where((o) => o.status == 'approved').length,
      'pending': orders.where((o) => o.status == 'pending' || o.status == 'submitted' || o.status == 'draft').length,
      'rejected': orders.where((o) => o.status == 'rejected').length,
    };
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'approved':
        return {'text': 'مقبول', 'color': AppColors.successColor};
      case 'submitted':
        return {'text': 'مرسل للمحافظة', 'color': AppColors.warningColor};
      case 'pending':
      case 'draft':
        return {'text': 'قيد المراجعة', 'color': AppColors.warningColor};
      case 'rejected':
        return {'text': 'مرفوض', 'color': AppColors.errorColor};
      case 'fulfilled':
      case 'delivered':
        return {'text': 'تم التسليم', 'color': AppColors.infoColor};
      default:
        return {'text': status, 'color': Colors.grey};
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}