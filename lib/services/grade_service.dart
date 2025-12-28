import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/grade_model.dart';
import 'api_client.dart';

/// خدمة إدارة الصفوف الدراسية والمواد
class GradeService with ChangeNotifier {
  List<Grade> _grades = [];
  List<Subject> _subjects = [];
  List<Term> _terms = [];
  bool _isLoading = false;
  String? _error;

  List<Grade> get grades => _grades;
  List<Subject> get subjects => _subjects;
  List<Term> get terms => _terms;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// جلب جميع الصفوف الدراسية
  Future<bool> fetchGrades() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.get('/api/grades/');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is List) {
          _grades = data.map((json) => Grade.fromJson(json)).toList();
        } else if (data['results'] != null) {
          _grades = (data['results'] as List)
              .map((json) => Grade.fromJson(json))
              .toList();
        }

        if (kDebugMode) print('✅ Fetched ${_grades.length} grades');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'فشل في جلب الصفوف الدراسية';
      }
    } catch (e) {
      _error = 'حدث خطأ: ${e.toString()}';
      if (kDebugMode) print('❌ GradeService.fetchGrades error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// جلب جميع المواد الدراسية
  Future<bool> fetchSubjects() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.get('/api/subjects/');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is List) {
          _subjects = data.map((json) => Subject.fromJson(json)).toList();
        } else if (data['results'] != null) {
          _subjects = (data['results'] as List)
              .map((json) => Subject.fromJson(json))
              .toList();
        }

        if (kDebugMode) print('✅ Fetched ${_subjects.length} subjects');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'فشل في جلب المواد الدراسية';
      }
    } catch (e) {
      _error = 'حدث خطأ: ${e.toString()}';
      if (kDebugMode) print('❌ GradeService.fetchSubjects error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// جلب المواد الدراسية لصف معين
  Future<List<Subject>> fetchSubjectsByGrade(int gradeId) async {
    try {
      final response = await ApiClient.get('/api/grades/$gradeId/subjects/');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List<Subject> gradeSubjects;
        if (data is List) {
          gradeSubjects = data.map((json) => Subject.fromJson(json)).toList();
        } else if (data['results'] != null) {
          gradeSubjects = (data['results'] as List)
              .map((json) => Subject.fromJson(json))
              .toList();
        } else {
          gradeSubjects = [];
        }

        if (kDebugMode) {
          print('✅ Fetched ${gradeSubjects.length} subjects for grade $gradeId');
        }
        return gradeSubjects;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ GradeService.fetchSubjectsByGrade error: $e');
      }
    }

    return [];
  }

  /// جلب جميع الفصول الدراسية
  Future<bool> fetchTerms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiClient.get('/api/terms/');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is List) {
          _terms = data.map((json) => Term.fromJson(json)).toList();
        } else if (data['results'] != null) {
          _terms = (data['results'] as List)
              .map((json) => Term.fromJson(json))
              .toList();
        }

        if (kDebugMode) print('✅ Fetched ${_terms.length} terms');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'فشل في جلب الفصول الدراسية';
      }
    } catch (e) {
      _error = 'حدث خطأ: ${e.toString()}';
      if (kDebugMode) print('❌ GradeService.fetchTerms error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// الحصول على المواد حسب الصف من القائمة المحلية
  List<Subject> getSubjectsByGrade(int gradeId) {
    return _subjects.where((s) => s.gradeId == gradeId).toList();
  }

  /// البحث عن صف بالاسم
  Grade? findGradeByName(String name) {
    try {
      return _grades.firstWhere(
        (g) => g.name.trim().toLowerCase() == name.trim().toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// البحث عن مادة بالاسم
  Subject? findSubjectByName(String name) {
    try {
      return _subjects.firstWhere(
        (s) => s.name.trim().toLowerCase() == name.trim().toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}
