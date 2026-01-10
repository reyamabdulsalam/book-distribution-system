import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/order_service.dart';
import '../services/grade_service.dart';
import '../models/book_model.dart';
import '../models/school_request_model.dart';
import '../models/grade_model.dart';
import '../utils/constants.dart';
import '../widgets/custom_drawer.dart';

class SchoolOrderScreen extends StatefulWidget {
  @override
  _SchoolOrderScreenState createState() => _SchoolOrderScreenState();
}

class _SchoolOrderScreenState extends State<SchoolOrderScreen> {
  final List<Book> _selectedBooks = [];
  final _formKey = GlobalKey<FormState>();
  // الفصل الدراسي المختار (افتراضي: الفصل الأول)
  String _selectedSemester = 'first'; // values: 'first', 'second'

  // القوائم الديناميكية من API
  List<Grade> _grades = [];
  List<Subject> _availableSubjects = [];
  bool _isLoadingGrades = false;
  bool _isLoadingSubjects = false;

  // المتغيرات لتخزين القيم المختارة
  Grade? _selectedGrade;
  Subject? _selectedSubject;
  final TextEditingController _quantityController = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  // جلب الصفوف من API
  Future<void> _loadGrades() async {
    setState(() => _isLoadingGrades = true);
    
    final gradeService = Provider.of<GradeService>(context, listen: false);
    final success = await gradeService.fetchGrades();
    
    if (success) {
      setState(() {
        _grades = gradeService.grades;
        _isLoadingGrades = false;
      });
    } else {
      setState(() => _isLoadingGrades = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في جلب الصفوف الدراسية'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // جلب المواد لصف معين
  Future<void> _loadSubjectsForGrade(int gradeId) async {
    setState(() => _isLoadingSubjects = true);
    
    final gradeService = Provider.of<GradeService>(context, listen: false);
    final subjects = await gradeService.fetchSubjectsByGrade(gradeId);
    
    setState(() {
      _availableSubjects = subjects;
      _selectedSubject = null; // إعادة تعيين المادة المختارة
      _isLoadingSubjects = false;
    });
  }

  // دالة لتحويل term إلى نص عربي
  String _getSemesterText(String term) {
    return term == 'first' ? 'الفصل الأول' : 'الفصل الثاني';
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          authService.currentUser?.schoolName ?? 'طلب كتب جديدة',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      drawer: CustomDrawer(currentScreen: 'home'),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Dropdown لاختيار الفصل الدراسي
              DropdownButtonFormField<String>(
                value: _selectedSemester,
                decoration: InputDecoration(
                  labelText: 'اختر الفصل الدراسي',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'first', child: Text('الفصل الأول')),
                  DropdownMenuItem(value: 'second', child: Text('الفصل الثاني')),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSemester = newValue ?? 'first';
                  });
                },
              ),
              SizedBox(height: 16),
              // Dropdown لاختيار الصف (يظهر أولاً حتى تتحدد المواد المتاحة)
              _isLoadingGrades
                  ? Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<Grade>(
                      value: _selectedGrade,
                      decoration: InputDecoration(
                        labelText: 'اختر الصف',
                        border: OutlineInputBorder(),
                      ),
                      items: _grades.map((Grade grade) {
                        return DropdownMenuItem<Grade>(
                          value: grade,
                          child: Text(grade.name),
                        );
                      }).toList(),
                      onChanged: (Grade? newValue) {
                        setState(() {
                          _selectedGrade = newValue;
                          _selectedSubject = null;
                          _availableSubjects = [];
                        });
                        if (newValue != null) {
                          _loadSubjectsForGrade(newValue.id);
                        }
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'يرجى اختيار الصف';
                        }
                        return null;
                      },
                    ),
              SizedBox(height: 16),

              // Dropdown لاختيار المادة (يظهر بعد اختيار الصف)
              _isLoadingSubjects
                  ? Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<Subject>(
                      value: _selectedSubject,
                      decoration: InputDecoration(
                        labelText: 'اختر المادة',
                        border: OutlineInputBorder(),
                      ),
                      items: _availableSubjects.map((Subject subject) {
                        return DropdownMenuItem<Subject>(
                          value: subject,
                          child: Text(subject.name),
                        );
                      }).toList(),
                      onChanged: (_selectedGrade == null)
                          ? null
                          : (Subject? newValue) {
                              setState(() {
                                _selectedSubject = newValue;
                              });
                            },
                      validator: (value) {
                        // نطلب اختيار المادة فقط إذا كان الصف محددًا
                        if (_selectedGrade != null) {
                          if (value == null) {
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
                        subtitle: Text(
                          'الصف: ${book.grade}\n'
                          'الكمية: ${book.quantity} - ${_getSemesterText(_selectedSemester)}'
                        ),
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
            title: _selectedSubject!.name,
            grade: _selectedGrade!.name,
            quantity: quantity,
          ));

          // إعادة تعيين الحقول
          _selectedSubject = null;
          _quantityController.text = '0';
          // لا نعيد تعيين الصف للسماح بإضافة مواد متعددة لنفس الصف
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
          term: _selectedSemester,
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