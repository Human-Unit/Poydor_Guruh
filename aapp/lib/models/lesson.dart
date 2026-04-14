import 'category.dart';

class Lesson {
  final int id;
  final String name;
  final int categoryId;
  final Category? category;

  Lesson({
    required this.id,
    required this.name,
    required this.categoryId,
    this.category,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      categoryId: json['category_id'] ?? 0,
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
    );
  }
}
