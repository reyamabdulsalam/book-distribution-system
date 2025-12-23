import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/order_service.dart';
import '../models/book_model.dart';
import '../models/school_request_model.dart';
import '../utils/constants.dart';

class SchoolOrderScreen extends StatefulWidget {
  @override
  _SchoolOrderScreenState createState() => _SchoolOrderScreenState();
}

class _SchoolOrderScreenState extends State<SchoolOrderScreen> {
  final List<Book> _selectedBooks = [];
  final _formKey = GlobalKey<FormState>();

  // القائمة المتاحة للمواد بعد فلترتها بحسب الصف
  late List<String> _availableSubjects;

  // خريطة تحدد المواد المسموح بها لكل صف
  final Map<String, List<String>> _allowedSubjectsByGrade = {
    // ابتدائي
    'أول ابتدائي': [
      'القرآن الكريم', 'التربية الإسلامية', 'اللغة العربية', 'العلوم', 'الرياضيات'
    ],
    'ثاني ابتدائي': [
      'القرآن الكريم', 'التربية الإسلامية', 'اللغة العربية', 'العلوم', 'الرياضيات'
    ],
    'ثالث ابتدائي': [
      'القرآن الكريم', 'التربية الإسلامية', 'اللغة العربية', 'العلوم', 'الرياضيات'
    ],

    // رابع-خامس-سادس
    'رابع أساسي': [
      'القرآن الكريم', 'التربية الإسلامية', 'اللغة العربية', 'العلوم', 'الرياضيات', 'الإجتماعيات'
    ],
    'خامس أساسي': [
      'القرآن الكريم', 'التربية الإسلامية', 'اللغة العربية', 'العلوم', 'الرياضيات', 'الإجتماعيات'
    ],
    'سادس أساسي': [
      'القرآن الكريم', 'التربية الإسلامية', 'اللغة العربية', 'العلوم', 'الرياضيات', 'الإجتماعيات'
    ],

    // سابع-ثامن-تاسع
    'سابع أساسي': [
      'القرآن الكريم', 'التربية الإسلامية', 'اللغة العربية', 'اللغة الإنجليزية', 'العلوم', 'الرياضيات', 'الجغرافيا', 'التاريخ', 'التربية الوطنية'
    ],
    'ثامن أساسي': [
      'القرآن الكريم', 'التربية الإسلامية', 'اللغة العربية', 'اللغة الإنجليزية', 'العلوم', 'الرياضيات', 'الجغرافيا', 'التاريخ', 'التربية الوطنية'
    ],
    'تاسع أساسي': [
      'القرآن الكريم', 'التربية الإسلامية', 'اللغة العربية', 'اللغة الإنجليزية', 'العلوم', 'الرياضيات', 'الجغرافيا', 'التاريخ', 'التربية الوطنية'
    ],

    // أول ثانوي
    'أول ثانوي': [
      'الإيمان', 'الحديث و الفقه', 'السيرة النبوية', 'القرآن الكريم', 'اللغة الإنجليزية', 'الرياضيات', 'الجغرافيا', 'التاريخ', 'المجتمع', 'الكيمياء', 'الفيزياء', 'الأحياء', 'البلاغة و النقد', 'النحو و الصرف', 'القراءة'
    ],

    // ثاني/ثالث ثانوي (علمي)
    'ثاني ثانوي(علمي)': [
      'القرآن الكريم', 'اللغة الإنجليزية', 'الرياضيات', 'الكيمياء', 'الفيزياء', 'الأحياء', 'البلاغة و النقد', 'النحو و الصرف', 'القراءة', 'الإيمان', 'الحديث و الفقه', 'السيرة النبوية'
    ],
    'ثالث ثانوي(علمي)': [
      'القرآن الكريم', 'اللغة الإنجليزية', 'الرياضيات', 'الكيمياء', 'الفيزياء', 'الأحياء', 'البلاغة و النقد', 'النحو و الصرف', 'القراءة', 'الإيمان', 'الحديث و الفقه', 'السيرة النبوية'
    ],

    // ثاني/ثالث ثانوي (أدبي)
    'ثاني ثانوي(أدبي)': [
      'القرآن الكريم', 'اللغة الإنجليزية', 'الرياضيات', 'الجغرافيا', 'التاريخ', 'المجتمع', 'الإحصاء', 'البلاغة و النقد', 'النحو و الصرف', 'القراءة', 'علم النفس', 'الإيمان', 'الحديث و الفقه', 'السيرة النبوية'
    ],
    'ثالث ثانوي(أدبي)': [
      'القرآن الكريم', 'اللغة الإنجليزية', 'الرياضيات', 'الجغرافيا', 'التاريخ', 'المجتمع', 'الإحصاء', 'البلاغة و النقد', 'النحو و الصرف', 'القراءة', 'علم النفس', 'الإيمان', 'الحديث و الفقه', 'السيرة النبوية'
    ],
  };

