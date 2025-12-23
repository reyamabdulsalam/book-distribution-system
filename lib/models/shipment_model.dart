/// نموذج الشحنة - متوافق مع Backend Shipment
class Shipment {
  final int? id;
  final int? fromMinistry;
  final String? fromMinistryName;
  final int? toProvince;
  final String? toProvinceName;
  final int? assignedCourier;
  final String? assignedCourierName;
  final String status; // pending, assigned, in_transit, delivered
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final String? notes;
  final List<ShipmentBook>? books;

  Shipment({
    this.id,
    this.fromMinistry,
    this.fromMinistryName,
    this.toProvince,
    this.toProvinceName,
    this.assignedCourier,
    this.assignedCourierName,
    this.status = 'pending',
    required this.createdAt,
    this.deliveredAt,
    this.notes,
    this.books,
  });

  factory Shipment.fromJson(Map<String, dynamic> json) {
    final booksList = json['books'] as List? ?? [];
    return Shipment(
      id: json['id'],
      fromMinistry: json['from_ministry'],
      fromMinistryName: json['from_ministry_name'],
      toProvince: json['to_province'],
      toProvinceName: json['to_province_name'],
      assignedCourier: json['assigned_courier'],
      assignedCourierName: json['assigned_courier_name'],
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      deliveredAt: json['delivered_at'] != null ? DateTime.parse(json['delivered_at']) : null,
      notes: json['notes'],
      books: booksList.map((b) => ShipmentBook.fromJson(b)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (fromMinistry != null) 'from_ministry': fromMinistry,
      if (toProvince != null) 'to_province': toProvince,
      if (assignedCourier != null) 'assigned_courier': assignedCourier,
      'status': status,
      if (notes != null) 'notes': notes,
      if (books != null) 'books': books!.map((b) => b.toJson()).toList(),
    };
  }

  String get statusInArabic {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'assigned':
        return 'مُسندة';
      case 'in_transit':
        return 'في الطريق';
      case 'delivered':
        return 'تم التسليم';
      default:
        return status;
    }
  }

  int get totalBooks {
    return books?.fold<int>(0, (int sum, ShipmentBook book) => sum + book.quantity) ?? 0;
  }
}

class ShipmentBook {
  final int? id;
  final int bookId;
  final String? bookTitle;
  final int quantity;
  final String? term;

  ShipmentBook({
    this.id,
    required this.bookId,
    this.bookTitle,
    required this.quantity,
    this.term,
  });

  factory ShipmentBook.fromJson(Map<String, dynamic> json) {
    return ShipmentBook(
      id: json['id'],
      bookId: json['book'] ?? json['book_id'] ?? 0,
      bookTitle: json['book_title'] ?? json['title'],
      quantity: json['quantity'] ?? 0,
      term: json['term'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book_id': bookId,
      'quantity': quantity,
      if (term != null) 'term': term,
    };
  }
}
