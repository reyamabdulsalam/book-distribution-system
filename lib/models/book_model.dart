class Book {
  final String id;
  final String title;
  final String grade;
  final int quantity;

  Book({
    required this.id,
    required this.title,
    required this.grade,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'grade': grade,
      'quantity': quantity,
    };
  }

  static Book fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      grade: json['grade'],
      quantity: json['quantity'],
    );
  }
}