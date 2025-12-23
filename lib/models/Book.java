class Book {
    final String id;
    final String title;
    final String grade;
    final String subject;
    final int quantity;
    final String term;

    Book({
        required this.id,
                required this.title,
                required this.grade,
                required this.subject,
                required this.quantity,
                required this.term,
    });

    factory Book.fromJson(Map<String, dynamic> json) {
        return Book(
                id: json['id'] ?? '',
                title: json['title'] ?? '',
                grade: json['grade'] ?? '',
                subject: json['subject'] ?? '',
                quantity: json['quantity'] ?? 0,
                term: json['term'] ?? '',
    );
    }

    Map<String, dynamic> toJson() {
        return {
                'id': id,
                'title': title,
                'grade': grade,
                'subject': subject,
                'quantity': quantity,
                'term': term,
    };
    }
}