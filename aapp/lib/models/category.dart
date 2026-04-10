class Category {
  final int id;
  final String name;

  Category({
    required this.id,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['ID'] ?? json['id'] ?? 0,
      name: json['Name'] ?? json['name'] ?? '',
    );
  }
}
