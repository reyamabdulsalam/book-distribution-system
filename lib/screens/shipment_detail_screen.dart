import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/api_shipment_model.dart';
import '../services/shipment_service.dart';
import '../utils/constants.dart';
import 'driver_qr_scanner_screen.dart';

/// شاشة تفاصيل الشحنة للمندوب
class ShipmentDetailScreen extends StatefulWidget {
  final ApiShipment shipment;

  ShipmentDetailScreen({required this.shipment});

  @override
  _ShipmentDetailScreenState createState() => _ShipmentDetailScreenState();
}

class _ShipmentDetailScreenState extends State<ShipmentDetailScreen> {
  final _recipientNameController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isProcessing = false;
  File? _proofPhoto;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _recipientNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _startDelivery() async {
    setState(() => _isProcessing = true);

    try {
      final shipmentService = Provider.of<ShipmentService>(context, listen: false);
      
      final success = await shipmentService.startDelivery(
        widget.shipment.id,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم بدء التوصيل بنجاح'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        throw Exception('فشل في بدء التوصيل');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (photo != null) {
        setState(() {
          _proofPhoto = File(photo.path);
        });

        // رفع الصورة فوراً
        final bytes = await _proofPhoto!.readAsBytes();
        final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

        final shipmentService = Provider.of<ShipmentService>(context, listen: false);
        final success = await shipmentService.uploadProofPhoto(
          widget.shipment.id,
          base64Image,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم رفع الصورة بنجاح'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في رفع الصورة: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _completeDelivery() async {
    if (_recipientNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الرجاء إدخال اسم المستلم'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final shipmentService = Provider.of<ShipmentService>(context, listen: false);

      final result = await shipmentService.completeDelivery(
        shipmentId: widget.shipment.id,
        receivedBy: _recipientNameController.text,
        deliveryNotes: _notesController.text,
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message']), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('تفاصيل الشحنة', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات الشحنة
            _buildInfoCard(),
            SizedBox(height: 16),

            // QR Code
            if (widget.shipment.qrCodeImage != null) _buildQrCard(),
            SizedBox(height: 16),

            // الكتب
            _buildBooksCard(),
            SizedBox(height: 16),

            // حالة التوصيل
            if (widget.shipment.canStartDelivery) _buildStartButton(),
            if (widget.shipment.isOutForDelivery) _buildDeliveryActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('معلومات الشحنة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Divider(),
            _buildInfoRow('رقم التتبع', widget.shipment.trackingCode),
            _buildInfoRow('الحالة', widget.shipment.statusInArabic),
            _buildInfoRow('من', widget.shipment.fromMinistryName ?? '-'),
            _buildInfoRow('إلى المحافظة', widget.shipment.toProvinceName ?? '-'),
            _buildInfoRow('المدرسة', widget.shipment.toSchoolName ?? '-'),
            _buildInfoRow('تاريخ الإنشاء',
                _formatDate(widget.shipment.createdAt)),
            if (widget.shipment.startedDeliveryAt != null)
              _buildInfoRow('بدأ التوصيل',
                  _formatDate(widget.shipment.startedDeliveryAt!)),
          ],
        ),
      ),
    );
  }

  Widget _buildQrCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('رمز QR للشحنة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            if (widget.shipment.qrCodeImage!.startsWith('data:image'))
              Image.memory(
                base64Decode(widget.shipment.qrCodeImage!.split(',')[1]),
                height: 200,
                width: 200,
              )
            else
              Container(
                height: 200,
                width: 200,
                color: Colors.grey[200],
                child: Center(child: Text('QR Code غير متاح')),
              ),
            SizedBox(height: 8),
            Text(
              widget.shipment.isQrValid
                  ? 'صالح حتى: ${_formatDate(widget.shipment.qrExpiresAt!)}'
                  : 'منتهي الصلاحية',
              style: TextStyle(
                color: widget.shipment.isQrValid ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DriverQrScannerScreen(
                        shipmentId: widget.shipment.id,
                      ),
                    ),
                  );
                  if (result == true) {
                    Navigator.pop(context);
                  }
                },
                icon: Icon(Icons.qr_code_scanner),
                label: Text('مسح رمز QR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBooksCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الكتب (${widget.shipment.totalBooks} كتاب)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Divider(),
            ...widget.shipment.books.map((book) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(book.bookName ?? 'كتاب #${book.bookId}'),
                      ),
                      Text('${book.quantity} × ${book.termInArabic}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : _startDelivery,
        icon: Icon(Icons.play_arrow),
        label: Text(_isProcessing ? 'جاري البدء...' : 'بدء التوصيل'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          padding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildDeliveryActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // التقاط صورة الإثبات
        Card(
          child: ListTile(
            leading: Icon(Icons.camera_alt, color: AppColors.primaryColor),
            title: Text('التقاط صورة الإثبات'),
            subtitle: _proofPhoto != null
                ? Text('تم رفع الصورة ✓', style: TextStyle(color: Colors.green))
                : null,
            onTap: _takePhoto,
          ),
        ),
        SizedBox(height: 16),

        // معلومات الاستلام
        Text('معلومات الاستلام',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        TextField(
          controller: _recipientNameController,
          decoration: InputDecoration(
            labelText: 'اسم المستلم *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
        ),
        SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'ملاحظات التسليم',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.note),
          ),
        ),
        SizedBox(height: 16),

        // زر الإكمال
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : _completeDelivery,
            icon: Icon(Icons.check_circle),
            label: Text(_isProcessing ? 'جاري الإكمال...' : 'إكمال التوصيل'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successColor,
              padding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
