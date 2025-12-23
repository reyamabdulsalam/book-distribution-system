import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/courier_model.dart';
import '../services/auth_service.dart';
import '../services/courier_service.dart';
import '../services/order_service.dart';
import '../models/order_model.dart';
import '../utils/constants.dart';
import '../widgets/custom_drawer.dart';
import 'qr_scanner_screen.dart';

class CourierDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final courierService = Provider.of<CourierService>(context);
    final orderService = Provider.of<OrderService>(context);
    final authService = Provider.of<AuthService>(context);

    final approvedOrders = orderService.pendingOrders.where(
            (order) => order.status == 'approved'
    ).toList();

    final myTasks = courierService.getCourierTasks(authService.currentUser!.id.toString());
    final pendingTasks = myTasks.where((task) => task.status != 'delivered').toList();
    final completedTasks = myTasks.where((task) => task.status == 'delivered').toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('لوحة المندوب - ${authService.currentUser?.fullName}',
              style: TextStyle(color: Colors.black, fontSize: 18)),
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.black),
          bottom: TabBar(
            indicatorColor: AppColors.courierColor,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'مهامي (${pendingTasks.length})', icon: Icon(Icons.assignment)),
              Tab(text: 'جاهزة للتسليم (${approvedOrders.length})', icon: Icon(Icons.local_shipping)),
              Tab(text: 'مكتملة (${completedTasks.length})', icon: Icon(Icons.check_circle)),
            ],
          ),
        ),
        drawer: CustomDrawer(currentScreen: 'home'),
        body: TabBarView(
          children: [
            _buildMyTasksTab(pendingTasks, context),
            _buildAvailableOrdersTab(approvedOrders, context),
            _buildCompletedTasksTab(completedTasks, context),
          ],
        ),
      ),
    );
  }

  Widget _buildMyTasksTab(List<DeliveryTask> tasks, BuildContext context) {
    return _buildTasksList(tasks, 'مهامي الحالية', Icons.assignment, context);
  }

  Widget _buildAvailableOrdersTab(List<Order> orders, BuildContext context) {
    return _buildOrdersList(orders, 'طلبات جاهزة', Icons.local_shipping, context);
  }

  Widget _buildCompletedTasksTab(List<DeliveryTask> tasks, BuildContext context) {
    return _buildTasksList(tasks, 'المهام المكتملة', Icons.check_circle, context);
  }

  Widget _buildTasksList(List<DeliveryTask> tasks, String title, IconData icon, BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: AppColors.courierColor),
              SizedBox(width: 8),
              Text('$title (${tasks.length})', style: AppStyles.heading3),
            ],
          ),
        ),
        Expanded(
          child: tasks.isEmpty
              ? _buildEmptyState(title)
              : ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _buildTaskCard(task, context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersList(List<Order> orders, String title, IconData icon, BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: AppColors.courierColor),
              SizedBox(width: 8),
              Text('$title (${orders.length})', style: AppStyles.heading3),
            ],
          ),
        ),
        Expanded(
          child: orders.isEmpty
              ? _buildEmptyState(title)
              : ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(order, context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(DeliveryTask task, BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.courierColor.withOpacity(0.1),
          child: Icon(Icons.school, color: AppColors.courierColor),
        ),
        title: Text(task.schoolName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${task.totalBooks} كتاب'),
            Text('كود: ${task.receiptCode}'),
            Text('الحالة: ${task.statusInArabic}'),
          ],
        ),
        trailing: _buildTaskActions(task, context),
        onTap: () => _showTaskDetails(task, context),
      ),
    );
  }

  Widget _buildOrderCard(Order order, BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.courierColor.withOpacity(0.1),
          child: Icon(Icons.school, color: AppColors.courierColor),
        ),
        title: Text(order.schoolName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${order.totalBooks} كتاب'),
            Text('كود: ${order.receiptCode}'),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            final courierService = Provider.of<CourierService>(context, listen: false);
            courierService.addDeliveryTask(order);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QrScannerScreen(),
              ),
            );
          },
          child: Text('استلام المهمة'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.courierColor,
          ),
        ),
        onTap: () => _showOrderDetails(order, context),
      ),
    );
  }

  Widget _buildTaskActions(DeliveryTask task, BuildContext context) {
    if (task.status == 'assigned') {
      return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QrScannerScreen(),
            ),
          );
        },
        child: Text('تسليم'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _getTaskStatusColor(task.status),
        ),
      );
    }
    return _buildStatusChip(task.status);
  }

  Widget _buildStatusChip(String status) {
    final statusInfo = _getStatusInfo(status);
    return Chip(
      label: Text(statusInfo['text']),
      backgroundColor: statusInfo['color'].withOpacity(0.1),
      labelStyle: TextStyle(color: statusInfo['color']),
    );
  }

  Widget _buildEmptyState(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list_alt, size: 80, color: Colors.grey[300]),
          SizedBox(height: 16),
          Text('لا توجد $title', style: AppStyles.heading3),
          SizedBox(height: 8),
          Text('سيظهر هنا عندما تتوفر مهام جديدة',
              style: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  void _showTaskDetails(DeliveryTask task, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل المهمة'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailItem('المدرسة', task.schoolName),
              _buildDetailItem('كود الاستلام', task.receiptCode),
              _buildDetailItem('عدد الكتب', '${task.totalBooks} كتاب'),
              _buildDetailItem('الحالة', task.statusInArabic),
              _buildDetailItem('تاريخ التعيين', _formatDate(task.assignedDate)),
              if (task.deliveryDate != null)
                _buildDetailItem('تاريخ التسليم', _formatDate(task.deliveryDate!)),
            ],
          ),
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

  void _showOrderDetails(Order order, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل الطلب'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailItem('المدرسة', order.schoolName),
              _buildDetailItem('كود الاستلام', order.receiptCode!),
              _buildDetailItem('عدد الكتب', '${order.totalBooks} كتاب'),
              _buildDetailItem('الحالة', _getStatusInfo(order.status)['text']),
            ],
          ),
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

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'approved':
        return {'text': 'مقبول', 'color': AppColors.successColor};
      case 'assigned':
        return {'text': 'مكلف', 'color': AppColors.courierColor};
      case 'in_transit':
        return {'text': 'قيد التوصيل', 'color': AppColors.warningColor};
      case 'delivered':
        return {'text': 'تم التسليم', 'color': AppColors.successColor};
      case 'cancelled':
        return {'text': 'ملغى', 'color': AppColors.errorColor};
      default:
        return {'text': status, 'color': Colors.grey};
    }
  }

  Color _getTaskStatusColor(String status) {
    switch (status) {
      case 'assigned': return AppColors.courierColor;
      case 'in_transit': return AppColors.warningColor;
      case 'delivered': return AppColors.successColor;
      case 'cancelled': return AppColors.errorColor;
      default: return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}