  // قائمة المواد الدراسية
  final List<String> _subjects = [
    'القرآن الكريم',
    'التربية الإسلامية',
    'اللغة العربية',
    'اللغة الإنجليزية',
    'العلوم',
    'الرياضيات',
    'الإجتماعيات',
    'الجغرافيا',
    'التاريخ',
    'التربية الوطنية',
    'المجتمع',
    'الكيمياء',
    'الفيزياء',
    'الأحياء',
    'الإحصاء',
    'البلاغة و النقد',
    'النحو و الصرف',
    'القراءة',
    'علم النفس',
    'الإيمان',
    'الحديث و الفقه',
    'السيرة النبوية'
  ];

  // قائمة الصفوف الدراسية
  final List<String> _grades = [
    'أول ابتدائي',
    'ثاني ابتدائي',
    'ثالث ابتدائي',
    'رابع أساسي',
    'خامس أساسي',
    'سادس أساسي',
    'سابع أساسي',
    'ثامن أساسي',
    'تاسع أساسي',
    'أول ثانوي',
    'ثاني ثانوي(علمي)',
    'ثالث ثانوي(علمي)',
    'ثاني ثانوي(أدبي)',
    'ثالث ثانوي(أدبي)'
  ];

  // المتغيرات لتخزين القيم المختارة
  String? _selectedSubject;
  String? _selectedGrade;
  final TextEditingController _quantityController = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    _availableSubjects = List<String>.from(_subjects);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('طلب كتب جديدة', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Dropdown لاختيار الصف (يظهر أولاً حتى تتحدد المواد المتاحة)
              DropdownButtonFormField<String>(
                value: _selectedGrade,
                decoration: InputDecoration(
                  labelText: 'اختر الصف',
                  border: OutlineInputBorder(),
                ),
                items: _grades.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGrade = newValue;
                    // فلترة المواد حسب الصف المختار
                    if (newValue != null && _allowedSubjectsByGrade.containsKey(newValue)) {
                      _availableSubjects = List<String>.from(_allowedSubjectsByGrade[newValue]!);
                    } else {
                      _availableSubjects = List<String>.from(_subjects);
                    }
                    // إعادة تعيين المادة المختارة عند تغيير الصف
                    _selectedSubject = null;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى اختيار الصف';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Dropdown لاختيار المادة (تُفلتر حسب الصف)
              DropdownButtonFormField<String>(
                value: _selectedSubject,
                decoration: InputDecoration(
                  labelText: 'اختر المادة',
                  border: OutlineInputBorder(),
                ),
                // إذا لم يُختر صف بعد فنجعل القائمة معطلة
                items: (_selectedGrade == null)
                    ? <DropdownMenuItem<String>>[]
                    : _availableSubjects.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                onChanged: (_selectedGrade == null)
                    ? null
                    : (String? newValue) {
                        setState(() {
                          _selectedSubject = newValue;
                        });
                      },
                validator: (value) {
                  // نطلب اختيار المادة فقط إذا كان الصف محددًا
                  if (_selectedGrade != null) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى اختيار المادة';
                    }
                  }
                  return null;
                },
                hint: (_selectedGrade == null) ? Text('اختر الصف أولاً') : null,
              ),
              SizedBox(height: 16),

