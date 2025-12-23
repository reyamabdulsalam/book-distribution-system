import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../models/courier_model.dart';

class CourierService with ChangeNotifier {
  List<DeliveryTask> _deliveryTasks = [];
  final List<Courier> _couriers = [
    Courier(
      id: 'courier_001',
      name: 'المندوب أحمد',
      governorateId: 'gov_1',
      completedDeliveries: 15,
      rating: 4.8,
      phoneNumber: '+967712345678',
      isAvailable: true,
    ),
    Courier(
      id: 'courier_002',
      name: 'المندوب محمد',
      governorateId: 'gov_1',
      completedDeliveries: 8,
      rating: 4.5,
      phoneNumber: '+967712345679',
      isAvailable: true,
    ),
  ];

  List<DeliveryTask> get deliveryTasks => _deliveryTasks;
  List<Courier> get couriers => _couriers;

  Courier get currentCourier => _couriers.firstWhere((c) => c.id == 'courier_001');

  void addDeliveryTask(Order order) {
    final task = DeliveryTask(
      id: 'TASK-${DateTime.now().millisecondsSinceEpoch}',
      orderId: order.id,
      schoolId: order.schoolId,
      schoolName: order.schoolName,
      courierId: currentCourier.id,
      assignedDate: DateTime.now(),
      status: 'assigned',
      receiptCode: order.receiptCode!,
      totalBooks: order.totalBooks,
    );

    _deliveryTasks.add(task);
    notifyListeners();
  }

  void updateTaskStatus(String taskId, String status) {
    final taskIndex = _deliveryTasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      _deliveryTasks[taskIndex].status = status;
      if (status == 'delivered') {
        _deliveryTasks[taskIndex].deliveryDate = DateTime.now();
      }
      notifyListeners();
    }
  }

  void completeDelivery(String orderId) {
    final taskIndex = _deliveryTasks.indexWhere((task) => task.orderId == orderId);
    if (taskIndex != -1) {
      _deliveryTasks[taskIndex].status = 'delivered';
      _deliveryTasks[taskIndex].deliveryDate = DateTime.now();
      notifyListeners();
    }
  }

  List<DeliveryTask> getPendingDeliveries() {
    return _deliveryTasks.where((task) => task.status != 'delivered').toList();
  }

  List<DeliveryTask> getCompletedDeliveries() {
    return _deliveryTasks.where((task) => task.status == 'delivered').toList();
  }

  List<DeliveryTask> getCourierTasks(String courierId) {
    return _deliveryTasks.where((task) => task.courierId == courierId).toList();
  }

  void assignTaskToCourier(String taskId, String courierId) {
    final taskIndex = _deliveryTasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      _deliveryTasks[taskIndex].courierId = courierId;
      notifyListeners();
    }
  }

  void updateCourierAvailability(String courierId, bool isAvailable) {
    final courierIndex = _couriers.indexWhere((c) => c.id == courierId);
    if (courierIndex != -1) {
      _couriers[courierIndex].isAvailable = isAvailable;
      notifyListeners();
    }
  }
}