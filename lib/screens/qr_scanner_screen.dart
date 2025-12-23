import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../services/school_delivery_service.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

/// شاشة مسح QR Code - محدثة ومتوافقة مع API
class QrScannerScreen extends StatefulWidget {
  @override
  _QrScannerScreenState createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final _qrController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _qrController.dispose();
    _recipientNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return null;
    }
  }

  Future<void> _scanAndConfirm() async {
    if (_qrController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء إدخال رمز QR'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final position = await _getCurrentLocation();

      // استخدام API الموحد لمسح QR
      final schoolService =
          Provider.of<SchoolDeliveryService>(context, listen: false);

      final result = await schoolService.scanQrCodeUnified(
        token: _qrController.text.trim(),
        recipientName: _recipientNameController.text.isNotEmpty
            ? _recipientNameController.text
            : authService.currentUser?.fullName,
        notes: _notesController.text,
        latitude: position?.latitude,
        longitude: position?.longitude,
      );

      if (result.success) {
        // نجحت العملية
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                SizedBox(width: 12),
                Text('تم بنجاح'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.message ?? 'تم تأكيد الاستلام بنجاح'),
                SizedBox(height: 12),
                if (result.shipment != null) ...[
                  Text('رقم الشحنة: ${result.shipment!.trackingCode}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('المدرسة: ${result.shipment!.toSchoolName ?? "-"}'),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // إغلاق الديالوج
                  Navigator.pop(context); // الرجوع للشاشة السابقة
                },
                child: Text('حسناً'),
              ),
            ],
          ),
        );
      } else {
        // فشلت العملية
        _showErrorDialog(result.error ?? 'فشل في مسح الرمز', result.reason);
      }
    } catch (e) {
      _showErrorDialog('حدث خطأ: ${e.toString()}', null);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showErrorDialog(String error, String? reason) {
    String detailedMessage = error;
    IconData icon = Icons.error;
    Color color = Colors.red;

    if (reason != null) {
      switch (reason) {
        case 'expired':
          detailedMessage = 'الرمز منتهي الصلاحية\n\nالرجاء طلب رمز جديد';
          icon = Icons.access_time;
          color = Colors.orange;
          break;
        case 'already_used':
          detailedMessage = 'تم استخدام هذا الرمز مسبقاً';
          icon = Icons.warning;
          break;
        case 'invalid':
          detailedMessage = 'الرمز غير صالح\n\nالرجاء التحقق من الرمز';
          icon = Icons.cancel;
          break;
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(width: 12),
            Text('خطأ'),
          ],
        ),
        content: Text(detailedMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('مسح QR Code',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // أيقونة QR
            Center(
              child: Icon(Icons.qr_code_scanner,
                  size: 100, color: AppColors.primaryColor),
            ),
            SizedBox(height: 24),

            // رسالة توضيحية
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 32),
                    SizedBox(height: 8),
                    Text(
                      'امسح رمز QR الموجود على الشحنة\nأو أدخل الرمز يدوياً',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.blue[800]),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // حقل إدخال رمز QR
            TextField(
              controller: _qrController,
              decoration: InputDecoration(
                labelText: 'رمز QR',
                hintText: 'أدخل الرمز أو امسحه',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () => _qrController.clear(),
                ),
              ),
            ),
            SizedBox(height: 16),

            // اسم المستلم
            TextField(
              controller: _recipientNameController,
              decoration: InputDecoration(
                labelText: 'اسم المستلم',
                hintText: authService.currentUser?.fullName ?? 'اسمك',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 16),

            // ملاحظات
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'ملاحظات (اختياري)',
                hintText: 'أضف ملاحظات حول الاستلام',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
            ),
            SizedBox(height: 24),

            // زر مسح وتأكيد
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _scanAndConfirm,
              icon: _isProcessing
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.check_circle, size: 28),
              label: Text(
                _isProcessing ? 'جاري المعالجة...' : 'تأكيد الاستلام',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successColor,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            SizedBox(height: 16),

            // زر الماسح الضوئي (للمستقبل)
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('الماسح الضوئي قيد التطوير'),
                  ),
                );
              },
              icon: Icon(Icons.camera_alt),
              label: Text('فتح الماسح الضوئي'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}