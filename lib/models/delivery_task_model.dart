class DeliveryTask {
  final String id;
  final String orderId;
  final String schoolId;
  final String schoolName;
  final String courierId;
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

  DeliveryTask copyWith({
    String? id,
    String? orderId,
    String? schoolId,
    String? schoolName,
    String? courierId,
    DateTime? assignedDate,
    DateTime? deliveryDate,
    String? status,
    String? receiptCode,
    int? totalBooks,
  }) {
    return DeliveryTask(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      schoolId: schoolId ?? this.schoolId,
      schoolName: schoolName ?? this.schoolName,
      courierId: courierId ?? this.courierId,
      assignedDate: assignedDate ?? this.assignedDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      status: status ?? this.status,
      receiptCode: receiptCode ?? this.receiptCode,
      totalBooks: totalBooks ?? this.totalBooks,
    );
  }
}