import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../services/shipment_service.dart';
import '../utils/constants.dart';

/// شاشة مسح QR Code للمندوب باستخدام الكاميرا
class DriverQrScannerScreen extends StatefulWidget {
  final int? shipmentId; // إذا كان معروف مسبقاً

  const DriverQrScannerScreen({Key? key, this.shipmentId}) : super(key: key);

  @override
  State<DriverQrScannerScreen> createState() => _DriverQrScannerScreenState();
}

class _DriverQrScannerScreenState extends State<DriverQrScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;
  String? _scannedCode;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _verifyQrCode(String qrCode) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _scannedCode = qrCode;
    });

    try {
      final shipmentService = Provider.of<ShipmentService>(context, listen: false);

      final result = await shipmentService.verifyQR(
        qrCode: qrCode,
        shipmentId: widget.shipmentId,
      );

      if (result['success']) {
        _showSuccessDialog(result['message'] ?? 'تم التحقق بنجاح');
      } else {
        _showErrorDialog(result['message'] ?? 'فشل التحقق من QR');
      }
    } catch (e) {
      _showErrorDialog('حدث خطأ: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showSuccessDialog(String message) {
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
            Text(message),
            SizedBox(height: 12),
            if (_scannedCode != null)
              Text(
                'الكود: $_scannedCode',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // إغلاق الديالوج
              Navigator.pop(context, true); // الرجوع مع نتيجة نجاح
            },
            child: Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('خطأ'),
          ],
        ),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isProcessing = false;
                _scannedCode = null;
              });
            },
            child: Text('إعادة المحاولة'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // إغلاق الديالوج
              Navigator.pop(context, false); // الرجوع مع نتيجة فشل
            },
            child: Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مسح QR Code', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: Icon(Icons.flip_camera_ios),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // كاميرا المسح
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null && !_isProcessing) {
                  _verifyQrCode(barcode.rawValue!);
                  break;
                }
              }
            },
          ),

          // إطار للتوجيه
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // تعليمات
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'وجه الكاميرا نحو رمز QR\nسيتم المسح تلقائياً',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          // مؤشر التحميل
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('جاري التحقق...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
