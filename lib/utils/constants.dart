import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF9C27B0);
  static const Color accentColor = Color(0xFF00BFA6);

  // ألوان الأدوار
  static const Color schoolColor = Color(0xFFB39DDB); // بنفسجي فاتح
  static const Color governorateColor = Color(0xFF3498DB);
  static const Color courierColor = Color(0xFF2196F3); // أزرق
  static const Color ministryColor = Color(0xFF2ECC71);

  // ألوان الحالة
  static const Color successColor = Color(0xFF27AE60);
  static const Color warningColor = Color(0xFFE67E22);
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color infoColor = Color(0xFF3498DB);

  // ألوان الخلفية والنص
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color borderColor = Color(0xFFECF0F1);
}

class AppStyles {
  // الأنماط النصية
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  // أنماط الأزرار
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryColor,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  static ButtonStyle secondaryButton = ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: AppColors.primaryColor,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: AppColors.primaryColor),
    ),
  );
}

class AppDecorations {
  // تزيين الصناديقة 
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.cardColor,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration inputDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.borderColor),
  );
}

class AppStrings {
  static const String appName = 'نظام توزيع الكتب';
  static const String welcome = 'مرحباً بك في نظام توزيع الكتب';
  static const String loginDesc = 'سجل الدخول للوصول إلى حسابك';
}

class AppConfig {
  // API base URL can be provided at build/run time via --dart-define=API_BASE_URL
  // Examples:
  //  - Run on Windows (backend on same machine):
  //      flutter run -d windows --dart-define=API_BASE_URL=http://localhost:8000
  //  - Run on Android emulator (emulator accesses host via 10.0.2.2):
  //      flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8000
  //  - Run on a physical Android device (use your PC LAN IP):
  //      flutter run -d <deviceId> --dart-define=API_BASE_URL=http://192.168.1.100:8000
  //  - Production / hosted backend:
  //      flutter build apk --dart-define=API_BASE_URL=https://api.yourdomain.com
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // Production backend (with explicit port) is the default; override via --dart-define as needed
    defaultValue: 'http://45.77.65.134:8000',
  );

}