class Courier {
  final String id;
  final String name;
  final String governorateId;
  final int completedDeliveries;
  final double rating;
  final String phoneNumber;
  late final bool isAvailable;

  Courier({
    required this.id,
    required this.name,
    required this.governorateId,
    this.completedDeliveries = 0,
    this.rating = 5.0,
    required this.phoneNumber,
    this.isAvailable = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'governorateId': governorateId,
      'completedDeliveries': completedDeliveries,
      'rating': rating,
      'phoneNumber': phoneNumber,
      'isAvailable': isAvailable,
    };
  }

  static Courier fromJson(Map<String, dynamic> json) {
    return Courier(
      id: json['id'],
      name: json['name'],
      governorateId: json['governorateId'],
      completedDeliveries: json['completedDeliveries'],
      rating: json['rating'],
      phoneNumber: json['phoneNumber'],
      isAvailable: json['isAvailable'],
    );
  }
}

class DeliveryTask {
  final String id;
  final String orderId;
  final String schoolId;
  final String schoolName;
  late final String courierId;
  final DateTime assignedDate;
  DateTime? deliveryDate;
  String status;
  final String receiptCode;
  final int totalBooks;

  DeliveryTask({
    required this.id,
    required this.orderId,
    required this.schoolId,
    required this.schoolName,
    required this.courierId,
    required this.assignedDate,
    this.deliveryDate,
    required this.status,
    required this.receiptCode,
    required this.totalBooks,
  });

  String get statusInArabic {
    switch (status) {
      case 'assigned': return 'مكلف';
      case 'in_transit': return 'قيد التوصيل';
      case 'delivered': return 'تم التسليم';
      case 'cancelled': return 'ملغى';
      default: return status;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'schoolId': schoolId,
      'schoolName': schoolName,
      'courierId': courierId,
      'assignedDate': assignedDate.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'status': status,
      'receiptCode': receiptCode,
      'totalBooks': totalBooks,
    };
  }

  static DeliveryTask fromJson(Map<String, dynamic> json) {
    return DeliveryTask(
      id: json['id'],
      orderId: json['orderId'],
      schoolId: json['schoolId'],
      schoolName: json['schoolName'],
      courierId: json['courierId'],
      assignedDate: DateTime.parse(json['assignedDate']),
      deliveryDate: json['deliveryDate'] != null ? DateTime.parse(json['deliveryDate']) : null,
      status: json['status'],
      receiptCode: json['receiptCode'],
      totalBooks: json['totalBooks'],
    );
  }
}