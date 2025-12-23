/// نموذج المستخدم - متوافق مع API
class User {
  final int id;
  final String username;
  final String fullName;
  final String role; // ministry_driver, province_driver, school_staff
  final String? schoolId;
  final String? schoolName;

  User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    this.schoolId,
    this.schoolName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // استخراج school ID من عدة مصادر محتملة
    String? extractedSchoolId;
    String? extractedSchoolName;
    
    if (json['school'] != null) {
      if (json['school'] is Map) {
        extractedSchoolId = json['school']['id']?.toString();
        extractedSchoolName = json['school']['name']?.toString();
      } else {
        extractedSchoolId = json['school'].toString();
      }
    } else if (json['school_id'] != null) {
      extractedSchoolId = json['school_id'].toString();
    } else if (json['schoolId'] != null) {
      extractedSchoolId = json['schoolId'].toString();
    }

    if (json['school_name'] != null) {
      extractedSchoolName = json['school_name'].toString();
    }
    
    return User(
      id: json['id'] ?? json['pk'] ?? 0,
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? json['name'] ?? json['username'] ?? 'مستخدم',
      role: json['role'] ?? json['user_role'] ?? json['user_type'] ?? 'school_staff',
      schoolId: extractedSchoolId,
      schoolName: extractedSchoolName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'role': role,
      if (schoolId != null) 'school_id': schoolId,
      if (schoolName != null) 'school_name': schoolName,
    };
  }

  String get roleInArabic {
    switch (role) {
      case 'ministry_driver':
        return 'مندوب الوزارة';
      case 'province_driver':
        return 'مندوب المحافظة';
      case 'school_staff':
        return 'موظف مدرسة';
      default:
        return role;
    }
  }

  bool get isDriver {
    return role == 'ministry_driver' || role == 'province_driver';
  }

  bool get isSchoolStaff {
    return role == 'school_staff';
  }
}

/// استجابة تسجيل الدخول من API
class LoginResponse {
  final bool success;
  final String access;
  final String refresh;
  final User user;

  LoginResponse({
    required this.success,
    required this.access,
    required this.refresh,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? true,
      access: json['access'] ?? json['token'] ?? '',
      refresh: json['refresh'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}