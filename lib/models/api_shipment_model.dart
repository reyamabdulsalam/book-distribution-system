/// نموذج الشحنة المحدث - متوافق 100% مع API
class ApiShipment {
  final int id;
  final String trackingCode;
  final String? fromMinistryName;
  final String? toProvinceName;
  final String? toSchoolName;
  final String status;
  final List<ShipmentBook> books;
  final String? qrCodeImage; // base64 image
  final DateTime? qrExpiresAt;
  final DateTime createdAt;
  final DateTime? startedDeliveryAt;
  final DateTime? deliveredAt;
  final String? assignedCourierName;
  final String? recipientName;
  final String? deliveryNotes;
  final double? latitude;
  final double? longitude;
  final String? proofPhotoUrl;
  final String? signatureUrl;

  ApiShipment({
    required this.id,
    required this.trackingCode,
    this.fromMinistryName,
    this.toProvinceName,
    this.toSchoolName,
    required this.status,
    required this.books,
    this.qrCodeImage,
    this.qrExpiresAt,
    required this.createdAt,
    this.startedDeliveryAt,
    this.deliveredAt,
    this.assignedCourierName,
    this.recipientName,
    this.deliveryNotes,
    this.latitude,
    this.longitude,
    this.proofPhotoUrl,
    this.signatureUrl,
  });

  factory ApiShipment.fromJson(Map<String, dynamic> json) {
    return ApiShipment(
      id: json['id'],
      trackingCode: json['tracking_code'] ?? '',
      fromMinistryName: json['from_ministry_name'],
      toProvinceName: json['to_province_name'],
      toSchoolName: json['to_school_name'],
      status: json['status'] ?? 'pending',
      books: (json['books'] as List?)
              ?.map((b) => ShipmentBook.fromJson(b))
              .toList() ??
          [],
      qrCodeImage: json['qr_code_image'],
      qrExpiresAt: json['qr_expires_at'] != null
          ? DateTime.parse(json['qr_expires_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      startedDeliveryAt: json['started_delivery_at'] != null
          ? DateTime.parse(json['started_delivery_at'])
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'])
          : null,
      assignedCourierName: json['assigned_courier_name'],
      recipientName: json['recipient_name'],
      deliveryNotes: json['delivery_notes'],
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

  int get totalBooks {
    return books.fold<int>(0, (sum, book) => sum + book.quantity);
  }

  bool get isQrValid {
    if (qrExpiresAt == null) return false;
    return DateTime.now().isBefore(qrExpiresAt!);
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
}

/// نموذج كتاب في الشحنة
class ShipmentBook {
  final int bookId;
  final String? bookName;
  final int quantity;
  final String term; // first, second

  ShipmentBook({
    required this.bookId,
    this.bookName,
    required this.quantity,
    required this.term,
  });

  factory ShipmentBook.fromJson(Map<String, dynamic> json) {
    return ShipmentBook(
      bookId: json['book_id'],
      bookName: json['book_name'],
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
class QrScanResponse {
  final bool success;
  final String? message;
  final String? error;
  final ApiShipment? shipment;
  final DateTime? scannedAt;
  final String? reason;

  QrScanResponse({
    required this.success,
    this.message,
    this.error,
    this.shipment,
    this.scannedAt,
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
      scannedAt: json['scanned_at'] != null
          ? DateTime.parse(json['scanned_at'])
          : null,
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
