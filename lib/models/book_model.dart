class Book {
  final String id;
  final String title;
  final String grade;
  final int quantity;
  final int? gradeId;
  final int? subjectId;

  Book({
    required this.id,
    required this.title,
    required this.grade,
    required this.quantity,
    this.gradeId,
    this.subjectId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'grade': grade,
      'quantity': quantity,
      if (gradeId != null) 'grade_id': gradeId,
      if (subjectId != null) 'subject_id': subjectId,
    };
  }

  static Book fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      grade: json['grade'],
      quantity: json['quantity'],
      gradeId: json['grade_id'] ?? json['gradeId'],
      subjectId: json['subject_id'] ?? json['subjectId'],
    );
  }
}