              // حقل إدخال الكمية
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'الكمية',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == 0) {
                    return 'يرجى إدخال كمية صحيحة';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // زر إضافة الكتاب إلى القائمة
              ElevatedButton(
                onPressed: _addBook,
                child: Text('إضافة الكتاب'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.schoolColor,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 16),

              // عنوان قائمة الكتب المختارة
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'الكتب المختارة:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8),

              // قائمة الكتب المختارة
              Expanded(
                child: _selectedBooks.isEmpty
                    ? Center(
                  child: Text(
                    'لم يتم إضافة أي كتب بعد',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
                    : ListView.builder(
                  itemCount: _selectedBooks.length,
                  itemBuilder: (context, index) {
                    final book = _selectedBooks[index];
                    return Card(
                      child: ListTile(
                        title: Text(book.title),
                        subtitle: Text('الصف: ${book.grade} - الكمية: ${book.quantity}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeBook(index),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // زر إرسال الطلب
              ElevatedButton(
                onPressed: _submitOrder,
                child: Text('إرسال الطلب'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.schoolColor,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة لإضافة كتاب إلى القائمة
  void _addBook() {
    if (_formKey.currentState!.validate()) {
      final quantity = int.tryParse(_quantityController.text) ?? 0;

      if (quantity > 0 && _selectedSubject != null && _selectedGrade != null) {
        setState(() {
          _selectedBooks.add(Book(
            id: 'book_${DateTime.now().millisecondsSinceEpoch}',
            title: _selectedSubject!,
            grade: _selectedGrade!,
            quantity: quantity,
          ));

          // إعادة تعيين الحقول
          _selectedSubject = null;
          _selectedGrade = null;
          _quantityController.text = '0';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم إضافة الكتاب إلى القائمة')),
        );
      }
    }
  }

  // دالة لإزالة كتاب من القائمة
  void _removeBook(int index) {
    setState(() {
      _selectedBooks.removeAt(index);
    });
  }

  void _submitOrder() async {
    if (_selectedBooks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى إضافة كتب إلى الطلب أولاً')),
      );
      return;
    }

    final orderService = Provider.of<OrderService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    // التحقق من وجود schoolId
    if (authService.currentUser?.schoolId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: لا يمكن تحديد المدرسة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // تحويل schoolId إلى int بشكل آمن
    final schoolId = int.tryParse(authService.currentUser!.schoolId!);
    if (schoolId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: رقم المدرسة غير صالح'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // إنشاء SchoolRequest للإرسال إلى Backend
    final schoolRequest = SchoolRequest(
      schoolId: schoolId,
      status: 'submitted',
      items: _selectedBooks.asMap().entries.map((entry) {
        final index = entry.key;
        final book = entry.value;
        return SchoolRequestItem(
          bookId: index + 1, // استخدام index فريد لكل كتاب (1, 2, 3, ...)
          bookTitle: book.title,
          grade: book.grade,
          quantity: book.quantity,
        );
      }).toList(),
      requestDate: DateTime.now(),
    );

    // عرض مؤشر تحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    // إرسال الطلب إلى Backend
    final result = await orderService.createSchoolRequest(schoolRequest);
    
    // التحقق من أن Widget لا يزال موجوداً
    if (!mounted) return;
    
    // إغلاق مؤشر التحميل
    Navigator.pop(context);

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ تم إرسال الطلب بنجاح (ID: ${result.id})'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.pop(context);
    } else {
      // عرض رسالة خطأ مفصلة
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ فشل إرسال الطلب. تحقق من Console للتفاصيل'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
          action: SnackBarAction(
            label: 'إعادة المحاولة',
            textColor: Colors.white,
            onPressed: () => _submitOrder(),
          ),
        ),
      );
    }
  }
}