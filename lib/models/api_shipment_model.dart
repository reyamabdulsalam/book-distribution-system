/// نموذج الشحنة المحدث - متوافق 100% مع API
class ApiShipment {
  final int id;
  final String trackingCode;
  final String? type; // shipment_type: "province_to_school" أو "ministry_to_province"
  final String? fromMinistryName;
  final String? fromLocation; // اسم مكان الإرسال (from)
  final String? toProvinceName;
  final String? toSchoolName;
  final String? toLocation; // اسم مكان الوصول (to)
  final String status;
  final String? statusDisplay;
  final List<ShipmentBook> books;
  final int? booksCountFromApi; // في حال أرسله الـ API مباشرة
  final String? qrCodeImage; // base64 image
  final String? qrToken; // QR token for scanning
  final DateTime? qrExpiresAt;
  final String? qrStatus; // active, expired, used
  final bool? qrUsed;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? startedDeliveryAt;
  final DateTime? deliveredAt;
  final String? assignedCourierName;
  final int? assignedCourierId;
  final String? courierPhone;
  final String? recipientName;
  final String? deliveryNotes;
  final double? latitude;
  final double? longitude;
  final String? proofPhotoUrl;
  final String? signatureUrl;

  ApiShipment({
    required this.id,
    required this.trackingCode,
    this.type,
    this.fromMinistryName,
    this.fromLocation, // اسم مكان الإرسال (from)
    this.toProvinceName,
    this.toSchoolName,
    this.toLocation, // اسم مكان الوصول (to)
    required this.status,
    this.statusDisplay,
    required this.books,
    this.booksCountFromApi, // في حال أرسله الـ API مباشرة
    this.qrCodeImage,
    this.qrToken,
    this.qrExpiresAt,
    this.qrStatus,
    this.qrUsed,
    required this.createdAt,
    this.updatedAt,
    this.startedDeliveryAt,
    this.deliveredAt,
    this.assignedCourierName,
    this.assignedCourierId,
    this.courierPhone,
    this.recipientName,
    this.deliveryNotes,
    this.latitude,
    this.longitude,
    this.proofPhotoUrl,
    this.signatureUrl,
  });
  factory ApiShipment.fromJson(Map<String, dynamic> json) {
    // Parse QR code object if exists
    final qrCode = json['qr_code'] as Map<String, dynamic>?;
    // Parse courier object if exists
    final courier = json['courier'] as Map<String, dynamic>?;
    // Parse delivery_info object if exists
    final deliveryInfo = json['delivery_info'] as Map<String, dynamic>?;
    // Parse timestamps object if exists
    final timestamps = json['timestamps'] as Map<String, dynamic>?;
    
    return ApiShipment(
      id: json['id'],
      trackingCode: json['tracking_code'] ?? '',
      type: json['type'] ?? json['shipment_type'],
      fromMinistryName: json['from_ministry_name'],
      fromLocation: json['from_location'] ?? json['from'],
      toProvinceName: json['to_province_name'],
      toSchoolName: json['to_school_name'],
      toLocation: json['to_location'] ?? json['to'],
      status: json['status'] ?? 'pending',
      statusDisplay: json['status_display'],
      books: (json['books'] as List?)
          ?.map((b) => ShipmentBook.fromJson(b))
          .toList() ??
        [],
      booksCountFromApi: json['books_count'],
      qrCodeImage: qrCode?['image'],
      qrToken: qrCode?['token'],
      qrExpiresAt: qrCode?['expires_at'] != null
        ? DateTime.parse(qrCode!['expires_at'])
        : null,
      qrStatus: qrCode?['status'],
      qrUsed: qrCode?['used'],
      createdAt: timestamps?['created_at'] != null 
        ? DateTime.parse(timestamps!['created_at'])
        : DateTime.parse(json['created_at']),
      updatedAt: timestamps?['updated_at'] != null
        ? DateTime.parse(timestamps!['updated_at'])
        : (json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null),
      startedDeliveryAt: json['started_delivery_at'] != null
        ? DateTime.parse(json['started_delivery_at'])
        : null,
      deliveredAt: deliveryInfo?['delivered_at'] != null
        ? DateTime.parse(deliveryInfo!['delivered_at'])
        : (json['delivered_at'] != null ? DateTime.parse(json['delivered_at']) : null),
      assignedCourierName: courier?['name'] ?? json['assigned_courier_name'],
      assignedCourierId: courier?['id'],
      courierPhone: courier?['phone'],
      recipientName: deliveryInfo?['recipient_name'] ?? json['recipient_name'],
      deliveryNotes: deliveryInfo?['notes'] ?? json['delivery_notes'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      proofPhotoUrl: json['proof_photo_url'],
      signatureUrl: json['signature_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tracking_code': trackingCode,
      'status': status,
      'books': books.map((b) => b.toJson()).toList(),
      if (recipientName != null) 'recipient_name': recipientName,
      if (deliveryNotes != null) 'delivery_notes': deliveryNotes,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }

  String get statusInArabic {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'assigned':
        return 'تم الإسناد';
      case 'out_for_delivery':
        return 'خارج للتوصيل';
      case 'delivered':
        return 'تم التسليم';
      case 'confirmed':
        return 'مؤكد';
      case 'canceled':
        return 'ملغي';
      default:
        return status;
    }
  }

  bool get isQrValid {
    if (qrExpiresAt == null) return false;
    return DateTime.now().isBefore(qrExpiresAt!);
  }

  int get totalBooks {
    return booksCountFromApi ?? books.fold<int>(0, (sum, book) => sum + book.quantity);
  }

  bool get canStartDelivery {
    return status == 'assigned';
  }

  bool get isOutForDelivery {
    return status == 'out_for_delivery';
  }

  bool get isDelivered {
    return status == 'delivered' || status == 'confirmed';
  }
  
  // تحديد نوع الشحنة بالعربي
  String get typeInArabic {
    if (type == null) return 'غير محدد';
    switch (type) {
      case 'province_to_school':
        return 'محافظة → مدرسة';
      case 'ministry_to_province':
        return 'وزارة → محافظة';
      default:
        return type!;
    }
  }
}

/// نموذج كتاب في الشحنة
class ShipmentBook {
  final int bookId;
  final String? bookName;
  final String? bookTitle; // من الـ API الجديد
  final String? bookSubject;
  final String? bookGrade;
  final int quantity;
  final String term; // first, second

  ShipmentBook({
    required this.bookId,
    this.bookName,
    this.bookTitle,
    this.bookSubject,
    this.bookGrade,
    required this.quantity,
    required this.term,
  });

  factory ShipmentBook.fromJson(Map<String, dynamic> json) {
    return ShipmentBook(
      bookId: json['book_id'],
      bookName: json['book_name'] ?? json['book_title'],
      bookTitle: json['book_title'],
      bookSubject: json['book_subject'],
      bookGrade: json['book_grade'],
      quantity: json['quantity'],
      term: json['term'] ?? 'first',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book_id': bookId,
      'quantity': quantity,
      'term': term,
    };
  }

  String get termInArabic {
    return term == 'first' ? 'الفصل الأول' : 'الفصل الثاني';
  }
}

/// استجابة API للشحنات (مع pagination)
class ShipmentListResponse {
  final int count;
  final List<ApiShipment> results;
  final String? next;
  final String? previous;

  ShipmentListResponse({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  factory ShipmentListResponse.fromJson(Map<String, dynamic> json) {
    return ShipmentListResponse(
      count: json['count'] ?? 0,
      results: (json['results'] as List?)
              ?.map((s) => ApiShipment.fromJson(s))
              .toList() ??
          [],
      next: json['next'],
      previous: json['previous'],
    );
  }
}

/// استجابة API لمسح QR
/// استجابة API لمسح QR Code - متوافقة مع توثيق Backend
class QrScanResponse {
  final bool success;
  final String? message;
  final String? error;
  final ApiShipment? shipment;
  final Map<String, dynamic>? deliveryDetails;
  final String? reason;

  QrScanResponse({
    required this.success,
    this.message,
    this.error,
    this.shipment,
    this.deliveryDetails,
    this.reason,
  });

  factory QrScanResponse.fromJson(Map<String, dynamic> json) {
    return QrScanResponse(
      success: json['success'] ?? false,
      message: json['message'],
      error: json['error'],
      shipment: json['shipment'] != null
          ? ApiShipment.fromJson(json['shipment'])
          : null,
      deliveryDetails: json['delivery_details'],
      reason: json['reason'],
    );
  }
}

/// استجابة API للتحقق من QR
class QrVerifyResponse {
  final bool valid;
  final int? shipmentId;
  final DateTime? expiresAt;
  final ApiShipment? shipment;

  QrVerifyResponse({
    required this.valid,
    this.shipmentId,
    this.expiresAt,
    this.shipment,
  });

  factory QrVerifyResponse.fromJson(Map<String, dynamic> json) {
    return QrVerifyResponse(
      valid: json['valid'] ?? false,
      shipmentId: json['shipment_id'],
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      shipment: json['shipment'] != null
          ? ApiShipment.fromJson(json['shipment'])
          : null,
    );
  }
}

/// نموذج إحصائيات أداء المندوب
class DriverPerformance {
  final int totalDeliveries;
  final int completedToday;
  final int thisMonth;
  final String averageDeliveryTime;
  final double successRate;
  final List<ApiShipment> recentShipments;

  DriverPerformance({
    required this.totalDeliveries,
    required this.completedToday,
    required this.thisMonth,
    required this.averageDeliveryTime,
    required this.successRate,
    required this.recentShipments,
  });

  factory DriverPerformance.fromJson(Map<String, dynamic> json) {
    return DriverPerformance(
      totalDeliveries: json['total_deliveries'] ?? 0,
      completedToday: json['completed_today'] ?? 0,
      thisMonth: json['this_month'] ?? 0,
      averageDeliveryTime: json['average_delivery_time'] ?? '0',
      successRate: (json['success_rate'] ?? 0).toDouble(),
      recentShipments: (json['recent_shipments'] as List?)
              ?.map((s) => ApiShipment.fromJson(s))
              .toList() ??
          [],
    );
  }
}

/// نموذج الموقع الجغرافي
class LocationData {
  final double latitude;
  final double longitude;
  final DateTime? updatedAt;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}
