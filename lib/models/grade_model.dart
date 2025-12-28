/// نموذج الصف الدراسي
class Grade {
  final int id;
  final String name;
  final String? description;
  final List<Subject>? subjects;

  Grade({
    required this.id,
    required this.name,
    this.description,
    this.subjects,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      subjects: json['subjects'] != null
          ? (json['subjects'] as List)
              .map((s) => Subject.fromJson(s as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'subjects': subjects?.map((s) => s.toJson()).toList(),
    };
  }
}

/// نموذج المادة الدراسية
class Subject {
  final int id;
  final String name;
  final String? description;
  final int? gradeId;

  Subject({
    required this.id,
    required this.name,
    this.description,
    this.gradeId,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      gradeId: json['grade_id'] as int? ?? json['grade'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'grade_id': gradeId,
    };
  }
}

/// نموذج الفصل الدراسي
class Term {
  final int id;
  final String name;
  final int termNumber;

  Term({
    required this.id,
    required this.name,
    required this.termNumber,
  });

  factory Term.fromJson(Map<String, dynamic> json) {
    return Term(
      id: json['id'] as int,
      name: json['name'] as String,
      termNumber: json['term_number'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'term_number': termNumber,
    };
  }
}
