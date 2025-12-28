
/// نموذج طلب الكتب من المدرسة - متوافق مع Backend SchoolRequest
class SchoolRequest {
  final int? id;
  final int schoolId;
  final String? schoolName;
  final List<SchoolRequestItem> items;
  final String status; // pending, approved, rejected, delivered
  final DateTime requestDate;
  final DateTime? approvalDate;
  final DateTime? deliveryDate;
  final String? notes;
  final String? rejectionReason;
  final String? receiptCode;

  SchoolRequest({
    this.id,
    required this.schoolId,
    this.schoolName,
    required this.items,
    this.status = 'pending',
    required this.requestDate,
    this.approvalDate,
    this.deliveryDate,
    this.notes,
    this.rejectionReason,
    this.receiptCode,
  });

  factory SchoolRequest.fromJson(Map<String, dynamic> json) {
    // الباك إند يرسل items_readonly بدلاً من items
    final itemsList = (json['items_readonly'] ?? json['items']) as List? ?? [];
    return SchoolRequest(
      id: json['id'],
      schoolId: json['school'] is int ? json['school'] : (json['school_id'] ?? 0),
      schoolName: json['school_name'] ?? json['schoolName'] ?? 
                  (json['school_detail'] != null ? json['school_detail']['name'] : null),
      items: itemsList.map((item) => SchoolRequestItem.fromJson(item)).toList(),
      status: json['status'] ?? 'pending',
      requestDate: DateTime.parse(json['request_date'] ?? json['created_at'] ?? DateTime.now().toIso8601String()),
      approvalDate: json['approval_date'] != null ? DateTime.parse(json['approval_date']) : null,
      deliveryDate: json['delivery_date'] != null ? DateTime.parse(json['delivery_date']) : null,
      notes: json['notes'],
      rejectionReason: json['rejection_reason'] ?? json['reason_rejected'],
      receiptCode: json['receipt_code'] ?? json['receiptCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'school': schoolId,
      'items': items.map((item) => item.toJson()).toList(),
      'status': status,
      'request_date': requestDate.toIso8601String(),
      if (approvalDate != null) 'approval_date': approvalDate!.toIso8601String(),
      if (deliveryDate != null) 'delivery_date': deliveryDate!.toIso8601String(),
      if (notes != null) 'notes': notes,
      if (rejectionReason != null) 'rejection_reason': rejectionReason,
      if (receiptCode != null) 'receipt_code': receiptCode,
    };
  }

  String get statusInArabic {
    switch (status) {
      case 'draft':
        return 'مسودة';
      case 'submitted':
        return 'مرسل للمحافظة';
      case 'approved':
        return 'مقبول من المحافظة';
      case 'rejected':
        return 'مرفوض من المحافظة';
      case 'fulfilled':
        return 'تم التوريد للمدرسة';
      case 'cancelled':
        return 'ملغى';
      case 'delivered':
        return 'تم التسليم';
      default:
        return status;
    }
  }

  int get totalBooks {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  SchoolRequest copyWith({
    int? id,
    int? schoolId,
    String? schoolName,
    List<SchoolRequestItem>? items,
    String? status,
    DateTime? requestDate,
    DateTime? approvalDate,
    DateTime? deliveryDate,
    String? notes,
    String? rejectionReason,
    String? receiptCode,
  }) {
    return SchoolRequest(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      schoolName: schoolName ?? this.schoolName,
      items: items ?? this.items,
      status: status ?? this.status,
      requestDate: requestDate ?? this.requestDate,
      approvalDate: approvalDate ?? this.approvalDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      notes: notes ?? this.notes,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      receiptCode: receiptCode ?? this.receiptCode,
    );
  }
}

/// عنصر في طلب الكتب
class SchoolRequestItem {
  final int? id;
  final int? bookId;
  final String? bookTitle;
  final String? subject;
  final String? grade;
  final int quantity;
  final String term; // first, second

  SchoolRequestItem({
    this.id,
    this.bookId,
    this.bookTitle,
    this.subject,
    this.grade,
    required this.quantity,
    this.term = 'first',
  });

  factory SchoolRequestItem.fromJson(Map<String, dynamic> json) {
    return SchoolRequestItem(
      id: json['id'],
      bookId: json['book'] is int ? json['book'] : (json['book_id']),
      bookTitle: json['book_title'] ?? json['title'] ?? 
                 (json['book_detail'] != null ? json['book_detail']['title'] : null),
      subject: json['subject'],
      grade: json['grade'],
      quantity: json['quantity'] ?? 0,
      term: json['term'] ?? 'first',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (bookId != null) 'book': bookId,
      if (bookTitle != null) 'book_title': bookTitle,
      if (subject != null) 'subject': subject,
      if (grade != null) 'grade': grade,
      'quantity': quantity,
      'term': term,
    };
  }

  String get termInArabic {
    return term == 'first' ? 'الفصل الأول' : 'الفصل الثاني';
  }
}
