import 'book_model.dart';

class Order {
  final String id;
  final String schoolId;
  final String schoolName;
  final String governorateId;
  final List<Book> books;
  String status;
  final DateTime requestDate;
  late final DateTime? approvalDate;
  late final double approvedPercentage;
  String? rejectionReason;
  late final String? receiptCode;

  Order({
    required this.id,
    required this.schoolId,
    required this.schoolName,
    required this.governorateId,
    required this.books,
    required this.status,
    required this.requestDate,
    this.approvalDate,
    this.approvedPercentage = 0.0,
    this.rejectionReason,
    this.receiptCode,
  });

  // دالة copyWith المضافة
  Order copyWith({
    String? id,
    String? schoolId,
    String? schoolName,
    String? governorateId,
    List<Book>? books,
    String? status,
    DateTime? requestDate,
    DateTime? approvalDate,
    double? approvedPercentage,
    String? rejectionReason,
    String? receiptCode,
  }) {
    return Order(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      schoolName: schoolName ?? this.schoolName,
      governorateId: governorateId ?? this.governorateId,
      books: books ?? List.from(this.books),
      status: status ?? this.status,
      requestDate: requestDate ?? this.requestDate,
      approvalDate: approvalDate ?? this.approvalDate,
      approvedPercentage: approvedPercentage ?? this.approvedPercentage,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      receiptCode: receiptCode ?? this.receiptCode,
    );
  }

  String get statusInArabic {
    switch (status) {
      case 'pending': return 'قيد المراجعة';
      case 'approved': return 'معتمد';
      case 'rejected': return 'مرفوض';
      case 'delivered': return 'تم التسليم';
      default: return status;
    }
  }

  int get totalBooks {
    return books.fold(0, (sum, book) => sum + book.quantity);
  }
}